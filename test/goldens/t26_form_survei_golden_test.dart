// Golden test for S-04: FormSurveiScreen
//
// FormSurveiScreen is already wrapped in PhoneFrame internally (both
// success and non-success states). We test the non-success state with
// mock GPS/photo state.
//
// Run with: flutter test --update-goldens
// Then:     flutter test  (to verify)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/surveyor/form_survei.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

void main() {
  group('T26 Golden: S-04 FormSurveiScreen', () {
    testWidgets('S-04 form survei matches golden', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _buildOverrides(),
          child: const MaterialApp(home: FormSurveiScreen(taskId: 'TGS-3402')),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(PhoneFrame), findsOneWidget);
      await expectLater(
        find.byType(PhoneFrame),
        matchesGoldenFile('goldens/s-04-form-survei.png'),
      );
    });
  });
}

List<Override> _buildOverrides() => [
  databaseProvider.overrideWith((_) => _MockDb()),
  surveyorTaskRepositoryProvider.overrideWith((_) => _MockSurveyorTaskRepo()),
  syncQueueRepositoryProvider.overrideWith((_) => _MockSyncQueueRepo()),
  apiClientProvider.overrideWith((_) => _MockApiClient()),
];

class _MockDb {}

class _MockSurveyorTaskRepo {}

class _MockSyncQueueRepo {}

class _MockApiClient {}
