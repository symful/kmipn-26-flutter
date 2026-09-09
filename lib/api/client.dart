import 'dart:io';
import 'dart:typed_data';
import '../services/internet_reachability.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../l10n/generated/app_localizations.dart';

import 'auth_interceptor.dart';
import 'exceptions.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

part 'models/statuses.dart';
part 'models/reports.dart';

part 'models/tasks.dart';
part 'models/governance.dart';
part 'models/geo.dart';

part 'models/common.dart';

class ApiClient {
  Future<ReverseGeocodedAddress> reverseGeocode(
    double latitude,
    double longitude,
  ) => _execute<ReverseGeocodedAddress>(
    dioCall: () => _dio.get(
      '/api/geocode/reverse',
      queryParameters: {'lat': latitude, 'lng': longitude},
    ),
    endpoint: '/api/geocode/reverse',
    parse: (data) =>
        ReverseGeocodedAddress.fromJson((data as Map).cast<String, dynamic>()),
  );
  Future<String> registerPushDevice({
    required String deviceId,
    required String token,
  }) => _execute<String>(
    dioCall: () => _dio.post(
      '/api/notifications/devices',
      data: {'device_id': deviceId, 'token': token, 'platform': 'android'},
    ),
    endpoint: '/api/notifications/devices',
    parse: (data) => data['id'] as String,
  );

  Future<void> unregisterPushDevice(String deviceId) => _execute<void>(
    dioCall: () => _dio.delete(
      '/api/notifications/devices',
      data: {'device_id': deviceId},
    ),
    endpoint: '/api/notifications/devices',
    parse: (_) {},
  );

  Future<SyncStatusReceipt> reportSyncStatus({
    required String deviceId,
    required int pendingCount,
    required int failedCount,
    required int totalCount,
  }) => _execute<SyncStatusReceipt>(
    dioCall: () => _dio.post(
      '/api/sync/status',
      data: {
        'device_id': deviceId,
        'pending_count': pendingCount,
        'failed_count': failedCount,
        'total_count': totalCount,
      },
    ),
    endpoint: '/api/sync/status',
    parse: (data) =>
        SyncStatusReceipt.fromJson((data as Map).cast<String, dynamic>()),
  );
  String resolveMediaUrl(String path) {
    final base = Uri.parse(_dio.options.baseUrl);
    final media = base.resolve(path);
    const loopbackHosts = {'localhost', '127.0.0.1', '::1'};
    if (media.path.startsWith('/r2/') && loopbackHosts.contains(media.host)) {
      return Uri(
        scheme: base.scheme,
        userInfo: base.userInfo,
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: media.path,
        query: media.hasQuery ? media.query : null,
        fragment: media.hasFragment ? media.fragment : null,
      ).toString();
    }
    return media.toString();
  }

  final Dio _dio;
  final Dio _publicDio;
  final Future<void> Function()? _checkConnectivityFn;
  final AppLocalizations? _l10n;

