// Golden test for M-11: ReviewKirimanScreen
//
// ReviewKirimanScreen is NOT wrapped in PhoneFrame by default.
// We wrap it in PhoneFrame here (392×812) for golden comparison.
//
// Run with: flutter test --update-goldens
// Then:     flutter test  (to verify)

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/review_kiriman_screen.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';

void main() {
  group('T26 Golden: M-11 ReviewKirimanScreen', () {
    testWidgets('M-11 review kiriman matches golden', (tester) async {
      // Build the screen wrapped in PhoneFrame
      await tester.pumpWidget(
        ProviderScope(
          overrides: _buildOverrides(),
          child: MaterialApp(
            home: PhoneFrame(
              child: ReviewKirimanScreen(
                description:
                    'Lubang jalan di depan rumah berukuran 50cm, '
                    'sangat berbahaya bagi pengguna jalan dan perlu perhatian '
                    'sejahtra dari petugas.',
                lat: -6.9175,
                lng: 107.6191,
                categoryId: 'cat-jalan',
                categoryName: 'JALAN',
                duplicateMatches: [
                  DuplicateMatch(
                    reportId: 'dup-001',
                    description: 'Lubang di JL Sudirman',
                    lat: -6.9175,
                    lng: 107.6191,
                    createdAt: DateTime(2026, 8, 15),
                    distance: '25m',
                    similarityScore: 0.85,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(PhoneFrame), findsOneWidget);
      await expectLater(
        find.byType(PhoneFrame),
        matchesGoldenFile('goldens/m-11-review-kiriman.png'),
      );
    });
  });
}

List<Override> _buildOverrides() => [
  connectivityProvider.overrideWith(
    (_) => Stream.value([ConnectivityResult.wifi]),
  ),
];
