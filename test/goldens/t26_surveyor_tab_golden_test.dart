// Golden test for S-01: SurveyorTabScreen
//
// SurveyorTabScreen is already wrapped in PhoneFrame internally.
// We test it as-is with mock providers.
//
// Run with: flutter test --update-goldens
// Then:     flutter test  (to verify)

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/features/surveyor/surveyor_tab_screen.dart';
import 'package:sigap/providers/auth_provider.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

void main() {
  group('T26 Golden: S-01 SurveyorTabScreen', () {
    testWidgets('S-01 surveyor tab matches golden', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _buildOverrides(),
          child: const MaterialApp(home: SurveyorTabScreen()),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(PhoneFrame), findsOneWidget);
      await expectLater(
        find.byType(PhoneFrame),
        matchesGoldenFile('goldens/s-01-surveyor-tab.png'),
      );
    });
  });
}

const _mockSurveyorAuth = AuthState(
  accessToken: 'test-token-surveyor',
  userId: 'user-surveyor-001',
  userRole: 'SURVEYOR',
  activeRole: 'SURVEYOR',
  userEmail: 'surveyor@test.com',
  userName: 'Surveyor Tester',
  roles: ['SURVEYOR'],
);

final _mockTasks = <SurveyorTask>[
  SurveyorTask(
    taskId: 'TGS-3401',
    reportId: 'rpt-001',
    reportTitle: 'Lubang jalan di JL Sudirman',
    reportLat: -6.9175,
    reportLng: 107.6191,
    reportAddress: 'Jl. Sudirman No. 10, Bandung',
    status: 'assigned',
    deadline: DateTime(2026, 8, 28).toIso8601String(),
  ),
  SurveyorTask(
    taskId: 'TGS-3402',
    reportId: 'rpt-002',
    reportTitle: 'Drainase tersumbat di Jl. Asia Afrika',
    reportLat: -6.9200,
    reportLng: 107.6100,
    reportAddress: 'Jl. Asia Afrika No. 5',
    status: 'pending',
    deadline: DateTime(2026, 8, 29).toIso8601String(),
  ),
];

List<Override> _buildOverrides() => [
  authNotifierProvider.overrideWith((_) {
    final notifier = _MockAuthNotifier(_mockSurveyorAuth);
    return notifier;
  }),
  surveyorTasksProvider.overrideWith((_) async => _mockTasks),
  connectivityProvider.overrideWith(
    (_) => Stream.value([ConnectivityResult.wifi]),
  ),
];

class _MockAuthNotifier extends StateNotifier<AuthState> {
  _MockAuthNotifier(AuthState state) : super(state);
}
