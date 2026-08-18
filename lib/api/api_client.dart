import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';
import 'exceptions.dart';
import 'types.g.dart';

/// Exception thrown when network connectivity is unavailable.
class ConnectivityException implements Exception {
  final String message;
  ConnectivityException([this.message = 'No internet connection']);
  @override
  String toString() => 'ConnectivityException: $message';
}

class ApiClient {
  final Dio _dio;
  final Dio _publicDio;
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
       _checkConnectivityFn = checkConnectivity,
       _publicDio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? ApiConfig.baseUrl,
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 30),
         ),
       ) {
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

  /// Fetches a single report by ID from the API.
  Future<Map<String, dynamic>> getReportById(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/reports/$id'),
      endpoint: '/api/reports/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Updates a report via PATCH /api/reports/:id.
  ///
  /// [data] can include: status, description, priority (severity), assigned_to.
  Future<Map<String, dynamic>> updateReport(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.patch('/api/reports/$id', data: data),
      endpoint: '/api/reports/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Deletes a report via DELETE /api/reports/:id.
  Future<void> deleteReport(String id) async {
    await _execute<void>(
      dioCall: () => _dio.delete('/api/reports/$id'),
      endpoint: '/api/reports/$id',
      parse: (_) {},
    );
  }

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
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/sync/batch',
        data: {if (deviceId != null) 'device_id': deviceId, 'reports': reports},
      ),
      endpoint: '/api/sync/batch',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Verifikator ───────────────────────────────────────────────────────────

  /// Fetches the verifikator queue (list of cases pending review).
  Future<Map<String, dynamic>> getVerifikatorQueue({
    String? status,
    int page = 1,
    int limit = 20,
    String? kategori,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/verifikator',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (kategori != null) 'kategori': kategori,
        },
      ),
      endpoint: '/api/verifikator',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches a single verifikator case by ID.
  Future<Map<String, dynamic>> getVerifikatorCase(String caseId) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/verifikator/cases/$caseId'),
      endpoint: '/api/verifikator/cases/$caseId',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Accepts a verifikator case (transitions to verified).
  Future<Map<String, dynamic>> acceptVerifikatorCase(
    String caseId, {
    String? reason,
    String? assignedUnitId,
    String? deadline,
    int? priority,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/accept',
        data: {
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (assignedUnitId != null) 'assigned_unit_id': assignedUnitId,
          if (deadline != null) 'deadline': deadline,
          if (priority != null) 'priority': priority,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/accept',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Combines/merges a verifikator case into another case.
  Future<Map<String, dynamic>> combineVerifikatorCase(
    String caseId, {
    required String targetCaseId,
    String? reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/combine',
        data: {
          'target_case_id': targetCaseId,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/combine',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Separates a verifikator case into a new case.
  Future<Map<String, dynamic>> separateVerifikatorCase(
    String caseId, {
    required String newCaseDescription,
    String? reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/separate',
        data: {
          'new_case_description': newCaseDescription,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/separate',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Rejects a verifikator case.
  Future<Map<String, dynamic>> rejectVerifikatorCase(
    String caseId, {
    required String reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/reject',
        data: {'reason': reason},
      ),
      endpoint: '/api/verifikator/cases/$caseId/reject',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Makes a decision on a verifikator case.
  Future<Map<String, dynamic>> decideVerifikatorCase({
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

  /// Alias for [decideVerifikatorCase] for backward compatibility.
  Future<Map<String, dynamic>> verifikatorDecide({
    required String caseId,
    required String decision,
    String? reason,
    String? duplicateOfReportId,
    String? surveyorId,
    String? assignedUnitId,
    String? deadline,
  }) async {
    return decideVerifikatorCase(
      caseId: caseId,
      decision: decision,
      reason: reason,
      duplicateOfReportId: duplicateOfReportId,
      surveyorId: surveyorId,
      assignedUnitId: assignedUnitId,
      deadline: deadline,
    );
  }

  /// Reviews a sanggahan (objection) on a verifikator case.
  Future<Map<String, dynamic>> reviewSanggahan(
    String caseId, {
    required String decision,
    String? reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/review-sanggahan',
        data: {
          'decision': decision,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/review-sanggahan',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Verifies completion of a verifikator case.
  Future<Map<String, dynamic>> verifyCompletion(
    String caseId, {
    required String decision,
    String? reason,
    String? completionNotes,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/verify-completion',
        data: {
          'decision': decision,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (completionNotes != null && completionNotes.isNotEmpty)
            'completion_notes': completionNotes,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/verify-completion',
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

  Future<Map<String, dynamic>> getPetugasTaskDetail(String taskId) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/petugas/tasks/$taskId'),
      endpoint: '/api/petugas/tasks/$taskId',
      parse: (data) => (data as Map).cast<String, dynamic>(),
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

  /// Fetches the checklist template for a surveyor task.
  Future<Map<String, dynamic>> getSurveyorChecklistTemplate(
    String taskId,
  ) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/surveyor/tasks/$taskId/checklist-template'),
      endpoint: '/api/surveyor/tasks/$taskId/checklist-template',
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

  /// Submits a structured visit report for a surveyor task.
  ///
  /// [taskId] - The surveyor task ID
  /// [photos] - Map of 4 corner photo paths: {depan, belakang, kiri, kanan}
  /// [gpsLat] - GPS latitude coordinate
  /// [gpsLng] - GPS longitude coordinate
  /// [accuracy] - GPS accuracy in meters
  /// [kondisi] - Condition selection (e.g., 'baik', 'rusak', 'berbahaya')
  /// [rekomendasi] - Recommendation selection (e.g., 'perbaikan', 'penggantian', 'pemeliharaan')
  /// [catatan] - Additional notes text
  Future<Map<String, dynamic>> submitVisitReport({
    required String taskId,
    required Map<String, String> photos,
    required double gpsLat,
    required double gpsLng,
    required double accuracy,
    required String kondisi,
    required String rekomendasi,
    String? catatan,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/surveyor/tasks/$taskId/visit',
        data: {
          'photos': photos,
          'gps_lat': gpsLat,
          'gps_lng': gpsLng,
          'accuracy': accuracy,
          'kondisi': kondisi,
          'rekomendasi': rekomendasi,
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
        },
      ),
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

  Future<Map<String, dynamic>> surveyorRejectTask(
    String taskId,
    String reason,
  ) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/surveyor/tasks/$taskId/reject',
        data: {'reason': reason},
      ),
      endpoint: '/api/surveyor/tasks/$taskId/reject',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  Future<Map<String, dynamic>> surveyorRequestClarification(
    String taskId, {
    required String question,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/surveyor/tasks/$taskId/clarification',
        data: {'question': question},
      ),
      endpoint: '/api/surveyor/tasks/$taskId/clarification',
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

  // ─── Warga Stats & Nearby ──────────────────────────────────────────────────

  /// Fetches warga statistics (submitted, verified, in_progress, resolved counts).
  Future<Map<String, dynamic>> getWargaStats() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/warga/stats'),
      endpoint: '/api/warga/stats',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches nearby reports based on user location.
  Future<List<Map<String, dynamic>>> getNearbyReports({
    required double lat,
    required double lng,
  }) async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get(
        '/api/reports/nearby',
        queryParameters: {'lat': lat, 'lng': lng},
      ),
      endpoint: '/api/reports/nearby',
      parse: (data) {
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data.containsKey('reports')) {
          return (data['reports'] as List).cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  // ─── Duplicate Cases (M-11) ────────────────────────────────────────────────

  /// Fetches duplicate case candidates for a given location and category.
  ///
  /// Used by SimilarCasesBanner during report creation to surface
  /// nearby cases that may be duplicates.
  Future<List<Map<String, dynamic>>> getDuplicateCases({
    required double lat,
    required double lng,
    String? categoryId,
  }) async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get(
        '/api/reports/duplicates',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/reports/duplicates',
      parse: (data) {
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data.containsKey('duplicates')) {
          return (data['duplicates'] as List).cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  // ─── Report Timeline ─────────────────────────────────────────────────────────

  /// Fetches the timeline/history events for a given report.
  Future<Map<String, dynamic>> getReportTimeline(String reportId) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/reports/$reportId/timeline'),
      endpoint: '/api/reports/$reportId/timeline',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Export ────────────────────────────────────────────────────────────────

  /// Exports reports as PDF.
  Future<Uint8List> exportPdf({
    String? status,
    String? categoryId,
    String? wilayahId,
    String? from,
    String? to,
  }) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (categoryId != null) query['category_id'] = categoryId;
    if (wilayahId != null) query['wilayah_id'] = wilayahId;
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;
    final uri = Uri.parse(
      '${_dio.options.baseUrl}/api/export/pdf',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final resp = await _dio.get<List<int>>(
      uri.toString(),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(resp.data ?? []);
  }

  // ─── Operator ──────────────────────────────────────────────────────────────

  /// Fetches operator case list with pagination and filters.
  Future<Map<String, dynamic>> getOperatorCases({
    int page = 1,
    int limit = 20,
    String? status,
    String? wilayahId,
    String? categoryId,
    String? search,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/operator/',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (wilayahId != null) 'wilayah_id': wilayahId,
          if (categoryId != null) 'category_id': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
      endpoint: '/api/operator/',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches operator dashboard summary data.
  Future<Map<String, dynamic>> getOperatorDashboard() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/operator/dashboard'),
      endpoint: '/api/operator/dashboard',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches operator statistics.
  Future<Map<String, dynamic>> getOperatorStats() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/operator/stats'),
      endpoint: '/api/operator/stats',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches operator backlog data (daily buckets).
  Future<Map<String, dynamic>> getOperatorBacklog({int days = 30}) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.get('/api/operator/backlog', queryParameters: {'days': days}),
      endpoint: '/api/operator/backlog',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches operator queue counts (new reports, SLA breached, etc).
  Future<Map<String, dynamic>> getOperatorQueueCounts() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/operator/queue-counts'),
      endpoint: '/api/operator/queue-counts',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Merges multiple cases into one primary case.
  Future<Map<String, dynamic>> mergeOperatorCase({
    required String caseId,
    required List<String> targetCaseIds,
    String? reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/merge',
        data: {
          'target_case_ids': targetCaseIds,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/merge',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Separates a case into multiple new cases.
  Future<Map<String, dynamic>> separateOperatorCase({
    required String caseId,
    required List<String> reportIdsToSeparate,
    String? reason,
    String? targetUnitId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/separate',
        data: {
          'report_ids_to_separate': reportIdsToSeparate,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (targetUnitId != null) 'target_unit_id': targetUnitId,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/separate',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Sets override priority score for a case.
  Future<Map<String, dynamic>> setOperatorPriority({
    required String caseId,
    required int newScore,
    String? reason,
    Map<String, dynamic>? factorBreakdown,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/priority',
        data: {
          'new_score': newScore,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (factorBreakdown != null) 'factor_breakdown': factorBreakdown,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/priority',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Assigns a case to a unit with optional instructions and deadline.
  Future<Map<String, dynamic>> assignOperatorCase({
    required String caseId,
    required String unitId,
    String? instructions,
    String? deadline,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/assign',
        data: {
          'unit_id': unitId,
          if (instructions != null && instructions.isNotEmpty)
            'instructions': instructions,
          if (deadline != null) 'deadline': deadline,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/assign',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Escalates a case to higher severity/priority.
  Future<Map<String, dynamic>> escalateOperatorCase({
    required String caseId,
    required String reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/escalate',
        data: {'reason': reason},
      ),
      endpoint: '/api/operator/cases/$caseId/escalate',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Updates the SLA deadline for a case.
  Future<Map<String, dynamic>> setOperatorSla({
    required String caseId,
    required String newDeadline,
    required String reason,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.patch(
        '/api/operator/cases/$caseId/sla',
        data: {'new_deadline': newDeadline, 'reason': reason},
      ),
      endpoint: '/api/operator/cases/$caseId/sla',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Admin ──────────────────────────────────────────────────────────────────

  /// Fetches admin users list (paginated).
  Future<Map<String, dynamic>> getAdminUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
    bool? isActive,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/users',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (role != null) 'role': role,
          if (search != null && search.isNotEmpty) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin/users',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin units list (paginated).
  Future<Map<String, dynamic>> getAdminUnits({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/units',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
      endpoint: '/api/admin/units',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin checklist templates (paginated).
  Future<Map<String, dynamic>> getAdminChecklistTemplates({
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/checklist-templates',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/admin/checklist-templates',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin priority config versions (paginated).
  Future<Map<String, dynamic>> getAdminPriorityConfig({
    int page = 1,
    int limit = 20,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/priority-config',
        queryParameters: {'page': page, 'limit': limit},
      ),
      endpoint: '/api/admin/priority-config',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Creates a new priority config version.
  Future<Map<String, dynamic>> saveAdminPriorityConfig({
    required Map<String, dynamic> weights,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/admin/priority-config', data: {'weights': weights}),
      endpoint: '/api/admin/priority-config',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin outbox dead-letter queue (paginated).
  Future<Map<String, dynamic>> getAdminOutbox({
    int page = 1,
    int limit = 50,
    String? targetSystem,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/outbox/dlq',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (targetSystem != null) 'target_system': targetSystem,
        },
      ),
      endpoint: '/api/admin/outbox/dlq',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin failed assessments (paginated).
  Future<Map<String, dynamic>> getAdminFailedAssessments({
    int page = 1,
    int limit = 50,
    String? reportId,
    String? toolName,
    bool? permanentDlq,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/failed-assessments',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (reportId != null) 'report_id': reportId,
          if (toolName != null) 'tool_name': toolName,
          if (permanentDlq != null) 'permanent_dlq': permanentDlq.toString(),
        },
      ),
      endpoint: '/api/admin/failed-assessments',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Generates an RT/RW verification token for a report.
  Future<Map<String, dynamic>> getAdminGenerateRtRwToken({
    required String reportId,
    required String rtRwUserId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/admin/generate-rt-rw-token',
        data: {'report_id': reportId, 'rt_rw_user_id': rtRwUserId},
      ),
      endpoint: '/api/admin/generate-rt-rw-token',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Retries a batch of failed assessments.
  Future<Map<String, dynamic>> retryAdminFailedAssessmentsBatch({
    required List<String> ids,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/admin/failed-assessments/retry-batch',
        data: {'ids': ids},
      ),
      endpoint: '/api/admin/failed-assessments/retry-batch',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Outbox ────────────────────────────────────────────────────────────────

  /// Fetches the outbox entry list with pagination and filters.
  ///
  /// [status] - Filter by status (e.g. 'pending', 'failed', 'sent', 'dead_letter').
  /// [targetSystem] - Filter by target system (e.g. 'sipd', 'satu_data').
  /// [page] - Page number (1-indexed).
  /// [limit] - Number of items per page.
  Future<Map<String, dynamic>> getOutboxList({
    String? status,
    String? targetSystem,
    int page = 1,
    int limit = 50,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/outbox/',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
          if (targetSystem != null && targetSystem.isNotEmpty)
            'target_system': targetSystem,
        },
      ),
      endpoint: '/api/outbox/',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Retries a specific outbox entry by ID.
  ///
  /// Resets the entry status to 'pending' and increments the retry count.
  Future<Map<String, dynamic>> retryOutboxEntry(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/outbox/$id/retry'),
      endpoint: '/api/outbox/$id/retry',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Triggers immediate processing of pending outbox entries.
  ///
  /// Only ADMIN and OPERATOR roles can call this.
  Future<Map<String, dynamic>> processOutbox() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/outbox/process'),
      endpoint: '/api/outbox/process',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches the outbox dead-letter queue (DLQ) entries.
  ///
  /// [page] - Page number (1-indexed).
  /// [limit] - Number of items per page.
  /// [targetSystem] - Optional filter by target system.
  Future<Map<String, dynamic>> getOutboxDlq({
    int page = 1,
    int limit = 50,
    String? targetSystem,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/outbox/dlq',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (targetSystem != null && targetSystem.isNotEmpty)
            'target_system': targetSystem,
        },
      ),
      endpoint: '/api/outbox/dlq',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Reconciles stuck outbox entries (resets stuck pending and retryable failed).
  ///
  /// Only ADMIN role can call this.
  Future<Map<String, dynamic>> reconcileOutboxDlq() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/outbox/dlq/reconcile'),
      endpoint: '/api/outbox/dlq/reconcile',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Notifications ──────────────────────────────────────────────────────────

  /// Fetches notifications from the server.
  Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get(
        '/api/notifications',
        queryParameters: {'page': page, 'limit': limit},
      ),
      endpoint: '/api/notifications',
      parse: (data) {
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data.containsKey('entries')) {
          return (data['entries'] as List).cast<Map<String, dynamic>>();
        }
        if (data is Map && data.containsKey('notifications')) {
          return (data['notifications'] as List).cast<Map<String, dynamic>>();
        }
        if (data is Map && data.containsKey('data')) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Marks a notification as read.
  Future<Map<String, dynamic>> markNotificationRead(
    String notificationId,
  ) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/notifications/mark-read',
        data: {'id': notificationId},
      ),
      endpoint: '/api/notifications/mark-read',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Marks all notifications as read.
  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/notifications/mark-read', data: {'mark_all': true}),
      endpoint: '/api/notifications/mark-read',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Supporting Reports ──────────────────────────────────────────────────────

  /// Fetches supporting reports for a given report ID.
  Future<List<Map<String, dynamic>>> getSupportingReports(
    String reportId,
  ) async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/reports/$reportId/supporting'),
      endpoint: '/api/reports/$reportId/supporting',
      parse: (data) {
        if (data is Map && data.containsKey('reports')) {
          return (data['reports'] as List).cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  // ─── Wilayah ────────────────────────────────────────────────────────────────

  /// Fetches the wilayah (region) list.
  Future<List<Map<String, dynamic>>> getWilayahList() async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/wilayah'),
      endpoint: '/api/wilayah',
      parse: (data) {
        if (data is Map && data.containsKey('wilayah')) {
          return (data['wilayah'] as List).cast<Map<String, dynamic>>();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Fetches the boundary geometry for a wilayah as GeoJSON.
  Future<Map<String, dynamic>> getWilayahBoundary(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/wilayah/$id/boundary'),
      endpoint: '/api/wilayah/$id/boundary',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Me ───────────────────────────────────────────────────────────────────

  /// Fetches the current user's data including default wilayah and accessible wilayahs.
  Future<Map<String, dynamic>> getMeData() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/me/data'),
      endpoint: '/api/me/data',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Geocode ────────────────────────────────────────────────────────────────

  /// Fetches reverse geocoded address for given coordinates.
  Future<Map<String, dynamic>> getGeocodeReverse({
    required double lat,
    required double lng,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/geocode/reverse',
        queryParameters: {'lat': lat, 'lng': lng},
      ),
      endpoint: '/api/geocode/reverse',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Public ────────────────────────────────────────────────────────────────

  /// Fetches public GeoJSON for the map (generalized coordinates).
  Future<Map<String, dynamic>> getPublicGeojson({
    String? status,
    String? categoryId,
    String? bbox,
    String? month,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/public/geojson',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (bbox != null) 'bbox': bbox,
          if (month != null) 'month': month,
        },
      ),
      endpoint: '/api/public/geojson',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches public reports GeoJSON for the map (coarsened coordinates).
  Future<Map<String, dynamic>> getPublicReportsGeojson({
    String? status,
    String? categoryId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/public/reports.geojson',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/public/reports.geojson',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches paginated public reports list.
  Future<Map<String, dynamic>> getPublicReports({
    String? status,
    String? categoryId,
    String? bbox,
    String? month,
    int page = 1,
    int limit = 20,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/public/reports',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (bbox != null) 'bbox': bbox,
          if (month != null) 'month': month,
        },
      ),
      endpoint: '/api/public/reports',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Submits an anonymous warga report (no auth required).
  ///
  /// POST /api/public/anonymous-reports
  ///
  /// Returns the created report's [AnonymousReportResult].
  Future<AnonymousReportResult> submitAnonymousReport({
    required String idempotencyKey,
    required String deviceId,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? title,
    List<String>? photos,
    String? captchaToken,
  }) async {
    await _checkConnectivity();
    try {
      final Map<String, dynamic> body = {
        'idempotency_key': idempotencyKey,
        'device_id': deviceId,
        'category_id': categoryId,
        'description': description,
        'lat': lat,
        'lng': lng,
        if (title != null) 'title': title,
        if (captchaToken != null) 'captcha_token': captchaToken,
      };

      Response<Map<String, dynamic>> res;
      if (photos != null && photos.isNotEmpty) {
        final formData = FormData.fromMap({...body, 'photos': photos});
        res = await _publicDio.post(
          '/api/public/anonymous-reports',
          data: formData,
        );
      } else {
        res = await _publicDio.post(
          '/api/public/anonymous-reports',
          data: body,
        );
      }
      return AnonymousReportResult.fromJson(res.data!);
    } on DioException catch (e) {
      final userMessage = extractErrorMessage(e);
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        body: e.response?.data?.toString(),
        endpoint: '/api/public/anonymous-reports',
        userMessage: userMessage,
      );
    }
  }

  /// Fetches public reports GeoJSON for map clustering.
  Future<Map<String, dynamic>> getPublicReportsCluster({
    String? status,
    String? categoryId,
  }) async {
    return getPublicReportsGeojson(status: status, categoryId: categoryId);
  }

  /// Fetches a single public report by ID.
  Future<Map<String, dynamic>> getPublicCase(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/public/reports/$id'),
      endpoint: '/api/public/reports/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches the public categories list.
  Future<List<Map<String, dynamic>>> getPublicCategories() async {
    return await _execute<List<Map<String, dynamic>>>(
      dioCall: () => _dio.get('/api/public/categories'),
      endpoint: '/api/public/categories',
      parse: (data) =>
          (data['categories'] as List).cast<Map<String, dynamic>>(),
    );
  }

  /// Fetches public statistics.
  Future<Map<String, dynamic>> getPublicStats() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/public/stats'),
      endpoint: '/api/public/stats',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches public sync KPI data.
  Future<Map<String, dynamic>> getPublicSyncKpi() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/public/sync-kpi'),
      endpoint: '/api/public/sync-kpi',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Posts device sync KPI data.
  Future<Map<String, dynamic>> postPublicSyncKpi({
    required String deviceId,
    required String platform,
    required int reportsCount,
    String? lastSyncAt,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post(
        '/api/public/sync-kpi',
        data: {
          'device_id': deviceId,
          'platform': platform,
          'reports_count': reportsCount,
          if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
        },
      ),
      endpoint: '/api/public/sync-kpi',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Auditor ────────────────────────────────────────────────────────────────

  /// Fetches auditor audit search results with pagination and filters.
  ///
  /// Query params: actor_id, action, object_type, object_id, from, to, page, limit.
  /// Returns: { entries: [...], total, page, limit }
  Future<Map<String, dynamic>> getAuditorAuditSearch({
    String? actorId,
    String? action,
    String? objectType,
    String? objectId,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/auditor/audit-search',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (actorId != null && actorId.isNotEmpty) 'actor_id': actorId,
          if (action != null && action.isNotEmpty) 'action': action,
          if (objectType != null && objectType.isNotEmpty)
            'object_type': objectType,
          if (objectId != null && objectId.isNotEmpty) 'object_id': objectId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/auditor/audit-search',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Exports auditor audit log as CSV or JSON file content.
  ///
  /// Query params: actor_id, action, object_type, object_id, from, to, format.
  /// Returns raw file content as string (caller handles sharing).
  Future<String> getAuditorAuditExport({
    String? actorId,
    String? action,
    String? objectType,
    String? objectId,
    String? from,
    String? to,
    String format = 'csv',
  }) async {
    final res = await _dio.get(
      '/api/auditor/audit-export',
      queryParameters: {
        if (actorId != null && actorId.isNotEmpty) 'actor_id': actorId,
        if (action != null && action.isNotEmpty) 'action': action,
        if (objectType != null && objectType.isNotEmpty)
          'object_type': objectType,
        if (objectId != null && objectId.isNotEmpty) 'object_id': objectId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'format': format,
      },
    );
    return res.data.toString();
  }

  /// Fetches auditor system logs with pagination and filters.
  ///
  /// Query params: level, from, to, page, limit.
  /// Returns: { entries: [...], total, page, limit }
  Future<Map<String, dynamic>> getAuditorSystemLogs({
    String? level,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/auditor/system-logs',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (level != null && level.isNotEmpty) 'level': level,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/auditor/system-logs',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches auditor statistics (counts, top actors, suspicious activity).
  ///
  /// Returns: { counts: { total, last_24h, last_7d, last_30d }, top_actors, failed_attempts, recent_suspicious }
  Future<Map<String, dynamic>> getAuditorStats() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/auditor/stats'),
      endpoint: '/api/auditor/stats',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Executive ──────────────────────────────────────────────────────────────

  /// Fetches the executive dashboard summary (total reports, SLA, staffing, etc.).
  Future<Map<String, dynamic>> getExecutiveDashboard() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/executive/dashboard'),
      endpoint: '/api/executive/dashboard',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches executive regional statistics (by wilayah, by category, staffing).
  Future<Map<String, dynamic>> getExecutiveRegionalStats() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/executive/regional-stats'),
      endpoint: '/api/executive/regional-stats',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches executive trend analysis over a given period.
  ///
  /// [period] - One of 'daily', 'weekly', or 'monthly' (defaults to 'monthly').
  Future<Map<String, dynamic>> getExecutiveTrendAnalysis(String period) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/executive/trend-analysis',
        queryParameters: {'period': period},
      ),
      endpoint: '/api/executive/trend-analysis',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Admin Daerah ──────────────────────────────────────────────────────────

  /// Fetches admin daerah dashboard stats.
  Future<Map<String, dynamic>> getAdminDaerahDashboard() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/admin-daerah/'),
      endpoint: '/api/admin-daerah/',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin daerah case list with pagination and filters.
  Future<Map<String, dynamic>> getAdminDaerahCases({
    int page = 1,
    int limit = 20,
    String? status,
    String? categoryId,
    String? search,
    String? severity,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/cases',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
          if (severity != null) 'severity': severity,
        },
      ),
      endpoint: '/api/admin-daerah/cases',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin daerah operator list with pagination and filters.
  Future<Map<String, dynamic>> getAdminDaerahOperators({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/operators',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/operators',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin daerah petugas list with pagination and filters.
  Future<Map<String, dynamic>> getAdminDaerahPetugas({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/petugas',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/petugas',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin daerah statistics.
  Future<Map<String, dynamic>> getAdminDaerahStats() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/admin-daerah/stats'),
      endpoint: '/api/admin-daerah/stats',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin daerah SLA rules with pagination and filters.
  Future<Map<String, dynamic>> getAdminDaerahSla({
    int page = 1,
    int limit = 20,
    String? kategoriId,
    String? prioritas,
    bool? isActive,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/sla',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (kategoriId != null) 'kategori_id': kategoriId,
          if (prioritas != null) 'prioritas': prioritas,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/sla',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Updates an admin daerah SLA rule.
  Future<Map<String, dynamic>> updateAdminDaerahSla(
    String id, {
    String? kategoriId,
    String? prioritas,
    int? jam,
    bool? isActive,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.put(
        '/api/admin-daerah/sla/$id',
        data: {
          if (kategoriId != null) 'kategori_id': kategoriId,
          if (prioritas != null) 'prioritas': prioritas,
          if (jam != null) 'jam': jam,
          if (isActive != null) 'is_active': isActive,
        },
      ),
      endpoint: '/api/admin-daerah/sla/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches admin daerah units list with pagination and filters.
  Future<Map<String, dynamic>> getAdminDaerahUnits({
    int page = 1,
    int limit = 20,
    String? wilayahId,
    bool? isActive,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/units',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (wilayahId != null) 'wilayah_id': wilayahId,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/units',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Fetches a single admin daerah unit by ID.
  Future<Map<String, dynamic>> getAdminDaerahUnitDetail(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get('/api/admin-daerah/units/$id'),
      endpoint: '/api/admin-daerah/units/$id',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Retries a failed integration outbox entry.
  Future<Map<String, dynamic>> retryAdminDaerahIntegration(String id) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/admin-daerah/integrasi/outbox/$id/retry'),
      endpoint: '/api/admin-daerah/integrasi/outbox/$id/retry',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Reconciles admin daerah integration outbox.
  Future<Map<String, dynamic>> reconcileAdminDaerahIntegration() async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.post('/api/admin-daerah/integrasi/reconcile'),
      endpoint: '/api/admin-daerah/integrasi/reconcile',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  // ─── Audit ──────────────────────────────────────────────────────────────────

  /// Fetches audit log entries with pagination and filters.
  ///
  /// Query params: actor_id, action, report_id, from, to, page, limit.
  /// Returns: { entries: [...], total, page, limit }
  Future<Map<String, dynamic>> getAuditSearch({
    String? actorId,
    String? action,
    String? reportId,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/audit/search',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (actorId != null && actorId.isNotEmpty) 'actor_id': actorId,
          if (action != null && action.isNotEmpty) 'action': action,
          if (reportId != null && reportId.isNotEmpty) 'report_id': reportId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/audit/search',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }

  /// Exports audit log entries as CSV or JSON file content.
  ///
  /// Query params: actor_id, action, report_id, from, to, format.
  /// Returns raw file content as string (caller handles sharing).
  Future<String> getAuditExport({
    String? actorId,
    String? action,
    String? reportId,
    String? from,
    String? to,
    String format = 'csv',
  }) async {
    final res = await _dio.get(
      '/api/audit/export',
      queryParameters: {
        if (actorId != null && actorId.isNotEmpty) 'actor_id': actorId,
        if (action != null && action.isNotEmpty) 'action': action,
        if (reportId != null && reportId.isNotEmpty) 'report_id': reportId,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'format': format,
      },
    );
    return res.data.toString();
  }

  // ─── Export ─────────────────────────────────────────────────────────────────

  /// Exports reports as CSV file content.
  ///
  /// Query params: status, category_id.
  /// Returns raw CSV file content as string (caller handles sharing).
  Future<String> getExportCsv({String? status, String? categoryId}) async {
    final res = await _dio.get(
      '/api/export/csv',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
      },
    );
    return res.data.toString();
  }

  /// Exports reports as GeoJSON FeatureCollection.
  Future<Map<String, dynamic>> getExportGeojson({
    String? status,
    String? categoryId,
  }) async {
    return await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/export/geojson',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
        },
      ),
      endpoint: '/api/export/geojson',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
  }
}
