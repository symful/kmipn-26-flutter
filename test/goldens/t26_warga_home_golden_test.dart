// Golden test for M-05: WargaHomeScreen
//
// Wraps WargaHomeScreen in PhoneFrame (392×812) with mock providers
// that return realistic data so the golden captures the full UI.
//
// Run with: flutter test --update-goldens
// Then:     flutter test  (to verify)

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/features/warga/warga_home_screen.dart';
import 'package:sigap/providers/auth_provider.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

void main() {
  group('T26 Golden: M-05 WargaHomeScreen', () {
    testWidgets('M-05 warga home matches golden', (tester) async {
      // Build the screen with mock providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: _buildOverrides(),
          child: const MaterialApp(home: WargaHomeScreen()),
        ),
      );

      // Wait for async providers to settle
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find the PhoneFrame and compare against golden
      expect(find.byType(PhoneFrame), findsOneWidget);
      await expectLater(
        find.byType(PhoneFrame),
        matchesGoldenFile('goldens/m-05-warga-home.png'),
      );
    });
  });
}

// ─── Mock providers for M-05 ───────────────────────────────────────────────

const _mockAuth = AuthState(
  accessToken: 'test-token',
  userId: 'user-001',
  userRole: 'WARGA',
  activeRole: 'WARGA',
  userEmail: 'warga@test.com',
  userName: 'Warga Tester',
  roles: ['WARGA'],
);

final _mockLocalReports = <LocalReport>[
  LocalReport(
    idempotencyKey: 'local-001',
    serverId: 'srv-001',
    categoryId: 'cat-001',
    description:
        'Lubang di jalan utama dengan diameter 50cm yang sangat berbahaya bagi pengguna jalan.',
    lat: -6.9175,
    lng: 107.6191,
    syncStatus: 1,
    status: 'submitted',
    createdAt: DateTime(2026, 8, 20),
    updatedAt: DateTime(2026, 8, 20),
  ),
  LocalReport(
    idempotencyKey: 'local-002',
    serverId: null,
    categoryId: 'cat-002',
    description:
        'Drainase tersumbat di depan Masjid Al-Hidayah menyebabkan air meluap.',
    lat: -6.9200,
    lng: 107.6100,
    syncStatus: 0, // pending sync
    status: 'draft',
    createdAt: DateTime(2026, 8, 18),
    updatedAt: DateTime(2026, 8, 18),
  ),
];

const _mockWargaStats = WargaStats(
  total: 5,
  submitted: 2,
  inProgress: 1,
  verified: 1,
  resolved: 1,
);

List<Override> _buildOverrides() => [
  authNotifierProvider.overrideWith((_) {
    final notifier = _MockAuthNotifier(_mockAuth);
    return notifier;
  }),
  connectivityProvider.overrideWith(
    (_) => Stream.value([ConnectivityResult.wifi]),
  ),
  localReportsProvider.overrideWith((_) async => _mockLocalReports),
  wargaReportsProvider.overrideWith((_) async => []),
  pendingCountProvider.overrideWith((_) => Stream.value(0)),
  wargaStatsProvider.overrideWith((_) async => _mockWargaStats),
  selectedWilayahNameProvider.overrideWith((_) => 'Bandung'),
  unreadCountProvider.overrideWith((_) => 3),
  wilayahProvider.overrideWith(
    (_) async => [
      {'id': 'w-001', 'name': 'Bandung', 'village_name': 'Bandung'},
    ],
  ),
];

class _MockAuthNotifier extends StateNotifier<AuthState> {
  _MockAuthNotifier(AuthState state) : super(state);
}
