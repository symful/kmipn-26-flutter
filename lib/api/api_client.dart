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

// ─── Paginated response wrappers ───────────────────────────────────────────

class PaginatedItems<T> {
  final List<T> items;
  final Pagination pagination;
  PaginatedItems({required this.items, required this.pagination});
}

class VerifikatorQueuePage {
  final List<VerifikatorQueueItem> items;
  final Pagination pagination;
  VerifikatorQueuePage({required this.items, required this.pagination});
}

class OperatorPage {
  final List<OperatorCase> items;
  final Pagination pagination;
  OperatorPage({required this.items, required this.pagination});
}

class AuditPage {
  final List<AuditEntry> entries;
  final int total;
  final int page;
  final int limit;
  AuditPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class NotificationPage {
  final List<NotificationEntry> entries;
  NotificationPage({required this.entries});
}

class OutboxPage {
  final List<OutboxEntry> entries;
  final int total;
  final int page;
  final int limit;
  OutboxPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class WargaReportsPage {
  final List<Report> items;
  WargaReportsPage({required this.items});
}

class PetugasTaskPage {
  final List<PetugasTask> tasks;
  PetugasTaskPage({required this.tasks});
}

class SurveyorTaskPage {
  final List<SurveyorTask> tasks;
  SurveyorTaskPage({required this.tasks});
}

class AdminUsersPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminUsersPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminUnitsPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminUnitsPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminChecklistTemplatesPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminChecklistTemplatesPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminPriorityConfigPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminPriorityConfigPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminFailedAssessmentsPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminFailedAssessmentsPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminOutboxPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminOutboxPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminDaerahCasesPage {
  final List<Map<String, dynamic>> items;
  final int total;
  final int page;
  final int limit;
  AdminDaerahCasesPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminDaerahOperatorsPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminDaerahOperatorsPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminDaerahPetugasPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminDaerahPetugasPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminDaerahSlaPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminDaerahSlaPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class AdminDaerahUnitsPage {
  final List<Map<String, dynamic>> entries;
  final int total;
  final int page;
  final int limit;
  AdminDaerahUnitsPage({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });
}

class PublicReportsPage {
  final List<Map<String, dynamic>> items;
  final Pagination pagination;
  PublicReportsPage({required this.items, required this.pagination});
}

class AdminGenerateRtRwTokenResult {
  final String? verificationToken;
  final String? expiresAt;
  AdminGenerateRtRwTokenResult({this.verificationToken, this.expiresAt});

  factory AdminGenerateRtRwTokenResult.fromJson(Map<String, dynamic> json) {
    return AdminGenerateRtRwTokenResult(
      verificationToken: json['verification_token'] as String?,
      expiresAt: json['expires_at'] as String?,
    );
  }
}

class RetryBatchResult {
  final int retried;
  final int failed;
  RetryBatchResult({required this.retried, required this.failed});

  factory RetryBatchResult.fromJson(Map<String, dynamic> json) {
    return RetryBatchResult(
      retried: json['retried'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
    );
  }
}

class VoidResult {}

class MarkNotificationResult {
  final bool success;
  MarkNotificationResult({required this.success});

  factory MarkNotificationResult.fromJson(Map<String, dynamic> json) {
    return MarkNotificationResult(success: json['success'] as bool? ?? true);
  }
}

class ProcessOutboxResult {
  final int processed;
  ProcessOutboxResult({required this.processed});

  factory ProcessOutboxResult.fromJson(Map<String, dynamic> json) {
    return ProcessOutboxResult(processed: json['processed'] as int? ?? 0);
  }
}

class ReconcileResult {
  final int reconciled;
  ReconcileResult({required this.reconciled});

  factory ReconcileResult.fromJson(Map<String, dynamic> json) {
    return ReconcileResult(reconciled: json['reconciled'] as int? ?? 0);
  }
}

class AdminPriorityConfigSaveResult {
  final String? id;
  final int? version;
  AdminPriorityConfigSaveResult({this.id, this.version});

  factory AdminPriorityConfigSaveResult.fromJson(Map<String, dynamic> json) {
    return AdminPriorityConfigSaveResult(
      id: json['id'] as String?,
      version: json['version'] as int?,
    );
  }
}

class AdminDaerahSlaUpdateResult {
  final bool success;
  AdminDaerahSlaUpdateResult({required this.success});

  factory AdminDaerahSlaUpdateResult.fromJson(Map<String, dynamic> json) {
    return AdminDaerahSlaUpdateResult(
      success: json['success'] as bool? ?? true,
    );
  }
}

class AdminDaerahIntegrationRetryResult {
  final bool success;
  AdminDaerahIntegrationRetryResult({required this.success});

  factory AdminDaerahIntegrationRetryResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminDaerahIntegrationRetryResult(
      success: json['success'] as bool? ?? true,
    );
  }
}

class AdminDaerahIntegrationReconcileResult {
  final int reconciled;
  AdminDaerahIntegrationReconcileResult({required this.reconciled});

  factory AdminDaerahIntegrationReconcileResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminDaerahIntegrationReconcileResult(
      reconciled: json['reconciled'] as int? ?? 0,
    );
  }
}

class AiAssessmentResult {
  final double? confidenceScore;
  final List<String>? supportingFactors;
  final List<String>? riskFactors;
  final List<Map<String, dynamic>>? duplicateCandidates;
  AiAssessmentResult({
    this.confidenceScore,
    this.supportingFactors,
    this.riskFactors,
    this.duplicateCandidates,
  });

