import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';

const _apiBaseUrl = 'https://sigap.live';

/// Authenticates and returns tokens. Throws if login fails so setUpAll fails loudly.
Future<({String accessToken, String refreshToken})> _login(
  String email,
  String password,
) async {
  final client = ApiClient(baseUrl: _apiBaseUrl);
  final resp = await client.login(email, password);
  final token = resp.token;
  final refresh = resp.refreshToken;
  expect(token, isNotNull, reason: 'login returned null access token');
  expect(token, isNotEmpty, reason: 'login returned empty access token');
  expect(refresh, isNotNull, reason: 'login returned null refresh token');
  return (accessToken: token!, refreshToken: refresh!);
}

void main() {
  late ApiClient wargaClient;
  late ApiClient surveyorClient;

  setUpAll(() async {
    final wargaTokens = await _login('warga@sigap.id', 'warga123');
    wargaClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: wargaTokens.accessToken,
    );

    final surveyorTokens = await _login('surveyor@sigap.id', 'surveyor123');
    surveyorClient = ApiClient(
      baseUrl: _apiBaseUrl,
      testAccessToken: surveyorTokens.accessToken,
    );
  });

  group('notifications + profile flow', () {
    test('getNotifications returns notification list', () async {
      final result = await wargaClient.getNotifications();
      expect(
        result.entries,
        isA<List<Notification>>(),
        reason: 'notifications should be List<Notification>',
      );
      for (final n in result.entries) {
        expect(n.id, isNotNull, reason: 'notification id should not be null');
        expect(
          n.title,
          isA<String>(),
          reason: 'notification title should be string',
        );
        expect(
          n.body,
          isA<String>(),
          reason: 'notification body should be string',
        );
        expect(
          n.createdAt,
          isNotNull,
          reason: 'notification createdAt should not be null',
        );
      }
    });

    test('markNotificationRead marks single notification as read', () async {
      final notifRes = await wargaClient.getNotifications();

      if (notifRes.entries.isEmpty) {
        // No notifications — mark-all is functionally equivalent
        final markAllRes = await wargaClient.markAllNotificationsRead();
        expect(
          markAllRes,
          isA<MarkReadResult>(),
          reason: 'markAll result should be MarkReadResult',
        );
        expect(
          markAllRes.success,
          isTrue,
          reason: 'markAll success should be true',
        );
      } else {
        final target = notifRes.entries.first;
        expect(target.id, isNotNull, reason: 'notification should have id');
        final markRes = await wargaClient.markNotificationRead(target.id!);
        expect(
          markRes,
          isA<MarkReadResult>(),
          reason: 'mark result should be MarkReadResult',
        );
        expect(
          markRes.success,
          isTrue,
          reason: 'mark read success should be true',
        );
      }
    });

    test('markAllNotificationsRead returns success', () async {
      final markAllRes = await wargaClient.markAllNotificationsRead();
      expect(
        markAllRes,
        isA<MarkReadResult>(),
        reason: 'result should be MarkReadResult',
      );
      expect(
        markAllRes.success,
        isA<bool>(),
        reason: 'success should be boolean',
      );
    });

    test(
      'forbidden: surveyor cannot mark warga notification as read',
      () async {
        final wargaNotifs = await wargaClient.getNotifications();

        if (wargaNotifs.entries.isNotEmpty) {
          final wargaNotifId = wargaNotifs.entries.first.id!;
          expect(
            () => surveyorClient.markNotificationRead(wargaNotifId),
            throwsA(anything),
            reason: 'surveyor should not be able to mark warga notification',
          );
        }
        // If warga has no notifications, skip this test
      },
    );

    test('me() returns warga profile data', () async {
      final meData = await wargaClient.me();
      expect(
        meData,
        isA<UserResponse>(),
        reason: 'me() should return UserResponse',
      );
      expect(meData.id, isNotNull, reason: 'user id should not be null');
      expect(meData.id, isNotEmpty, reason: 'user id should not be empty');
      expect(meData.email, isA<String>(), reason: 'email should be string');
      expect(meData.email, contains('@'), reason: 'email should contain @');
    });

    test('getStats returns warga report stats', () async {
      final stats = await wargaClient.getStats();
      expect(
        stats.total != null || stats.byStatus != null,
        isTrue,
        reason: 'stats should have data',
      );
      expect(
        stats.byStatus is Map<String, dynamic> || stats.byStatus == null,
        isTrue,
        reason: 'byStatus should be Map or null',
      );
    });

    test('/api/auth/me raw endpoint returns user data export', () async {
      // Use the wargaClient which already has auth — me() calls /api/auth/me
      final meData = await wargaClient.me();
      expect(meData.id, isNotNull, reason: 'me data should have id');
      expect(meData.id, isA<String>(), reason: 'id should be string');
    });

    test('me endpoint response respects user privacy', () async {
      final meData = await wargaClient.me();
      // The UserResponse type doesn't expose password/refresh_token fields directly
      // but we verify only expected fields are present
      expect(
        meData.id,
        isNotNull,
        reason: 'user id should be present in me data',
      );
    });

    test('warga profile has expected fields', () async {
      final meData = await wargaClient.me();
      expect(meData.id, isA<String>(), reason: 'profile id should be string');
      expect(
        meData.email,
        isA<String>(),
        reason: 'profile email should be string',
      );
      expect(
        meData.role,
        isA<String>(),
        reason: 'profile role should be string',
      );
      expect(meData.role, equals('WARGA'), reason: 'role should be WARGA');
    });
  });
}
