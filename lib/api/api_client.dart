import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';
import 'exceptions.dart';

/// Exception thrown when network connectivity is unavailable.
class ConnectivityException implements Exception {
  final String message;
  ConnectivityException([this.message = 'No internet connection']);
  @override
  String toString() => 'ConnectivityException: $message';
}

class ApiClient {
  final Dio _dio;
  final Future<void> Function()? _checkConnectivityFn;

  ApiClient({
    String? baseUrl,
    FlutterSecureStorage? storage,
    Future<void> Function()? onLogout,
    Dio? dio,
    Future<void> Function()? checkConnectivity,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? ApiConfig.baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
             ),
           ),
       _checkConnectivityFn = checkConnectivity {
    // Only add interceptor if we're using the internally created Dio
    if (dio == null) {
      final effectiveStorage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );
      _dio.interceptors.add(
        AuthInterceptor(
          storage: effectiveStorage,
          dio: _dio,
          onLogout: onLogout ?? () async {},
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<void> _checkConnectivity() async {
    if (_checkConnectivityFn != null) {
      await _checkConnectivityFn();
      return;
    }
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw ConnectivityException();
    }
  }

  Future<T> _execute<T>({
    required Future<Response<dynamic>> Function() dioCall,
    required String endpoint,
    required T Function(dynamic data) parse,
  }) async {
    await _checkConnectivity();
    try {
      final res = await dioCall();
      return parse(res.data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
          throw NetworkException('Tidak dapat terhubung ke server.');
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw TimeoutException(const Duration(seconds: 30), endpoint);
        case DioExceptionType.badResponse:
          final userMessage = extractErrorMessage(e);
          throw ApiException(
            statusCode: e.response?.statusCode ?? 0,
            body: e.response?.data?.toString(),
            endpoint: endpoint,
            userMessage: userMessage,
          );
        default:
          final userMessage = extractErrorMessage(e);
          throw ApiException(
            statusCode: 0,
            body: e.message ?? 'Unknown error',
            endpoint: endpoint,
            userMessage: userMessage,
          );
      }
    }
  }

  // ─── Core HTTP helpers ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String path) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(path),
      endpoint: path,
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(path, data: data),
      endpoint: path,
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.patch(path, data: data),
      endpoint: path,
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> uploadWithPhotos(
    String path,
    Map<String, dynamic> data,
    List<String> photoPaths,
  ) async {
    final mapData = <String, dynamic>{...data};
    for (var i = 0; i < photoPaths.length; i++) {
      final file = File(photoPaths[i]);
      final bytes = await file.readAsBytes();
      final name = photoPaths[i].split('/').last;
      mapData['photos[$i]'] = MultipartFile.fromBytes(bytes, filename: name);
    }
    final formData = FormData.fromMap(mapData);
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(path, data: formData),
      endpoint: path,
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> uploadPhotoBytes(
    String url,
    List<int> bytes,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: filename),
    });
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      ),
      endpoint: url,
      parse: (data) {
        if (data is Map) {
          return data.cast<String, dynamic>();
        }
        return <String, dynamic>{};
      },
    );
  }

  // ─── Categories ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/categories'),
      endpoint: '/api/categories',
      parse: (data) =>
          (data['categories'] as List).cast<Map<String, dynamic>>(),
    );
  }

  // ─── Reports ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createReport({
    required String idempotencyKey,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? deviceId,
    String? title,
    List<Map<String, dynamic>>? photos,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/reports',
        data: {
          'idempotency_key': idempotencyKey,
          'category_id': categoryId,
          'description': description,
          'title': title,
          'lat': lat,
          'lng': lng,
          if (deviceId != null) 'device_id': deviceId,
          if (photos != null && photos.isNotEmpty)
            'photos': photos
                .map(
                  (p) => {
                    'report_idempotency_key': p['report_idempotency_key'],
                    'file_path': p['file_path'],
                    if (p['exif_data_json'] != null)
                      'exif_data_json': p['exif_data_json'],
                  },
                )
                .toList(),
        },
      ),
      endpoint: '/api/reports',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> syncBatch({
    required List<Map<String, dynamic>> reports,
    String? deviceId,
    List<Map<String, dynamic>>? photos,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/sync/batch',
        data: {
          if (deviceId != null) 'device_id': deviceId,
          'reports': reports,
          if (photos != null && photos.isNotEmpty) 'photos': photos,
        },
      ),
      endpoint: '/api/sync/batch',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Verifikator ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifikatorDecide({
    required String caseId,
    required String decision,
    String? reason,
    String? duplicateOfReportId,
    String? surveyorId,
    String? assignedUnitId,
    String? deadline,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/decide',
        data: {
          'decision': decision,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (duplicateOfReportId != null)
            'duplicate_of_report_id': duplicateOfReportId,
          if (surveyorId != null) 'surveyor_id': surveyorId,
          if (assignedUnitId != null) 'assigned_unit_id': assignedUnitId,
          if (deadline != null) 'deadline': deadline,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/decide',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> rtRwVerify({
    required String verificationToken,
    required String reportId,
    required String verdict,
    String? reason,
    String? photoPath,
  }) async {
    final mapData = <String, dynamic>{
      'verification_token': verificationToken,
      'report_id': reportId,
      'verdict': verdict,
    };
    if (reason != null && reason.isNotEmpty) {
      mapData['reason'] = reason;
    }
    if (photoPath != null) {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final name = photoPath.split('/').last;
      mapData['photo'] = MultipartFile.fromBytes(bytes, filename: name);
    }
    final formData = FormData.fromMap(mapData);
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/rt-rw/verify', data: formData),
      endpoint: '/api/rt-rw/verify',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Petugas ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> petugasAcceptTask(String taskId) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/petugas/tasks/$taskId/accept'),
      endpoint: '/api/petugas/tasks/$taskId/accept',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> petugasRejectTask(
    String taskId,
    String reason,
  ) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/petugas/tasks/$taskId/reject',
        data: {'reason': reason},
      ),
      endpoint: '/api/petugas/tasks/$taskId/reject',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> petugasUpdateProgress({
    required String taskId,
    required int progressPercent,
    String? notes,
    String? estimatedCompletion,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.patch(
        '/api/petugas/tasks/$taskId/progress',
        data: {
          'progress_percent': progressPercent,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (estimatedCompletion != null)
            'estimated_completion': estimatedCompletion,
        },
      ),
      endpoint: '/api/petugas/tasks/$taskId/progress',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> petugasUploadEvidence(
    String taskId,
    List<String> photoPaths, {
    String? notes,
  }) async {
    return uploadWithPhotos('/api/petugas/tasks/$taskId/evidence', {
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    }, photoPaths);
  }

  Future<Map<String, dynamic>> petugasCompleteTask(
    String taskId, {
    required String summary,
    required List<String> photoPaths,
  }) async {
    return uploadWithPhotos('/api/petugas/tasks/$taskId/complete', {
      'summary': summary,
    }, photoPaths);
  }

  Future<Map<String, dynamic>> petugasRequestClarification(
    String taskId, {
    required String question,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/petugas/tasks/$taskId/clarification',
        data: {'question': question},
      ),
      endpoint: '/api/petugas/tasks/$taskId/clarification',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<List<Map<String, dynamic>>> petugasGetTasks() async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/petugas/tasks'),
      endpoint: '/api/petugas/tasks',
      parse: (data) => (data['tasks'] as List).cast<Map<String, dynamic>>(),
    );
  }

  // ─── Surveyor ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> surveyorGetTasks() async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/surveyor/tasks'),
      endpoint: '/api/surveyor/tasks',
      parse: (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }

  Future<Map<String, dynamic>> surveyorGetTaskDetail(String taskId) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/surveyor/tasks/$taskId'),
      endpoint: '/api/surveyor/tasks/$taskId',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> surveyorSubmitVisit(
    String taskId,
    Map<String, dynamic> visitData,
  ) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/surveyor/tasks/$taskId/visit', data: visitData),
      endpoint: '/api/surveyor/tasks/$taskId/visit',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> surveyorAcceptTask(String taskId) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/surveyor/tasks/$taskId/accept'),
      endpoint: '/api/surveyor/tasks/$taskId/accept',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> surveyorStartTask(String taskId) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/surveyor/tasks/$taskId/start'),
      endpoint: '/api/surveyor/tasks/$taskId/start',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Warga ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> wargaFileSanggahan({
    required String reportId,
    required String reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/warga/sanggahan/$reportId', data: {'reason': reason}),
      endpoint: '/api/warga/sanggahan/$reportId',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> wargaRequestReopen({
    required String reportId,
    required String reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/warga/reopen/$reportId', data: {'reason': reason}),
      endpoint: '/api/warga/reopen/$reportId',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> wargaSubmitEvidence({
    required String reportId,
    required String description,
    required List<String> photoPaths,
  }) async {
    return uploadWithPhotos('/api/warga/evidence/$reportId', {
      'description': description,
    }, photoPaths);
  }

  Future<List<Map<String, dynamic>>> getWargaReports() async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/reports?creator_id=me'),
      endpoint: '/api/reports?creator_id=me',
      parse: (data) {
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data.containsKey('reports')) {
          return (data['reports'] as List).cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  Future<Map<String, dynamic>> validateRole(String role) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/auth/validate-role', data: {'role': role}),
      endpoint: '/api/auth/validate-role',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Operator ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> operatorSeparateCase({
    required String caseId,
    required String reason,
    String? targetUnitId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/separate',
        data: {
          'reason': reason,
          if (targetUnitId != null) 'target_unit_id': targetUnitId,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/separate',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }
}