  factory AiAssessmentResult.fromJson(Map<String, dynamic> json) {
    return AiAssessmentResult(
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      supportingFactors: (json['supporting_factors'] as List?)
          ?.map((e) => e as String)
          .toList(),
      riskFactors: (json['risk_factors'] as List?)
          ?.map((e) => e as String)
          .toList(),
      duplicateCandidates: (json['duplicate_candidates'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }
}

class OperatorQueueCounts {
  final int? newReports;
  final int? slaBreached;
  final int? slaAtRisk;
  final int? inProgress;
  OperatorQueueCounts({
    this.newReports,
    this.slaBreached,
    this.slaAtRisk,
    this.inProgress,
  });

  factory OperatorQueueCounts.fromJson(Map<String, dynamic> json) {
    return OperatorQueueCounts(
      newReports: json['new_reports'] as int?,
      slaBreached: json['sla_breached'] as int?,
      slaAtRisk: json['sla_at_risk'] as int?,
      inProgress: json['in_progress'] as int?,
    );
  }
}

class AuditorSystemLogs {
  final List<AuditEntry> entries;
  final int total;
  final int page;
  final int limit;
  AuditorSystemLogs({
    required this.entries,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory AuditorSystemLogs.fromJson(Map<String, dynamic> json) {
    return AuditorSystemLogs(
      entries:
          (json['entries'] as List?)
              ?.map(
                (e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 50,
    );
  }
}

class AuditorStats {
  final Map<String, dynamic>? counts;
  final List<Map<String, dynamic>>? topActors;
  final List<Map<String, dynamic>>? failedAttempts;
  final List<Map<String, dynamic>>? recentSuspicious;
  AuditorStats({
    this.counts,
    this.topActors,
    this.failedAttempts,
    this.recentSuspicious,
  });

  factory AuditorStats.fromJson(Map<String, dynamic> json) {
    return AuditorStats(
      counts: json['counts'] as Map<String, dynamic>?,
      topActors: (json['top_actors'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      failedAttempts: (json['failed_attempts'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      recentSuspicious: (json['recent_suspicious'] as List?)
          ?.map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
    );
  }
}

class AdminDaerahUnitDetail {
  final String? id;
  final String? name;
  final String? wilayahId;
  final bool? isActive;
  AdminDaerahUnitDetail({this.id, this.name, this.wilayahId, this.isActive});

  factory AdminDaerahUnitDetail.fromJson(Map<String, dynamic> json) {
    return AdminDaerahUnitDetail(
      id: json['id'] as String?,
      name: json['name'] as String?,
      wilayahId: json['wilayah_id'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }
}

class PetugasUploadEvidenceResult {
  final String? evidenceId;
  final List<String>? photoUrls;
  PetugasUploadEvidenceResult({this.evidenceId, this.photoUrls});

  factory PetugasUploadEvidenceResult.fromJson(Map<String, dynamic> json) {
    return PetugasUploadEvidenceResult(
      evidenceId: json['evidence_id'] as String?,
      photoUrls: (json['photo_urls'] as List?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class PetugasCompleteTaskResult {
  final String? taskId;
  final String? status;
  final String? completionProof;
  PetugasCompleteTaskResult({this.taskId, this.status, this.completionProof});

  factory PetugasCompleteTaskResult.fromJson(Map<String, dynamic> json) {
    return PetugasCompleteTaskResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
      completionProof: json['completion_proof'] as String?,
    );
  }
}

class RtRwVerifyResult {
  final String? status;
  final String? reportId;
  RtRwVerifyResult({this.status, this.reportId});

  factory RtRwVerifyResult.fromJson(Map<String, dynamic> json) {
    return RtRwVerifyResult(
      status: json['status'] as String?,
      reportId: json['report_id'] as String?,
    );
  }
}

class SurveyorAcceptResult {
  final String? taskId;
  final String? status;
  SurveyorAcceptResult({this.taskId, this.status});

  factory SurveyorAcceptResult.fromJson(Map<String, dynamic> json) {
    return SurveyorAcceptResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class SurveyorStartResult {
  final String? taskId;
  final String? status;
  SurveyorStartResult({this.taskId, this.status});

  factory SurveyorStartResult.fromJson(Map<String, dynamic> json) {
    return SurveyorStartResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class SurveyorRejectResult {
  final String? taskId;
  final String? status;
  SurveyorRejectResult({this.taskId, this.status});

  factory SurveyorRejectResult.fromJson(Map<String, dynamic> json) {
    return SurveyorRejectResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class ClarificationResult {
  final String? clarificationId;
  final String? status;
  ClarificationResult({this.clarificationId, this.status});

  factory ClarificationResult.fromJson(Map<String, dynamic> json) {
    return ClarificationResult(
      clarificationId: json['clarification_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class PetugasAcceptResult {
  final String? taskId;
  final String? status;
  PetugasAcceptResult({this.taskId, this.status});

  factory PetugasAcceptResult.fromJson(Map<String, dynamic> json) {
    return PetugasAcceptResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class PetugasRejectResult {
  final String? taskId;
  final String? status;
  PetugasRejectResult({this.taskId, this.status});

  factory PetugasRejectResult.fromJson(Map<String, dynamic> json) {
    return PetugasRejectResult(
      taskId: json['task_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class PetugasUpdateProgressResult {
  final String? taskId;
  final int? progressPercent;
  PetugasUpdateProgressResult({this.taskId, this.progressPercent});

  factory PetugasUpdateProgressResult.fromJson(Map<String, dynamic> json) {
    return PetugasUpdateProgressResult(
      taskId: json['task_id'] as String?,
      progressPercent: json['progress_percent'] as int?,
    );
  }
}

class SanggahanResult {
  final String? status;
  SanggahanResult({this.status});

  factory SanggahanResult.fromJson(Map<String, dynamic> json) {
    return SanggahanResult(status: json['status'] as String?);
  }
}

class ReopenResult {
  final String? status;
  ReopenResult({this.status});

  factory ReopenResult.fromJson(Map<String, dynamic> json) {
    return ReopenResult(status: json['status'] as String?);
  }
}

class ValidationResult {
  final bool valid;
  final String? role;
  ValidationResult({required this.valid, this.role});

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      valid: json['valid'] as bool? ?? false,
      role: json['role'] as String?,
    );
  }
}

class GeocodeResult {
  final String? address;
  final String? district;
  final String? city;
  GeocodeResult({this.address, this.district, this.city});

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    return GeocodeResult(
      address: json['address'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
    );
  }
}

class SupportingReportsResult {
  final List<Report> reports;
  SupportingReportsResult({required this.reports});
}

class WilayahBoundaryResult {
  final GeoJSONFeatureCollection? boundary;
  WilayahBoundaryResult({this.boundary});

  factory WilayahBoundaryResult.fromJson(Map<String, dynamic> json) {
    return WilayahBoundaryResult(
      boundary: json['boundary'] != null
          ? GeoJSONFeatureCollection.fromJson(
              json['boundary'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class MergeOperatorResult {
  final String? caseId;
  final String? status;
  MergeOperatorResult({this.caseId, this.status});

  factory MergeOperatorResult.fromJson(Map<String, dynamic> json) {
    return MergeOperatorResult(
      caseId: json['case_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class SeparateOperatorResult {
  final List<String>? newCaseIds;
  final String? status;
  SeparateOperatorResult({this.newCaseIds, this.status});

  factory SeparateOperatorResult.fromJson(Map<String, dynamic> json) {
    return SeparateOperatorResult(
      newCaseIds: (json['new_case_ids'] as List?)
          ?.map((e) => e as String)
          .toList(),
      status: json['status'] as String?,
    );
  }
}

class SetPriorityResult {
  final String? caseId;
  final int? newScore;
  SetPriorityResult({this.caseId, this.newScore});

  factory SetPriorityResult.fromJson(Map<String, dynamic> json) {
    return SetPriorityResult(
      caseId: json['case_id'] as String?,
      newScore: json['new_score'] as int?,
    );
  }
}

class AssignOperatorResult {
  final String? caseId;
  final String? status;
  AssignOperatorResult({this.caseId, this.status});

  factory AssignOperatorResult.fromJson(Map<String, dynamic> json) {
    return AssignOperatorResult(
      caseId: json['case_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class EscalateOperatorResult {
  final String? caseId;
  final String? status;
  EscalateOperatorResult({this.caseId, this.status});

  factory EscalateOperatorResult.fromJson(Map<String, dynamic> json) {
    return EscalateOperatorResult(
      caseId: json['case_id'] as String?,
      status: json['status'] as String?,
    );
  }
}

class SetSlaResult {
  final String? caseId;
  final String? newDeadline;
  SetSlaResult({this.caseId, this.newDeadline});

  factory SetSlaResult.fromJson(Map<String, dynamic> json) {
    return SetSlaResult(
      caseId: json['case_id'] as String?,
      newDeadline: json['new_deadline'] as String?,
    );
  }
}

class OutboxRetryResult {
  final bool success;
  OutboxRetryResult({required this.success});

  factory OutboxRetryResult.fromJson(Map<String, dynamic> json) {
    return OutboxRetryResult(success: json['success'] as bool? ?? true);
  }
}

// ─── API Client ───────────────────────────────────────────────────────────────

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
    String? testAccessToken,
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
          testAccessToken: testAccessToken,
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

  /// Enforces that the response contains the required envelope key.
  /// Throws FormatException if the key is missing.
  Map<String, dynamic> _expectKey(Map<String, dynamic> data, String key) {
    if (!data.containsKey(key)) {
      throw FormatException(
        'Unexpected response shape at: expected "$key" key',
      );
    }
    return data;
  }

  /// Enforces that the response is a list under the given key.
  /// Throws FormatException if the key is missing or data is not a list.
  List<dynamic> _expectListKey(Map<String, dynamic> data, String key) {
    if (!data.containsKey(key)) {
      throw FormatException(
        'Unexpected response shape at: expected "$key" key',
      );
    }
    final value = data[key];
    if (value is! List) {
      throw FormatException(
        'Unexpected response shape at: expected "$key" to be a list',
      );
    }
    return value;
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

  Future<EvidenceResult> uploadSinglePhoto(
    String path, {
    required String description,
    required String photoPath,
  }) async {
    final file = File(photoPath);
    final bytes = await file.readAsBytes();
    final name = photoPath.split('/').last;
    final formData = FormData.fromMap({
      'description': description,
      'photo': MultipartFile.fromBytes(bytes, filename: name),
    });
    return await _execute<EvidenceResult>(
      dioCall: () => _dio.post(path, data: formData),
      endpoint: path,
      parse: (data) => EvidenceResult.fromJson(
        _expectKey((data as Map).cast<String, dynamic>(), 'result'),
      ),
    );
  }

  Future<EvidenceResult> uploadPhotoBytes(
    String url,
    List<int> bytes,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'photo': MultipartFile.fromBytes(bytes, filename: filename),
    });
    return await _execute<EvidenceResult>(
      dioCall: () => _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      ),
      endpoint: url,
      parse: (data) => EvidenceResult.fromJson(
        _expectKey((data as Map).cast<String, dynamic>(), 'result'),
      ),
    );
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

  /// Logs in a user with email and password.
  /// Returns a [LoginResponse] containing access_token, refresh_token, and user data.
  Future<LoginResponse> login(String email, String password) async {
    return await _execute<LoginResponse>(
      dioCall: () => _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/auth/login',
      parse: (data) =>
          LoginResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Logs out a user by invalidating the refresh token.
  Future<void> logout(String refreshToken) async {
    await _execute<void>(
      dioCall: () =>
          _dio.post('/api/auth/logout', data: {'refresh_token': refreshToken}),
      endpoint: '/api/auth/logout',
      parse: (_) {},
    );
  }

  // ─── Categories ────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final data = _expectListKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/categories'),
        endpoint: '/api/categories',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'categories',
    );
    return data
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // ─── Reports ───────────────────────────────────────────────────────────────

  /// Fetches a single report by ID from the API.
  Future<Report> getReportById(String id) async {
    return await _execute<Report>(
      dioCall: () => _dio.get('/api/reports/$id'),
      endpoint: '/api/reports/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Updates a report via PATCH /api/reports/:id.
  ///
  /// [data] can include: status, description, priority (severity), assigned_to.
  Future<Report> updateReport(String id, Map<String, dynamic> data) async {
    return await _execute<Report>(
      dioCall: () => _dio.patch('/api/reports/$id', data: data),
      endpoint: '/api/reports/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
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

  /// Uploads a photo via presigned URL (anonymous warga flow).
  /// Returns the public URL of the uploaded photo.
  Future<String> uploadReportPhotoAnon({
    required String filePath,
    required String idempotencyKey,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    // Step 1: Get presigned URL from the API
    final urlRes = await _dio.post(
      '/api/reports/photos/upload-url-anon',
      data: {'content_type': 'image/jpeg', 'idempotency_key': idempotencyKey},
    );

    final uploadUrl = urlRes.data['upload_url'] as String;
    final publicUrl = urlRes.data['public_url'] as String;

    // Step 2: PUT bytes directly to presigned URL (no auth needed)
    final uploadDio = Dio();
    await uploadDio.put(
      uploadUrl,
      data: bytes,
      options: Options(headers: {'Content-Type': 'image/jpeg'}),
    );

    return publicUrl;
  }

  Future<Report> createReport({
    required String idempotencyKey,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? deviceId,
    String? title,
    List<String>? photoPaths,
  }) async {
    // Upload photos first via presigned URL if provided
    List<String>? photoUrls;
    if (photoPaths != null && photoPaths.isNotEmpty) {
      photoUrls = [];
      for (final path in photoPaths) {
        final publicUrl = await uploadReportPhotoAnon(
          filePath: path,
          idempotencyKey: '${idempotencyKey}_photo_${photoUrls.length}',
        );
        photoUrls.add(publicUrl);
      }
    }

    return await _execute<Report>(
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
          if (photoUrls != null && photoUrls.isNotEmpty)
            'photo_urls': photoUrls,
        },
      ),
      endpoint: '/api/reports',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<SyncBatchResult> syncBatch({
    required List<Map<String, dynamic>> reports,
    String? deviceId,
  }) async {
    return await _execute<SyncBatchResult>(
      dioCall: () => _dio.post(
        '/api/sync/batch',
        data: {if (deviceId != null) 'device_id': deviceId, 'reports': reports},
      ),
      endpoint: '/api/sync/batch',
      parse: (data) =>
          SyncBatchResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── AI Assessment ─────────────────────────────────────────────────────────

  /// Fetches AI pre-verification assessment for a report.
  ///
  /// Returns assessment data including confidence score, supporting factors,
  /// risk factors, and duplicate candidates. Returns an empty map if no
  /// assessment is available.
  Future<AiAssessmentResult> getAiAssessment(String reportId) async {
    return await _execute<AiAssessmentResult>(
      dioCall: () => _dio.get('/api/agent/assessments/$reportId'),
      endpoint: '/api/agent/assessments/$reportId',
      parse: (data) {
        if (data is Map) {
          return AiAssessmentResult.fromJson(data.cast<String, dynamic>());
        }
        return AiAssessmentResult();
      },
    );
  }

  // ─── Verifikator ───────────────────────────────────────────────────────────

  /// Fetches the verifikator queue (list of cases pending review).
  Future<VerifikatorQueuePage> getVerifikatorQueue({
    String? status,
    int page = 1,
    int limit = 20,
    String? kategori,
  }) async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get(
          '/api/verifikator/queue',
          queryParameters: {
            'page': page,
            'limit': limit,
            if (status != null) 'status': status,
            if (kategori != null) 'kategori': kategori,
          },
        ),
        endpoint: '/api/verifikator/queue',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'items',
    );
    final paginationData = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get(
          '/api/verifikator/queue',
          queryParameters: {
            'page': page,
            'limit': limit,
            if (status != null) 'status': status,
            if (kategori != null) 'kategori': kategori,
          },
        ),
        endpoint: '/api/verifikator/queue',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'pagination',
    );
    return VerifikatorQueuePage(
      items: (data as List)
          .map(
            (e) => VerifikatorQueueItem.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
      pagination: Pagination.fromJson(paginationData),
    );
  }

  /// Fetches a single verifikator case by ID.
  Future<VerifikatorCase> getVerifikatorCase(String caseId) async {
    return await _execute<VerifikatorCase>(
      dioCall: () => _dio.get('/api/verifikator/cases/$caseId'),
      endpoint: '/api/verifikator/cases/$caseId',
      parse: (data) =>
          VerifikatorCase.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Accepts a verifikator case (transitions to verified).
  Future<VerifikatorCase> acceptVerifikatorCase(
    String caseId, {
    String? reason,
    String? assignedUnitId,
    String? deadline,
    int? priority,
  }) async {
    return await _execute<VerifikatorCase>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/accept',
        data: {
          if (reason != null) 'reason': reason,
          if (assignedUnitId != null) 'assigned_unit_id': assignedUnitId,
          if (deadline != null) 'deadline': deadline,
          if (priority != null) 'priority': priority,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/verifikator/cases/$caseId/accept',
      parse: (data) =>
          VerifikatorCase.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Combines/merges a verifikator case into another case.
  Future<VerifikatorCase> combineVerifikatorCase(
    String caseId, {
    required String targetCaseId,
    String? reason,
  }) async {
    return await _execute<VerifikatorCase>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/combine',
        data: {
          'target_case_id': targetCaseId,
          if (reason != null) 'reason': reason,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/combine',
      parse: (data) =>
          VerifikatorCase.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Separates a verifikator case into a new case.
  Future<VerifikatorCase> separateVerifikatorCase(
    String caseId, {
    required String newCaseDescription,
    String? reason,
  }) async {
    return await _execute<VerifikatorCase>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/separate',
        data: {
          'new_case_description': newCaseDescription,
          if (reason != null) 'reason': reason,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/separate',
      parse: (data) =>
          VerifikatorCase.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Rejects a verifikator case.
  Future<VerifikatorCase> rejectVerifikatorCase(
    String caseId, {
    required String reason,
  }) async {
    return await _execute<VerifikatorCase>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/reject',
        data: {'reason': reason},
      ),
      endpoint: '/api/verifikator/cases/$caseId/reject',
      parse: (data) =>
          VerifikatorCase.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Makes a decision on a verifikator case.
  Future<DecideResult> decideVerifikatorCase({
    required String caseId,
    required String decision,
    required String reason,
    String? duplicateOfReportId,
    String? surveyorId,
    String? assignedUnitId,
    String? deadline,
  }) async {
    return await _execute<DecideResult>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/decide',
        data: {
          'decision': decision,
          'reason': reason,
          if (duplicateOfReportId != null)
            'duplicate_of_report_id': duplicateOfReportId,
          if (surveyorId != null) 'surveyor_id': surveyorId,
          if (assignedUnitId != null) 'assigned_unit_id': assignedUnitId,
          if (deadline != null) 'deadline': deadline,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/decide',
      parse: (data) =>
          DecideResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Alias for [decideVerifikatorCase] for backward compatibility.
  Future<DecideResult> verifikatorDecide({
    required String caseId,
    required String decision,
    required String reason,
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
  Future<VerifikatorCase> reviewSanggahan(
    String caseId, {
    required String decision,
    required String reason,
  }) async {
    return await _execute<VerifikatorCase>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/review-sanggahan',
        data: {'decision': decision, 'reason': reason},
      ),
      endpoint: '/api/verifikator/cases/$caseId/review-sanggahan',
      parse: (data) =>
          VerifikatorCase.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Verifies completion of a verifikator case.
  Future<VerifikatorCase> verifyCompletion(
    String caseId, {
    required String decision,
    required String reason,
    String? completionNotes,
  }) async {
    return await _execute<VerifikatorCase>(
      dioCall: () => _dio.post(
        '/api/verifikator/cases/$caseId/verify-completion',
        data: {
          'decision': decision,
          'reason': reason,
          if (completionNotes != null) 'completion_notes': completionNotes,
        },
      ),
      endpoint: '/api/verifikator/cases/$caseId/verify-completion',
      parse: (data) =>
          VerifikatorCase.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<RtRwVerifyResult> rtRwVerify({
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
    if (reason != null) {
      mapData['reason'] = reason;
    }
    if (photoPath != null) {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      final name = photoPath.split('/').last;
      mapData['photo'] = MultipartFile.fromBytes(bytes, filename: name);
    }
    final formData = FormData.fromMap(mapData);
    return await _execute<RtRwVerifyResult>(
      dioCall: () => _dio.post('/api/rt-rw/verify', data: formData),
      endpoint: '/api/rt-rw/verify',
      parse: (data) =>
          RtRwVerifyResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Petugas ───────────────────────────────────────────────────────────────

  Future<PetugasAcceptResult> petugasAcceptTask(String taskId) async {
    return await _execute<PetugasAcceptResult>(
      dioCall: () => _dio.post(
        '/api/petugas/tasks/$taskId/accept',
        data: {},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/petugas/tasks/$taskId/accept',
      parse: (data) =>
          PetugasAcceptResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<PetugasRejectResult> petugasRejectTask(
    String taskId,
    String reason,
  ) async {
    return await _execute<PetugasRejectResult>(
      dioCall: () => _dio.post(
        '/api/petugas/tasks/$taskId/reject',
        data: {'reason': reason},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/petugas/tasks/$taskId/reject',
      parse: (data) =>
          PetugasRejectResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<PetugasUpdateProgressResult> petugasUpdateProgress({
    required String taskId,
    required int progressPercent,
    String? notes,
    String? estimatedCompletion,
  }) async {
    return await _execute<PetugasUpdateProgressResult>(
      dioCall: () => _dio.patch(
        '/api/petugas/tasks/$taskId/progress',
        data: {
          'progress_percent': progressPercent,
          if (notes != null) 'notes': notes,
          if (estimatedCompletion != null)
            'estimated_completion': estimatedCompletion,
        },
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/petugas/tasks/$taskId/progress',
      parse: (data) => PetugasUpdateProgressResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  Future<PetugasUploadEvidenceResult> petugasUploadEvidence(
    String taskId,
    List<String> photoPaths, {
    String? notes,
  }) async {
    final mapData = <String, dynamic>{if (notes != null) 'notes': notes};
    for (var i = 0; i < photoPaths.length; i++) {
      final file = File(photoPaths[i]);
      final bytes = await file.readAsBytes();
      final name = photoPaths[i].split('/').last;
      mapData['photos[$i]'] = MultipartFile.fromBytes(bytes, filename: name);
    }
    final formData = FormData.fromMap(mapData);
    final result = await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/petugas/tasks/$taskId/evidence', data: formData),
      endpoint: '/api/petugas/tasks/$taskId/evidence',
      parse: (data) =>
          _expectKey((data as Map).cast<String, dynamic>(), 'result'),
    );
    return PetugasUploadEvidenceResult.fromJson(result);
  }

  Future<PetugasCompleteTaskResult> petugasCompleteTask(
    String taskId, {
    required String summary,
    required List<String> photoPaths,
  }) async {
    final mapData = <String, dynamic>{'summary': summary};
    for (var i = 0; i < photoPaths.length; i++) {
      final file = File(photoPaths[i]);
      final bytes = await file.readAsBytes();
      final name = photoPaths[i].split('/').last;
      mapData['photos[$i]'] = MultipartFile.fromBytes(bytes, filename: name);
    }
    final formData = FormData.fromMap(mapData);
    final result = await _execute<Map<String, dynamic>>(
      dioCall: () =>
          _dio.post('/api/petugas/tasks/$taskId/complete', data: formData),
      endpoint: '/api/petugas/tasks/$taskId/complete',
      parse: (data) =>
          _expectKey((data as Map).cast<String, dynamic>(), 'result'),
    );
    return PetugasCompleteTaskResult.fromJson(result);
  }

  Future<ClarificationResult> petugasRequestClarification(
    String taskId, {
    required String question,
  }) async {
    return await _execute<ClarificationResult>(
      dioCall: () => _dio.post(
        '/api/petugas/tasks/$taskId/clarification',
        data: {'question': question},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/petugas/tasks/$taskId/clarification',
      parse: (data) =>
          ClarificationResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<PetugasTaskPage> petugasGetTasks() async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/petugas/tasks'),
        endpoint: '/api/petugas/tasks',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'tasks',
    );
    return PetugasTaskPage(
      tasks: (data as List)
          .map((e) => PetugasTask.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<PetugasTaskDetail> getPetugasTaskDetail(String taskId) async {
    return await _execute<PetugasTaskDetail>(
      dioCall: () => _dio.get('/api/petugas/tasks/$taskId'),
      endpoint: '/api/petugas/tasks/$taskId',
      parse: (data) =>
          PetugasTaskDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Surveyor ──────────────────────────────────────────────────────────────

  Future<SurveyorTaskPage> surveyorGetTasks() async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/surveyor/tasks'),
        endpoint: '/api/surveyor/tasks',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'tasks',
    );
    return SurveyorTaskPage(
      tasks: (data as List)
          .map((e) => SurveyorTask.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<SurveyorTaskDetail> surveyorGetTaskDetail(String taskId) async {
    return await _execute<SurveyorTaskDetail>(
      dioCall: () => _dio.get('/api/surveyor/tasks/$taskId'),
      endpoint: '/api/surveyor/tasks/$taskId',
      parse: (data) =>
          SurveyorTaskDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches the checklist template for a surveyor task.
  Future<ChecklistTemplate> getSurveyorChecklistTemplate(String taskId) async {
    return await _execute<ChecklistTemplate>(
      dioCall: () => _dio.get('/api/surveyor/tasks/$taskId/checklist-template'),
      endpoint: '/api/surveyor/tasks/$taskId/checklist-template',
      parse: (data) =>
          ChecklistTemplate.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<VisitResult> surveyorSubmitVisit(
    String taskId,
    Map<String, dynamic> visitData,
  ) async {
    return await _execute<VisitResult>(
      dioCall: () =>
          _dio.post('/api/surveyor/tasks/$taskId/visit', data: visitData),
      endpoint: '/api/surveyor/tasks/$taskId/visit',
      parse: (data) =>
          VisitResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Submits a structured visit report for a surveyor task.
  ///
  /// [taskId] - The surveyor task ID
  /// [findings] - Survey findings summary text (required, non-empty)
  /// [checklist] - List of checklist items (required, non-empty)
  /// [photoUrls] - List of photo URLs after presigned upload
  /// [gpsLat] - GPS latitude coordinate
  /// [gpsLng] - GPS longitude coordinate
  /// [accuracy] - GPS accuracy in meters
  /// [conditionAssessment] - Condition assessment: 'ringan', 'berat', or 'kritis'
  /// [recommendation] - Recommendation: 'valid_needs_followup' or 'not_found'
  /// [catatan] - Additional notes text (optional)
  ///
  /// Throws [ArgumentError] if findings, checklist, or gps coordinates are empty.
  Future<VisitResult> submitVisitReport({
    required String taskId,
    required String findings,
    required List<Map<String, dynamic>> checklist,
    required List<String> photoUrls,
    required double gpsLat,
    required double gpsLng,
    required double accuracy,
    required String conditionAssessment,
    required String recommendation,
    String? catatan,
  }) async {
    if (findings.isEmpty) {
      throw ArgumentError('submitVisitReport requires non-empty findings');
    }
    if (checklist.isEmpty) {
      throw ArgumentError('submitVisitReport requires non-empty checklist');
    }
    if (gpsLat == 0 && gpsLng == 0) {
      throw ArgumentError(
        'submitVisitReport requires valid GPS coordinates (gpsLat, gpsLng)',
      );
    }

    return await _execute<VisitResult>(
      dioCall: () => _dio.post(
        '/api/surveyor/tasks/$taskId/visit',
        data: {
          'findings': findings,
          'checklist': checklist,
          'photo_urls': photoUrls,
          'condition_assessment': conditionAssessment,
          'recommendation': recommendation,
          'gps': {'lat': gpsLat, 'lng': gpsLng, 'accuracy_m': accuracy},
          if (catatan != null && catatan.isNotEmpty) 'notes': catatan,
        },
      ),
      endpoint: '/api/surveyor/tasks/$taskId/visit',
      parse: (data) =>
          VisitResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<SurveyorAcceptResult> surveyorAcceptTask(String taskId) async {
    return await _execute<SurveyorAcceptResult>(
      dioCall: () => _dio.post('/api/surveyor/tasks/$taskId/accept'),
      endpoint: '/api/surveyor/tasks/$taskId/accept',
      parse: (data) =>
          SurveyorAcceptResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<SurveyorStartResult> surveyorStartTask(String taskId) async {
    return await _execute<SurveyorStartResult>(
      dioCall: () => _dio.post('/api/surveyor/tasks/$taskId/start'),
      endpoint: '/api/surveyor/tasks/$taskId/start',
      parse: (data) =>
          SurveyorStartResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<SurveyorRejectResult> surveyorRejectTask(
    String taskId,
    String reason,
  ) async {
    return await _execute<SurveyorRejectResult>(
      dioCall: () => _dio.post(
        '/api/surveyor/tasks/$taskId/reject',
        data: {'reason': reason},
      ),
      endpoint: '/api/surveyor/tasks/$taskId/reject',
      parse: (data) =>
          SurveyorRejectResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<ClarificationResult> surveyorRequestClarification(
    String taskId, {
    required String question,
  }) async {
    return await _execute<ClarificationResult>(
      dioCall: () => _dio.post(
        '/api/surveyor/tasks/$taskId/clarification',
        data: {'question': question},
      ),
      endpoint: '/api/surveyor/tasks/$taskId/clarification',
      parse: (data) =>
          ClarificationResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Warga ─────────────────────────────────────────────────────────────────

  Future<SanggahanResult> wargaFileSanggahan({
    required String reportId,
    required String reason,
  }) async {
    return await _execute<SanggahanResult>(
      dioCall: () =>
          _dio.post('/api/warga/sanggahan/$reportId', data: {'reason': reason}),
      endpoint: '/api/warga/sanggahan/$reportId',
      parse: (data) =>
          SanggahanResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<ReopenResult> wargaRequestReopen({
    required String reportId,
    required String reason,
  }) async {
    return await _execute<ReopenResult>(
      dioCall: () =>
          _dio.post('/api/warga/reopen/$reportId', data: {'reason': reason}),
      endpoint: '/api/warga/reopen/$reportId',
      parse: (data) =>
          ReopenResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<List<EvidenceResult>> wargaSubmitEvidence({
    required String reportId,
    required String description,
    required List<String> photoPaths,
  }) async {
    final results = <EvidenceResult>[];
    for (final photoPath in photoPaths) {
      final result = await uploadSinglePhoto(
        '/api/warga/evidence/$reportId',
        description: description,
        photoPath: photoPath,
      );
      results.add(result);
    }
    return results;
  }

  Future<WargaReportsPage> getWargaReports() async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/reports?creator_id=me'),
        endpoint: '/api/reports?creator_id=me',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'items',
    );
    return WargaReportsPage(
      items: (data as List)
          .map((e) => Report.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<ValidationResult> validateRole(String role) async {
    return await _execute<ValidationResult>(
      dioCall: () =>
          _dio.get('/api/auth/validate-role', queryParameters: {'role': role}),
      endpoint: '/api/auth/validate-role',
      parse: (data) =>
          ValidationResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Warga Stats & Nearby ──────────────────────────────────────────────────

  /// Fetches warga statistics (submitted, verified, in_progress, resolved counts).
  Future<WargaStats> getWargaStats() async {
    return await _execute<WargaStats>(
      dioCall: () => _dio.get('/api/warga/stats'),
      endpoint: '/api/warga/stats',
      parse: (data) =>
          WargaStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches nearby reports based on user location.
  Future<List<NearbyReport>> getNearbyReports({
    required double lat,
    required double lng,
  }) async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get(
          '/api/reports/nearby',
          queryParameters: {'lat': lat, 'lng': lng},
        ),
        endpoint: '/api/reports/nearby',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'reports',
    );
    return (data as List)
        .map((e) => NearbyReport.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // ─── Duplicate Cases (M-11) ────────────────────────────────────────────────

  /// Fetches duplicate case candidates for a given location and category.
  ///
  /// Used by SimilarCasesBanner during report creation to surface
  /// nearby cases that may be duplicates.
  Future<List<DuplicateCandidate>> getDuplicateCases({
    required double lat,
    required double lng,
    String? categoryId,
  }) async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get(
          '/api/reports/duplicates',
          queryParameters: {
            'lat': lat,
            'lng': lng,
            if (categoryId != null) 'category_id': categoryId,
          },
        ),
        endpoint: '/api/reports/duplicates',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'candidates',
    );
    return (data as List)
        .map(
          (e) =>
              DuplicateCandidate.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  // ─── Report Timeline ─────────────────────────────────────────────────────────

  /// Fetches the timeline/history events for a given report.
  Future<TimelineEnvelope> getReportTimeline(String reportId) async {
    return await _execute<TimelineEnvelope>(
      dioCall: () => _dio.get('/api/reports/$reportId/timeline'),
      endpoint: '/api/reports/$reportId/timeline',
      parse: (data) =>
          TimelineEnvelope.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Export ───────────────────────────────────────────────────────────────

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
  Future<OperatorPage> getOperatorCases({
    int page = 1,
    int limit = 20,
    String? status,
    String? wilayahId,
    String? categoryId,
    String? search,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/operator',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (wilayahId != null) 'wilayah_id': wilayahId,
          if (categoryId != null) 'category_id': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
      endpoint: '/api/operator',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final itemsData = _expectKey(data, 'items');
    final paginationData = _expectKey(data, 'pagination');
    return OperatorPage(
      items: (itemsData as List)
          .map((e) => OperatorCase.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination: Pagination.fromJson(paginationData),
    );
  }

  /// Fetches operator dashboard summary data.
  Future<ExecutiveDashboard> getOperatorDashboard() async {
    return await _execute<ExecutiveDashboard>(
      dioCall: () => _dio.get('/api/operator/dashboard'),
      endpoint: '/api/operator/dashboard',
      parse: (data) =>
          ExecutiveDashboard.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches operator statistics.
  Future<OperatorStats> getOperatorStats() async {
    return await _execute<OperatorStats>(
      dioCall: () => _dio.get('/api/operator/stats'),
      endpoint: '/api/operator/stats',
      parse: (data) =>
          OperatorStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches operator backlog data (daily buckets).
  Future<ReportsStats> getOperatorBacklog({int days = 30}) async {
    return await _execute<ReportsStats>(
      dioCall: () =>
          _dio.get('/api/operator/backlog', queryParameters: {'days': days}),
      endpoint: '/api/operator/backlog',
      parse: (data) =>
          ReportsStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches operator queue counts (new reports, SLA breached, etc).
  Future<OperatorQueueCounts> getOperatorQueueCounts() async {
    return await _execute<OperatorQueueCounts>(
      dioCall: () => _dio.get('/api/operator/queue-counts'),
      endpoint: '/api/operator/queue-counts',
      parse: (data) =>
          OperatorQueueCounts.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Merges multiple cases into one primary case.
  Future<MergeOperatorResult> mergeOperatorCase({
    required String caseId,
    required List<String> targetCaseIds,
    String? reason,
  }) async {
    return await _execute<MergeOperatorResult>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/merge',
        data: {
          'target_case_ids': targetCaseIds,
          if (reason != null) 'reason': reason,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/merge',
      parse: (data) =>
          MergeOperatorResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Separates a case into multiple new cases.
  Future<SeparateOperatorResult> separateOperatorCase({
    required String caseId,
    required List<String> reportIdsToSeparate,
    String? reason,
    String? targetUnitId,
  }) async {
    return await _execute<SeparateOperatorResult>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/separate',
        data: {
          'report_ids_to_separate': reportIdsToSeparate,
          if (reason != null) 'reason': reason,
          if (targetUnitId != null) 'target_unit_id': targetUnitId,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/separate',
      parse: (data) => SeparateOperatorResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Sets override priority score for a case.
  Future<SetPriorityResult> setOperatorPriority({
    required String caseId,
    required int newScore,
    String? reason,
    Map<String, dynamic>? factorBreakdown,
  }) async {
    return await _execute<SetPriorityResult>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/priority',
        data: {
          'new_score': newScore,
          if (reason != null) 'reason': reason,
          if (factorBreakdown != null) 'factor_breakdown': factorBreakdown,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/priority',
      parse: (data) =>
          SetPriorityResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Assigns a case to a unit with optional instructions and deadline.
  Future<AssignOperatorResult> assignOperatorCase({
    required String caseId,
    required String unitId,
    String? instructions,
    String? deadline,
  }) async {
    return await _execute<AssignOperatorResult>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/assign',
        data: {
          'unit_id': unitId,
          if (instructions != null) 'instructions': instructions,
          if (deadline != null) 'deadline': deadline,
        },
      ),
      endpoint: '/api/operator/cases/$caseId/assign',
      parse: (data) =>
          AssignOperatorResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Escalates a case to higher severity/priority.
  Future<EscalateOperatorResult> escalateOperatorCase({
    required String caseId,
    required String reason,
  }) async {
    return await _execute<EscalateOperatorResult>(
      dioCall: () => _dio.post(
        '/api/operator/cases/$caseId/escalate',
        data: {'reason': reason},
      ),
      endpoint: '/api/operator/cases/$caseId/escalate',
      parse: (data) => EscalateOperatorResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Updates the SLA deadline for a case.
  Future<SetSlaResult> setOperatorSla({
    required String caseId,
    required String newDeadline,
    required String reason,
  }) async {
    return await _execute<SetSlaResult>(
      dioCall: () => _dio.patch(
        '/api/operator/cases/$caseId/sla',
        data: {'new_deadline': newDeadline, 'reason': reason},
      ),
      endpoint: '/api/operator/cases/$caseId/sla',
      parse: (data) =>
          SetSlaResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Admin ──────────────────────────────────────────────────────────────────

  /// Fetches admin users list (paginated).
  Future<AdminUsersPage> getAdminUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? search,
    bool? isActive,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final entriesData = _expectKey(data, 'entries');
    return AdminUsersPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches admin units list (paginated).
  Future<AdminUnitsPage> getAdminUnits({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final entriesData = _expectKey(data, 'entries');
    return AdminUnitsPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches admin checklist templates (paginated).
  Future<AdminChecklistTemplatesPage> getAdminChecklistTemplates({
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final entriesData = _expectKey(data, 'entries');
    return AdminChecklistTemplatesPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches admin priority config versions (paginated).
  Future<AdminPriorityConfigPage> getAdminPriorityConfig({
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin/priority-config',
        queryParameters: {'page': page, 'limit': limit},
      ),
      endpoint: '/api/admin/priority-config',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = _expectKey(data, 'entries');
    return AdminPriorityConfigPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Creates a new priority config version.
  Future<AdminPriorityConfigSaveResult> saveAdminPriorityConfig({
    required Map<String, dynamic> weights,
  }) async {
    return await _execute<AdminPriorityConfigSaveResult>(
      dioCall: () =>
          _dio.post('/api/admin/priority-config', data: {'weights': weights}),
      endpoint: '/api/admin/priority-config',
      parse: (data) => AdminPriorityConfigSaveResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches admin outbox dead-letter queue (paginated).
  Future<AdminOutboxPage> getAdminOutbox({
    int page = 1,
    int limit = 50,
    String? targetSystem,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final entriesData = _expectKey(data, 'entries');
    return AdminOutboxPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches admin failed assessments (paginated).
  Future<AdminFailedAssessmentsPage> getAdminFailedAssessments({
    int page = 1,
    int limit = 50,
    String? reportId,
    String? toolName,
    bool? permanentDlq,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final entriesData = _expectKey(data, 'entries');
    return AdminFailedAssessmentsPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Generates an RT/RW verification token for a report.
  Future<AdminGenerateRtRwTokenResult> getAdminGenerateRtRwToken({
    required String reportId,
    required String rtRwUserId,
  }) async {
    return await _execute<AdminGenerateRtRwTokenResult>(
      dioCall: () => _dio.post(
        '/api/admin/generate-rt-rw-token',
        data: {'report_id': reportId, 'rt_rw_user_id': rtRwUserId},
      ),
      endpoint: '/api/admin/generate-rt-rw-token',
      parse: (data) => AdminGenerateRtRwTokenResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Retries a batch of failed assessments.
  Future<RetryBatchResult> retryAdminFailedAssessmentsBatch({
    required List<String> ids,
  }) async {
    return await _execute<RetryBatchResult>(
      dioCall: () => _dio.post(
        '/api/admin/failed-assessments/retry-batch',
        data: {'ids': ids},
      ),
      endpoint: '/api/admin/failed-assessments/retry-batch',
      parse: (data) =>
          RetryBatchResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Outbox ───────────────────────────────────────────────────────────────

  /// Fetches the outbox entry list with pagination and filters.
  ///
  /// [status] - Filter by status (e.g. 'pending', 'failed', 'sent', 'dead_letter').
  /// [targetSystem] - Filter by target system (e.g. 'sipd', 'satu_data').
  /// [page] - Page number (1-indexed).
  /// [limit] - Number of items per page.
  Future<OutboxPage> getOutboxList({
    String? status,
    String? targetSystem,
    int page = 1,
    int limit = 50,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/outbox',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (targetSystem != null) 'target_system': targetSystem,
        },
      ),
      endpoint: '/api/outbox',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = _expectKey(data, 'entries');
    return OutboxPage(
      entries: (entriesData as List)
          .map((e) => OutboxEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Retries a specific outbox entry by ID.
  ///
  /// Resets the entry status to 'pending' and increments the retry count.
  Future<OutboxRetryResult> retryOutboxEntry(String id) async {
    return await _execute<OutboxRetryResult>(
      dioCall: () => _dio.post('/api/outbox/$id/retry'),
      endpoint: '/api/outbox/$id/retry',
      parse: (data) =>
          OutboxRetryResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Triggers immediate processing of pending outbox entries.
  ///
  /// Only ADMIN and OPERATOR roles can call this.
  Future<ProcessOutboxResult> processOutbox() async {
    return await _execute<ProcessOutboxResult>(
      dioCall: () => _dio.post('/api/outbox/process'),
      endpoint: '/api/outbox/process',
      parse: (data) =>
          ProcessOutboxResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches the outbox dead-letter queue (DLQ) entries.
  ///
  /// [page] - Page number (1-indexed).
  /// [limit] - Number of items per page.
  /// [targetSystem] - Optional filter by target system.
  Future<OutboxPage> getOutboxDlq({
    int page = 1,
    int limit = 50,
    String? targetSystem,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/outbox/dlq',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (targetSystem != null) 'target_system': targetSystem,
        },
      ),
      endpoint: '/api/outbox/dlq',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = _expectKey(data, 'entries');
    return OutboxPage(
      entries: (entriesData as List)
          .map((e) => OutboxEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Reconciles stuck outbox entries (resets stuck pending and retryable failed).
  ///
  /// Only ADMIN role can call this.
  Future<ReconcileResult> reconcileOutboxDlq() async {
    return await _execute<ReconcileResult>(
      dioCall: () => _dio.post('/api/outbox/dlq/reconcile'),
      endpoint: '/api/outbox/dlq/reconcile',
      parse: (data) =>
          ReconcileResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Notifications ──────────────────────────────────────────────────────────

  /// Fetches notifications from the server.
  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get(
          '/api/notifications',
          queryParameters: {'page': page, 'limit': limit},
        ),
        endpoint: '/api/notifications',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'entries',
    );
    return NotificationPage(
      entries: (data as List)
          .map(
            (e) =>
                NotificationEntry.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  /// Marks a notification as read.
  Future<MarkNotificationResult> markNotificationRead(
    String notificationId,
  ) async {
    return await _execute<MarkNotificationResult>(
      dioCall: () => _dio.post(
        '/api/notifications/mark-read',
        data: {'id': notificationId},
      ),
      endpoint: '/api/notifications/mark-read',
      parse: (data) => MarkNotificationResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Marks all notifications as read.
  Future<MarkNotificationResult> markAllNotificationsRead() async {
    return await _execute<MarkNotificationResult>(
      dioCall: () =>
          _dio.post('/api/notifications/mark-read', data: {'mark_all': true}),
      endpoint: '/api/notifications/mark-read',
      parse: (data) => MarkNotificationResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // ─── Supporting Reports ──────────────────────────────────────────────────────

  /// Fetches supporting reports for a given report ID.
  Future<SupportingReportsResult> getSupportingReports(String reportId) async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/reports/$reportId/supporting'),
        endpoint: '/api/reports/$reportId/supporting',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'reports',
    );
    return SupportingReportsResult(
      reports: (data as List)
          .map((e) => Report.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  // ─── Wilayah ────────────────────────────────────────────────────────────────

  /// Fetches the wilayah (region) list.
  Future<List<Wilayah>> getWilayahList() async {
    final data = _expectKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/wilayah'),
        endpoint: '/api/wilayah',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'wilayah',
    );
    return (data as List)
        .map((e) => Wilayah.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Fetches the boundary geometry for a wilayah as GeoJSON.
  Future<GeoJSONFeatureCollection> getWilayahBoundary(String id) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get('/api/wilayah/$id/boundary'),
      endpoint: '/api/wilayah/$id/boundary',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // ─── Me ───────────────────────────────────────────────────────────────────

  /// Fetches the current user's data including default wilayah and accessible wilayahs.
  Future<User> getMeData() async {
    return await _execute<User>(
      dioCall: () => _dio.get('/api/me/data'),
      endpoint: '/api/me/data',
      parse: (data) => User.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Geocode ───────────────────────────────────────────────────────────────

  /// Fetches reverse geocoded address for given coordinates.
  Future<GeocodeResult> getGeocodeReverse({
    required double lat,
    required double lng,
  }) async {
    return await _execute<GeocodeResult>(
      dioCall: () => _dio.get(
        '/api/geocode/reverse',
        queryParameters: {'lat': lat, 'lng': lng},
      ),
      endpoint: '/api/geocode/reverse',
      parse: (data) =>
          GeocodeResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Public ────────────────────────────────────────────────────────────────

  /// Fetches public GeoJSON for the map (generalized coordinates).
  Future<GeoJSONFeatureCollection> getPublicGeojson({
    String? status,
    String? categoryId,
    String? bbox,
    String? month,
  }) async {
    return await _execute<GeoJSONFeatureCollection>(
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
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches public reports GeoJSON for the map (coarsened coordinates).
  Future<GeoJSONFeatureCollection> getPublicReportsGeojson({
    String? status,
    String? categoryId,
  }) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/public/reports.geojson',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/public/reports.geojson',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches paginated public reports list.
  Future<PublicReportsPage> getPublicReports({
    String? status,
    String? categoryId,
    String? bbox,
    String? month,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final itemsData = _expectKey(data, 'items');
    final paginationData = _expectKey(data, 'pagination');
    return PublicReportsPage(
      items: (itemsData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      pagination: Pagination.fromJson(paginationData),
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
  Future<GeoJSONFeatureCollection> getPublicReportsCluster({
    String? status,
    String? categoryId,
  }) async {
    return getPublicReportsGeojson(status: status, categoryId: categoryId);
  }

  /// Fetches a single public report by ID.
  Future<Report> getPublicCase(String id) async {
    return await _execute<Report>(
      dioCall: () => _dio.get('/api/public/reports/$id'),
      endpoint: '/api/public/reports/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches the public categories list.
  Future<List<Category>> getPublicCategories() async {
    final data = _expectListKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/public/categories'),
        endpoint: '/api/public/categories',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'categories',
    );
    return data
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Fetches public statistics.
  Future<PublicStats> getPublicStats() async {
    return await _execute<PublicStats>(
      dioCall: () => _dio.get('/api/public/stats'),
      endpoint: '/api/public/stats',
      parse: (data) =>
          PublicStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches public sync KPI data.
  Future<SyncKpi> getPublicSyncKpi() async {
    return await _execute<SyncKpi>(
      dioCall: () => _dio.get('/api/public/sync-kpi'),
      endpoint: '/api/public/sync-kpi',
      parse: (data) => SyncKpi.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Posts device sync KPI data.
  Future<SyncKpi> postPublicSyncKpi({
    required String deviceId,
    required String platform,
    required int reportsCount,
    String? lastSyncAt,
  }) async {
    return await _execute<SyncKpi>(
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
      parse: (data) => SyncKpi.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Auditor ────────────────────────────────────────────────────────────────

  /// Fetches auditor audit search results with pagination and filters.
  ///
  /// Query params: actor_id, action, object_type, object_id, from, to, page, limit.
  /// Returns: [AuditPage] with entries, total, page, limit.
  Future<AuditPage> getAuditorAuditSearch({
    String? actorId,
    String? action,
    String? objectType,
    String? objectId,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/auditor/audit-search',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (actorId != null) 'actor_id': actorId,
          if (action != null) 'action': action,
          if (objectType != null) 'object_type': objectType,
          if (objectId != null) 'object_id': objectId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/auditor/audit-search',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = _expectKey(data, 'entries');
    return AuditPage(
      entries: (entriesData as List)
          .map((e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
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
        if (actorId != null) 'actor_id': actorId,
        if (action != null) 'action': action,
        if (objectType != null) 'object_type': objectType,
        if (objectId != null) 'object_id': objectId,
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
  /// Returns: [AuditorSystemLogs] with entries, total, page, limit
  Future<AuditorSystemLogs> getAuditorSystemLogs({
    String? level,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    return await _execute<AuditorSystemLogs>(
      dioCall: () => _dio.get(
        '/api/auditor/system-logs',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (level != null) 'level': level,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/auditor/system-logs',
      parse: (data) =>
          AuditorSystemLogs.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches auditor statistics (counts, top actors, suspicious activity).
  ///
  /// Returns: [AuditorStats] with counts, top_actors, failed_attempts, recent_suspicious
  Future<AuditorStats> getAuditorStats() async {
    return await _execute<AuditorStats>(
      dioCall: () => _dio.get('/api/auditor/stats'),
      endpoint: '/api/auditor/stats',
      parse: (data) =>
          AuditorStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Executive ──────────────────────────────────────────────────────────────

  /// Fetches the executive dashboard summary (total reports, SLA, staffing, etc.).
  Future<ExecutiveDashboard> getExecutiveDashboard() async {
    return await _execute<ExecutiveDashboard>(
      dioCall: () => _dio.get('/api/executive/dashboard'),
      endpoint: '/api/executive/dashboard',
      parse: (data) =>
          ExecutiveDashboard.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches executive regional statistics (by wilayah, by category, staffing).
  Future<ExecutiveDashboard> getExecutiveRegionalStats() async {
    return await _execute<ExecutiveDashboard>(
      dioCall: () => _dio.get('/api/executive/regional-stats'),
      endpoint: '/api/executive/regional-stats',
      parse: (data) =>
          ExecutiveDashboard.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches executive trend analysis over a given period.
  ///
  /// [period] - One of 'daily', 'weekly', or 'monthly' (defaults to 'monthly').
  Future<ExecutiveTrend> getExecutiveTrendAnalysis(String period) async {
    return await _execute<ExecutiveTrend>(
      dioCall: () => _dio.get(
        '/api/executive/trend-analysis',
        queryParameters: {'period': period},
      ),
      endpoint: '/api/executive/trend-analysis',
      parse: (data) =>
          ExecutiveTrend.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Admin Daerah ──────────────────────────────────────────────────────────

  /// Fetches admin daerah dashboard stats.
  Future<AdminDaerahDashboard> getAdminDaerahDashboard() async {
    return await _execute<AdminDaerahDashboard>(
      dioCall: () => _dio.get('/api/admin-daerah/dashboard'),
      endpoint: '/api/admin-daerah/dashboard',
      parse: (data) =>
          AdminDaerahDashboard.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches admin daerah case list with pagination and filters.
  Future<AdminDaerahCasesPage> getAdminDaerahCases({
    int page = 1,
    int limit = 20,
    String? status,
    String? categoryId,
    String? search,
    String? severity,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/cases',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (search != null) 'search': search,
          if (severity != null) 'severity': severity,
        },
      ),
      endpoint: '/api/admin-daerah/cases',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final itemsData = _expectKey(data, 'items');
    return AdminDaerahCasesPage(
      items: (itemsData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches admin daerah operator list with pagination and filters.
  Future<AdminDaerahOperatorsPage> getAdminDaerahOperators({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/operators',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/operators',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = _expectKey(data, 'entries');
    return AdminDaerahOperatorsPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches admin daerah petugas list with pagination and filters.
  Future<AdminDaerahPetugasPage> getAdminDaerahPetugas({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/admin-daerah/petugas',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (isActive != null) 'is_active': isActive.toString(),
        },
      ),
      endpoint: '/api/admin-daerah/petugas',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = _expectKey(data, 'entries');
    return AdminDaerahPetugasPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches admin daerah statistics.
  Future<AdminDaerahDashboard> getAdminDaerahStats() async {
    return await _execute<AdminDaerahDashboard>(
      dioCall: () => _dio.get('/api/admin-daerah/stats'),
      endpoint: '/api/admin-daerah/stats',
      parse: (data) =>
          AdminDaerahDashboard.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches admin daerah SLA rules with pagination and filters.
  Future<AdminDaerahSlaPage> getAdminDaerahSla({
    int page = 1,
    int limit = 20,
    String? kategoriId,
    String? prioritas,
    bool? isActive,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final entriesData = _expectKey(data, 'entries');
    return AdminDaerahSlaPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Updates an admin daerah SLA rule.
  Future<AdminDaerahSlaUpdateResult> updateAdminDaerahSla(
    String id, {
    String? kategoriId,
    String? prioritas,
    int? jam,
    bool? isActive,
  }) async {
    return await _execute<AdminDaerahSlaUpdateResult>(
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
      parse: (data) => AdminDaerahSlaUpdateResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Fetches admin daerah units list with pagination and filters.
  Future<AdminDaerahUnitsPage> getAdminDaerahUnits({
    int page = 1,
    int limit = 20,
    String? wilayahId,
    bool? isActive,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
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
    final entriesData = _expectKey(data, 'entries');
    return AdminDaerahUnitsPage(
      entries: (entriesData as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
    );
  }

  /// Fetches a single admin daerah unit by ID.
  Future<AdminDaerahUnitDetail> getAdminDaerahUnitDetail(String id) async {
    return await _execute<AdminDaerahUnitDetail>(
      dioCall: () => _dio.get('/api/admin-daerah/units/$id'),
      endpoint: '/api/admin-daerah/units/$id',
      parse: (data) =>
          AdminDaerahUnitDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Retries a failed integration outbox entry.
  Future<AdminDaerahIntegrationRetryResult> retryAdminDaerahIntegration(
    String id,
  ) async {
    return await _execute<AdminDaerahIntegrationRetryResult>(
      dioCall: () => _dio.post('/api/admin-daerah/integrasi/outbox/$id/retry'),
      endpoint: '/api/admin-daerah/integrasi/outbox/$id/retry',
      parse: (data) => AdminDaerahIntegrationRetryResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Reconciles admin daerah integration outbox.
  Future<AdminDaerahIntegrationReconcileResult>
  reconcileAdminDaerahIntegration() async {
    return await _execute<AdminDaerahIntegrationReconcileResult>(
      dioCall: () => _dio.post('/api/admin-daerah/integrasi/reconcile'),
      endpoint: '/api/admin-daerah/integrasi/reconcile',
      parse: (data) => AdminDaerahIntegrationReconcileResult.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  // ─── Audit ──────────────────────────────────────────────────────────────────

  /// Fetches audit log entries with pagination and filters.
  ///
  /// Query params: actor_id, action, report_id, from, to, page, limit.
  /// Returns: [AuditPage] with entries, total, page, limit.
  Future<AuditPage> getAuditSearch({
    String? actorId,
    String? action,
    String? reportId,
    String? from,
    String? to,
    int page = 1,
    int limit = 50,
  }) async {
    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/audit/search',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (actorId != null) 'actor_id': actorId,
          if (action != null) 'action': action,
          if (reportId != null) 'report_id': reportId,
          if (from != null) 'from': from,
          if (to != null) 'to': to,
        },
      ),
      endpoint: '/api/audit/search',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = _expectKey(data, 'entries');
    return AuditPage(
      entries: (entriesData as List)
          .map((e) => AuditEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      limit: data['limit'] as int? ?? limit,
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
        if (actorId != null) 'actor_id': actorId,
        if (action != null) 'action': action,
        if (reportId != null) 'report_id': reportId,
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
        if (status != null) 'status': status,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    return res.data.toString();
  }

  /// Exports reports as GeoJSON FeatureCollection.
  Future<GeoJSONFeatureCollection> getExportGeojson({
    String? status,
    String? categoryId,
  }) async {
    return await _execute<GeoJSONFeatureCollection>(
      dioCall: () => _dio.get(
        '/api/export/geojson',
        queryParameters: {
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
        },
      ),
      endpoint: '/api/export/geojson',
      parse: (data) => GeoJSONFeatureCollection.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }
}