  ApiClient({
    String? baseUrl,
    FlutterSecureStorage? storage,
    Future<void> Function()? onLogout,
    Dio? dio,
    Future<void> Function()? checkConnectivity,
    String? testAccessToken,
    Future<String?> Function(String role)? authTokenProvider,
    AppLocalizations? l10n,
    bool authenticated = true,
    String? accountId,
  }) : _l10n = l10n,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? ApiConfig.baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
               validateStatus: (int? status) =>
                   status != null && (status < 400 || status == 503),
             ),
           ),
       _checkConnectivityFn = checkConnectivity,
       _publicDio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? ApiConfig.baseUrl,
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(seconds: 30),
           validateStatus: (int? status) =>
               status != null && (status < 400 || status == 503),
         ),
       ) {
    if (baseUrl != null && dio != null) {
      _dio.options.baseUrl = baseUrl;
      _publicDio.options.baseUrl = baseUrl;
    }
    if (dio == null && authenticated) {
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
          expectedUserId: accountId,
        ),
      );
    }
  }

  Dio get dio => _dio;

  void close() {
    _dio.close(force: true);
    _publicDio.close(force: true);
  }

  Future<void> _checkConnectivity() async {
    if (_checkConnectivityFn != null) {
      await _checkConnectivityFn();
      return;
    }
    if (!await InternetReachability.isOnline()) {
      throw NetworkException();
    }
  }

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
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await dioCall();
        final sc = res.statusCode ?? 0;

        if (sc >= 400) {
          final apiErr = ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: endpoint,
            userMessage: '${extractErrorMessageFromData(res.data)} [$endpoint]',
          );
          final retryable =
              sc == 503 || (res.data?.toString().contains('1102') ?? false);
          if (retryable && attempt < 3) {
            lastError = apiErr;
            await Future.delayed(backoffs[attempt]);
            continue;
          }
          throw apiErr;
        }

        return parse(res.data);
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final bodyStr = e.response?.data?.toString() ?? '';
        final retryable = statusCode == 503 || bodyStr.contains('1102');
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(const Duration(seconds: 30), endpoint);
          case DioExceptionType.badResponse:
            final userMessage = extractErrorMessage(e);
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.response?.data?.toString(),
              endpoint: endpoint,
              userMessage: '$userMessage [$endpoint]',
            );
          default:
            final userMessage = extractErrorMessage(e);
            throw ApiException(
              statusCode: 0,
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: endpoint,
              userMessage: '$userMessage [$endpoint]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  // ─── Auth ─────────────────────────────────────────────────────────────────

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

  Future<LoginResponse> refresh(String refreshToken) async {
    return await _execute<LoginResponse>(
      dioCall: () => _dio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/auth/refresh',
      parse: (data) =>
          LoginResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<UserResponse> me() async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.get('/api/auth/me'),
      endpoint: '/api/auth/me',
      parse: (data) =>
          UserResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<void> logout(String refreshToken) async {
    await _execute<void>(
      dioCall: () =>
          _dio.post('/api/auth/logout', data: {'refresh_token': refreshToken}),
      endpoint: '/api/auth/logout',
      parse: (_) {},
    );
  }

  Future<UserResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _execute<UserResponse>(
      dioCall: () => _dio.post(
        '/api/auth/register',
        data: {'email': email, 'password': password, 'name': name},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/auth/register',
      parse: (data) =>
          UserResponse.fromJson({'user': data as Map<String, dynamic>}),
    );
  }

  // ─── Categories ─────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories() async {
    final data = _expectListKey(
      await _execute<Map<String, dynamic>>(
        dioCall: () => _dio.get('/api/categories'),
        endpoint: '/api/categories',
        parse: (data) => (data as Map).cast<String, dynamic>(),
      ),
      'data',
    );
    return data
        .map((e) => Category.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // ─── Public Endpoints (no auth required) ─────────────────────────────────

  /// Fetches public report list — no auth token needed.
  /// Returns reports with no PII (reporter info excluded).

  /// Fetches public stats — no auth required.
  Future<PublicStats> getPublicStats({String? period}) async {
    await _checkConnectivity();
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await _publicDio.get(
          '/api/public/stats',
          queryParameters: {if (period != null) 'period': period},
        );
        final sc = res.statusCode ?? 0;
        if (sc >= 400) {
          throw ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: '/api/public/stats',
            userMessage:
                _l10n?.gagalMemuatStatistikPublik ??
                'Failed to fetch public stats',
          );
        }
        final data = res.data as Map<String, dynamic>;
        return PublicStats.fromJson(data);
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final retryable = statusCode == 503;
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(
              const Duration(seconds: 30),
              '/api/public/stats',
            );
          default:
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: '/api/public/stats',
              userMessage: '${extractErrorMessage(e)} [/api/public/stats]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  /// Fetches OG meta for sharing a case — no auth required.
  Future<ShareMetadata> getShareMetadata(String caseId) async {
    await _checkConnectivity();
    final backoffs = [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 6),
    ];
    Object? lastError;
    for (var attempt = 0; attempt <= 3; attempt++) {
      try {
        final res = await _publicDio.get('/api/public/cases/$caseId/share');
        final sc = res.statusCode ?? 0;
        if (sc >= 400) {
          throw ApiException(
            statusCode: sc,
            body: res.data?.toString(),
            endpoint: '/api/public/cases/$caseId/share',
            userMessage:
                _l10n?.gagalMemuatMetadataBagikan ??
                'Failed to fetch share metadata',
          );
        }
        final data = res.data as Map<String, dynamic>;
        return ShareMetadata.fromJson(data);
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final retryable = statusCode == 503;
        if (retryable && attempt < 3) {
          lastError = e;
          await Future.delayed(backoffs[attempt]);
          continue;
        }
        if (attempt >= 3 && lastError != null) throw lastError;
        switch (e.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
            throw NetworkException(
              _l10n?.tidakDapatTerhubungKeServer ?? 'Cannot connect to server.',
            );
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw TimeoutException(
              const Duration(seconds: 30),
              '/api/public/cases/$caseId/share',
            );
          default:
            throw ApiException(
              statusCode: e.response?.statusCode ?? 0,
              body: e.message ?? (_l10n?.errorTidakDikenal ?? 'Unknown error'),
              endpoint: '/api/public/cases/$caseId/share',
              userMessage:
                  '${extractErrorMessage(e)} [/api/public/cases/$caseId/share]',
            );
        }
      }
    }
    throw lastError ??
        Exception(_l10n?.gagalRetryLoop ?? 'Unexpected retry loop exit');
  }

  // ─── Reports ───────────────────────────────────────────────────────────────

  Future<Report> getReportById(String id) async {
    return await _execute<Report>(
      dioCall: () => _dio.get('/api/reports/$id'),
      endpoint: '/api/reports/$id',
      parse: (data) => Report.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<PaginatedReports> getReports({
    String? status,
    String? categoryId,
    String? cursor,
    int limit = 50,
    String? q,
    String? creatorId,
  }) async {
    return await _execute<PaginatedReports>(
      dioCall: () => _dio.get(
        '/api/reports',
        queryParameters: {
          'limit': limit,
          if (status != null) 'status': status,
          if (categoryId != null) 'category_id': categoryId,
          if (cursor != null) 'cursor': cursor,
          if (q != null) 'q': q,
          if (creatorId != null) 'creator_id': creatorId,
        },
      ),
      endpoint: '/api/reports',
      parse: (data) =>
          PaginatedReports.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Unified report submission for both authenticated (warga) and anonymous reporters.
  /// Uses _dio (optional-auth client) — token is attached only if user is logged in;
  /// otherwise the request is sent without auth and backend treats it as anonymous.
  ///
  /// Photos must be uploaded BEFORE calling this method via [uploadReportPhotoAnon]
  /// or [uploadReportPhoto]. Pass the returned public URLs in [photoUrls].
  Future<SubmitReportResult> submitReport({
    required String idempotencyKey,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    String? deviceId,
    String? title,
    List<String>? photoUrls,
    String? reportedSeverity,
    DateTime? reportedAt,
    String? supportingCaseId,
    String? captchaToken,
    int? populationAffected,
    double? vulnerabilityIndex,
    List<String>? impactDampak,
    bool anonymous = false,
    String? kecamatan,
    String? kelurahan,
    String? kabupaten,
    String? provinsi,
    String? addressArea,
  }) async {
    if (anonymous) {
      return await _execute<SubmitReportResult>(
        dioCall: () => _dio.post(
          '/api/public/anonymous-reports',
          data: {
            'idempotency_key': idempotencyKey,
            'category_id': categoryId,
            'description': description,
            'lat': lat,
            'lng': lng,
            if (reportedAt != null)
              'reported_at': reportedAt.toUtc().toIso8601String(),
            if (deviceId != null) 'device_id': deviceId,
            if (title != null) 'title': title,
            if (reportedSeverity != null) 'reported_severity': reportedSeverity,
            if (supportingCaseId != null)
              'supporting_case_id': supportingCaseId,
            if (photoUrls != null && photoUrls.isNotEmpty) 'photos': photoUrls,
            if (populationAffected != null)
              'population_affected': populationAffected,
            if (vulnerabilityIndex != null)
              'vulnerability_index': vulnerabilityIndex,
            if (captchaToken != null) 'captcha_token': captchaToken,
            if (kecamatan != null) 'kecamatan': kecamatan,
            if (kelurahan != null) 'kelurahan': kelurahan,
            if (kabupaten != null) 'kabupaten': kabupaten,
            if (provinsi != null) 'provinsi': provinsi,
            if (addressArea != null && addressArea.trim().isNotEmpty)
              'address_area': addressArea.trim(),
          },
        ),
        endpoint: '/api/public/anonymous-reports',
        parse: (data) =>
            SubmitReportResult.fromJson((data as Map).cast<String, dynamic>()),
      );
    } else {
      return await _execute<SubmitReportResult>(
        dioCall: () => _dio.post(
          '/api/reports',
          data: {
            'idempotency_key': idempotencyKey,
            'category_id': categoryId,
            'description': description,
            'lat': lat,
            'lng': lng,
            if (reportedAt != null)
              'reported_at': reportedAt.toUtc().toIso8601String(),
            if (title != null) 'title': title,
            if (reportedSeverity != null) 'reported_severity': reportedSeverity,
            if (supportingCaseId != null)
              'supporting_case_id': supportingCaseId,
            if (photoUrls != null && photoUrls.isNotEmpty)
              'photo_urls': photoUrls
                  .where(
                    (url) =>
                        url.startsWith('/r2/reports/') ||
                        ((Uri.tryParse(url)?.hasAuthority ?? false) &&
                            (url.startsWith('http://') ||
                                url.startsWith('https://'))),
                  )
                  .toList(),
            if (populationAffected != null)
              'population_affected': populationAffected,
            if (vulnerabilityIndex != null)
              'vulnerability_index': vulnerabilityIndex,
            if (impactDampak != null) 'impact_dampak': impactDampak,
            if (kecamatan != null) 'kecamatan': kecamatan,
            if (kelurahan != null) 'kelurahan': kelurahan,
            if (kabupaten != null) 'kabupaten': kabupaten,
            if (provinsi != null) 'provinsi': provinsi,
            if (addressArea != null && addressArea.trim().isNotEmpty)
              'address_area': addressArea.trim(),
          },
        ),
        endpoint: '/api/reports',
        parse: (data) =>
            SubmitReportResult.fromJson((data as Map).cast<String, dynamic>()),
      );
    }
  }

  /// Uploads a photo for anonymous report creation via FormData.
  /// Calls POST /api/reports/photos/upload-url-anon with multipart form data.
  /// Returns the public R2 URL of the uploaded photo.
  Future<String> uploadReportPhotoAnon(
    String filePath,
    String idempotencyKey, {
    int slot = 0,
    String? originalFilePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ApiException(
        statusCode: 404,
        endpoint: filePath,
        userMessage:
            '${_l10n?.fileFotoTidakDitemukan ?? 'Photo file not found'}: $filePath',
      );
    }

    final fileName = filePath.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: fileName),
      'idempotency_key': idempotencyKey,
      'slot': slot.toString(),
      if (originalFilePath != null)
        'original_photo': await MultipartFile.fromFile(
          originalFilePath,
          filename: originalFilePath.split(Platform.pathSeparator).last,
          contentType: DioMediaType.parse(
            originalFilePath.toLowerCase().endsWith('.png')
                ? 'image/png'
                : originalFilePath.toLowerCase().endsWith('.webp')
                ? 'image/webp'
                : 'image/jpeg',
          ),
        ),
    });

    final res = await _dio.post<Map<String, dynamic>>(
      '/api/reports/photos/upload-url-anon',
      data: formData,
    );

    final data = res.data;
    if (data == null || data['public_url'] == null) {
      throw ApiException(
        statusCode: 500,
        endpoint: '/api/reports/photos/upload-url-anon',
        userMessage:
            _l10n?.uploadFotoGagalUrl ?? 'Photo upload failed: no URL returned',
      );
    }

    return data['public_url'] as String;
  }

  Future<ReportActionResponse> reportAction({
    required String reportId,
    required String action,
    String? note,
  }) async {
    // Dispatch action to the specific backend sub-route
    String endpoint;
    Map<String, dynamic> body;

    switch (action) {
      case 'sanggah':
        endpoint = '/api/reports/$reportId/sanggahan';
        body = {'reason': note ?? ''};
        break;
      case 'lengkapi':
        // lengkapi (add evidence) — submit via evidence endpoint
        endpoint = '/api/reports/$reportId/evidence';
        body = {'description': note ?? ''};
        break;
      case 'reopen':
        endpoint = '/api/reports/$reportId/reopen';
        body = {'reason': note ?? ''};
        break;
      case 'self_close':
        endpoint = '/api/reports/$reportId/self-close';
        body = {'reason': note ?? ''};
        break;
      default:
        throw ArgumentError.value(
          action,
          'action',
          'Unsupported report action',
        );
    }

    return await _execute<ReportActionResponse>(
      dioCall: () => _dio.post(
        endpoint,
        data: body,
        options: Options(contentType: 'application/json'),
      ),
      endpoint: endpoint,
      parse: (data) =>
          ReportActionResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<void> addReportEvidence(
    String reportId,
    String filePath, {
    String description = '',
  }) async {
    final extension = filePath.split('.').last.toLowerCase();
    final mime = extension == 'png'
        ? 'image/png'
        : extension == 'webp'
        ? 'image/webp'
        : 'image/jpeg';
    await _dio.post(
      '/api/reports/$reportId/evidence',
      data: FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          filePath,
          filename: 'evidence.$extension',
          contentType: DioMediaType.parse(mime),
        ),
        'description': description,
      }),
    );
  }

  Future<PhotoUploadUrlResponse> getPhotoUploadUrl(
    String reportId,
    String uploadToken, {
    int slot = 0,
  }) async {
    return await _execute<PhotoUploadUrlResponse>(
      dioCall: () => _dio.post(
        '/api/reports/$reportId/photos',
        queryParameters: {'uploadToken': uploadToken, 'slot': slot},
      ),
      endpoint: '/api/reports/$reportId/photos',
      parse: (data) => PhotoUploadUrlResponse.fromJson(
        (data as Map).cast<String, dynamic>(),
      ),
    );
  }

  /// Authenticated multipart upload used by field evidence; no anonymous token.
  Future<String> uploadTaskPhoto(String reportId, String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();
    final mime = extension == 'png'
        ? 'image/png'
        : extension == 'webp'
        ? 'image/webp'
        : 'image/jpeg';
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/reports/$reportId/photos/upload-url',
      data: FormData.fromMap({
        'purpose': 'task_evidence',
        'photo': await MultipartFile.fromFile(
          filePath,
          filename: 'survey.$extension',
          contentType: DioMediaType.parse(mime),
        ),
      }),
    );
    final url = response.data?['public_url']?.toString();
    if (url == null || url.isEmpty) {
      throw StateError('Foto belum berhasil diunggah');
    }
    return url;
  }

  Future<PhotoPutResponse> putPhoto({
    required String reportId,
    required String putUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final putDio = Dio();
    final res = await putDio.put(
      putUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {'Content-Type': contentType, 'Content-Length': bytes.length},
      ),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw ApiException(
        statusCode: res.statusCode ?? 0,
        endpoint: putUrl,
        userMessage: _l10n?.uploadFotoGagal ?? 'Photo upload failed',
      );
    }
    return PhotoPutResponse.fromJson((res.data as Map).cast<String, dynamic>());
  }

  /// Uploads a photo for an existing report using the presigned URL flow.
  /// Requires authentication.
  /// Calls POST /api/reports/:id/photos?uploadToken=... to get presigned URL, then PUTs the bytes.
  Future<PhotoUploadResult> uploadReportPhoto(
    String reportId,
    String filePath,
    String uploadToken, {
    int slot = 0,
  }) async {
    // Get presigned upload URL
    final uploadUrlResp = await getPhotoUploadUrl(
      reportId,
      uploadToken,
      slot: slot,
    );

    // Read file bytes
    final file = File(filePath);
    if (!await file.exists()) {
      throw ApiException(
        statusCode: 404,
        endpoint: filePath,
        userMessage:
            '${_l10n?.fileFotoTidakDitemukan ?? 'Photo file not found'}: $filePath',
      );
    }
    final bytes = await file.readAsBytes();

    // Upload to R2 via presigned URL
    final putResp = await putPhoto(
      reportId: reportId,
      putUrl: uploadUrlResp.putUrl ?? '',
      bytes: bytes,
      contentType: 'image/jpeg',
    );

    return PhotoUploadResult(
      publicUrl: putResp.photoUrls.isNotEmpty ? putResp.photoUrls.first : null,
    );
  }

  // ─── Agent/AI Assessment ─────────────────────────────────────────────────

  /// Fetches AI assessment results for a report from GET /api/reports/:id.
  Future<WargaReportsPage> getMyReports() async {
    // Pass creator_id=me so backend filters by reporter_id
    final paginatedReports = await getReports(limit: 100, creatorId: 'me');
    return WargaReportsPage(items: paginatedReports.data);
  }

  Future<TimelineEnvelope> getReportTimeline(String reportId) =>
      _execute<TimelineEnvelope>(
        dioCall: () => _dio.get('/api/reports/$reportId/timeline'),
        endpoint: '/api/reports/$reportId/timeline',
        parse: (data) =>
            TimelineEnvelope.fromJson((data as Map).cast<String, dynamic>()),
      );

  /// Fetches priority data for a report from GET /api/reports/:id/priority.
  Future<List<NearbyReport>> getNearbyReports({
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/reports/nearby',
      queryParameters: {'lat': lat, 'lng': lng, 'limit': limit},
    );
    final data = res.data as Map<String, dynamic>;
    final items = (data['reports'] ?? data['data']) as List? ?? [];
    return items
        .map(
          (item) =>
              NearbyReport.fromJson((item as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  /// Fetches similar report candidates from GET /api/reports/duplicates.
  /// Used during report creation (M-11) to suggest attaching to existing cases.
  Future<List<SimilarReport>> getSimilarReports({
    required double lat,
    required double lng,
    required String categoryId,
    int limit = 10,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/reports/duplicates',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'category_id': categoryId,
        'limit': limit,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final items = data['data'] as List? ?? [];
    return items
        .map((item) => SimilarReport.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Extracts duplicate case candidates from GET /api/reports/:id assessment
  /// results. Parses assessments[].risk JSON to find duplicate_candidates.
  Future<TaskListPage<PetugasTask>> getTasks({
    String? reportId,
    String? filter,
    String? status,
    String? sort,
  }) async {
    final queryParams = <String, dynamic>{};
    if (reportId != null) queryParams['report_id'] = reportId;
    if (filter != null) queryParams['filter'] = filter;
    if (status != null) queryParams['status'] = status;
    if (sort != null) queryParams['sort'] = sort;

    final data = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/tasks',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      ),
      endpoint: '/api/tasks',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    // Backend returns { data: [...] } — not { tasks: [...] }
    List<dynamic> tasksList = [];
    final rawData = data['data'];
    if (rawData is List) tasksList = rawData;
    return TaskListPage<PetugasTask>(
      tasks: tasksList
          .map((e) => PetugasTask.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination: Pagination(page: 1, limit: 20, total: tasksList.length),
    );
  }

  Future<TaskDetail> getTaskDetail(String taskId) async {
    return await _execute<TaskDetail>(
      dioCall: () => _dio.get('/api/tasks/$taskId'),
      endpoint: '/api/tasks/$taskId',
      parse: (data) =>
          TaskDetail.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<ChecklistTemplate> getTaskChecklistTemplate(String taskId) async {
    return await _execute<ChecklistTemplate>(
      dioCall: () => _dio.get('/api/tasks/$taskId/checklist-template'),
      endpoint: '/api/tasks/$taskId/checklist-template',
      parse: (data) =>
          ChecklistTemplate.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<TaskActionResult> taskAction(
    String taskId, {
    required String action,
    String? note,
  }) async {
    // Dispatch action to the specific backend sub-route
    String endpoint;
    Map<String, dynamic> body;

    switch (action) {
      case 'accept':
        endpoint = '/api/tasks/$taskId/accept';
        body = {'accept': true, if (note != null) 'reason': note};
        break;
      case 'start':
        endpoint = '/api/tasks/$taskId/start';
        body = {};
        break;
      case 'reject':
        endpoint = '/api/tasks/$taskId/reject';
        body = {'reason': note ?? ''};
        break;
      case 'clarify':
        endpoint = '/api/tasks/$taskId/clarification';
        body = {'message': note ?? ''};
        break;
      case 'complete':
        endpoint = '/api/tasks/$taskId/complete';
        body = {'summary': note ?? ''};
        break;
      default:
        throw ArgumentError.value(action, 'action', 'Unsupported task action');
    }

    return await _execute<TaskActionResult>(
      dioCall: () => _dio.post(
        endpoint,
        data: body,
        options: Options(contentType: 'application/json'),
      ),
      endpoint: endpoint,
      parse: (data) =>
          TaskActionResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<VisitResult> submitVisitReport({
    required String taskId,
    String? idempotencyKey,
    required String findings,
    required List<SurveyChecklistAnswer> checklist,
    required List<String> photoUrls,
    required double gpsLat,
    required double gpsLng,
    required double accuracy,
    required String conditionAssessment,
    required String recommendation,
    String? dimensions,
    String? catatan,
  }) async {
    if (findings.isEmpty) {
      throw ArgumentError('submitVisitReport requires non-empty findings');
    }
    if (checklist.isEmpty) {
      throw ArgumentError('submitVisitReport requires non-empty checklist');
    }
    if (gpsLat == 0 && gpsLng == 0) {
      throw ArgumentError('submitVisitReport requires valid GPS coordinates');
    }

    return await _execute<VisitResult>(
      dioCall: () => _dio.post(
        '/api/tasks/$taskId/visit',
        data: {
          'findings': findings,
          if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
          'checklist': checklist.map((answer) => answer.toJson()).toList(),
          'photo_urls': photoUrls,
          'condition_assessment': conditionAssessment,
          'recommendation': recommendation,
          'gps': {'lat': gpsLat, 'lng': gpsLng, 'accuracy_m': accuracy},
          if (dimensions != null && dimensions.isNotEmpty)
            'dimensions': dimensions,
          if (catatan != null && catatan.isNotEmpty) 'notes': catatan,
        },
      ),
      endpoint: '/api/tasks/$taskId/visit',
      parse: (data) =>
          VisitResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  Future<StatsResponse> getStats() async {
    return await _execute<StatsResponse>(
      dioCall: () => _dio.get('/api/stats'),
      endpoint: '/api/stats',
      parse: (data) =>
          StatsResponse.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  /// Fetches warga-specific statistics (submitted, verified, in_progress, resolved).
  /// Returns a [WargaStats] object from GET /api/stats.
  Future<WargaStats> getWargaStats() async {
    return await _execute<WargaStats>(
      dioCall: () => _dio.get('/api/stats'),
      endpoint: '/api/stats',
      parse: (data) =>
          WargaStats.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Notifications ─────────────────────────────────────────────────────

  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _execute<Map<String, dynamic>>(
      dioCall: () => _dio.get(
        '/api/notifications',
        queryParameters: {'page': page, 'limit': limit},
      ),
      endpoint: '/api/notifications',
      parse: (data) => (data as Map).cast<String, dynamic>(),
    );
    final entriesData = response['data'] ?? response['entries'];
    if (entriesData is! List) {
      throw FormatException(
        'Unexpected response shape: expected "data" or "entries" key to be a list',
      );
    }
    return NotificationPage(
      entries: entriesData
          .map((e) => Notification.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<MarkReadResult> markNotificationRead(String notificationId) async {
    return await _execute<MarkReadResult>(
      dioCall: () => _dio.post(
        '/api/notifications/mark-read',
        data: {'id': notificationId},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/notifications/mark-read',
      parse: (data) =>
          MarkReadResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  Future<MarkReadResult> markAllNotificationsRead() async {
    // Use the bulk endpoint POST /api/notifications/mark-read with mark_all: true
    return await _execute<MarkReadResult>(
      dioCall: () => _dio.post(
        '/api/notifications/mark-read',
        data: {'mark_all': true},
        options: Options(contentType: 'application/json'),
      ),
      endpoint: '/api/notifications/mark-read',
      parse: (data) =>
          MarkReadResult.fromJson((data as Map).cast<String, dynamic>()),
    );
  }

  // ─── Map ────────────────────────────────────────────────────────────────

  Future<GeoJSONFeatureCollection> getMapGeoJson() async {
    await _checkConnectivity();
    final res = await _publicDio.get('/api/public/geojson');
    final sc = res.statusCode ?? 0;
    if (sc >= 400) {
      throw ApiException(
        statusCode: sc,
        body: res.data?.toString(),
        endpoint: '/api/public/geojson',
        userMessage: _l10n?.gagalMemuatPeta ?? 'Failed to load map data',
      );
    }
    return GeoJSONFeatureCollection.fromJson(
      (res.data as Map).cast<String, dynamic>(),
    );
  }
}
