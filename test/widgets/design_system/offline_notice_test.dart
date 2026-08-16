import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/offline_notice.dart';

void main() {
  group('OfflineNotice', () {
    testWidgets('renders with amber background and border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 2,
              title: '2 laporan belum tersinkron',
              description: 'Aman tersimpan di perangkat.',
            ),
          ),
        ),
      );

      // Find the main container with amber styling
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.warningBg);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.lg));
    });

    testWidgets('displays pending count in amber badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 2,
              title: '2 laporan belum tersinkron',
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('displays title text with correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 2,
              title: '2 laporan belum tersinkron',
              description: 'Aman tersimpan di perangkat.',
            ),
          ),
        ),
      );

      final titleFinder = find.text('2 laporan belum tersinkron');
      expect(titleFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.fontSize, AppTypography.size13_5);
      expect(textWidget.style?.fontWeight, FontWeight.w600);
      expect(textWidget.style?.color, AppColors.warningTextStrong);
    });

    testWidgets('displays description text with correct styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 2,
              title: '2 laporan belum tersinkron',
              description: 'Aman tersimpan di perangkat.',
            ),
          ),
        ),
      );

      final descFinder = find.text('Aman tersimpan di perangkat.');
      expect(descFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(descFinder);
      expect(textWidget.style?.fontSize, AppTypography.size12);
      expect(textWidget.style?.color, AppColors.warningText);
    });

    testWidgets('displays action link when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 2,
              title: '2 laporan belum tersinkron',
              description: 'Aman tersimpan di perangkat.',
              actionText: 'Buka Pusat Sinkronisasi →',
            ),
          ),
        ),
      );

      expect(find.text('Buka Pusat Sinkronisasi →'), findsOneWidget);
    });

    testWidgets('hides badge when pending count is zero', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 0,
              title: 'Tidak ada koneksi internet',
              description: 'Pastikan Wi-Fi aktif.',
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('calls onActionTap when action is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 2,
              title: '2 laporan belum tersinkron',
              description: 'Aman tersimpan di perangkat.',
              actionText: 'Buka Pusat Sinkronisasi →',
              onActionTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Pusat Sinkronisasi →'));
      expect(tapped, isTrue);
    });

    testWidgets('does not render action link when actionText is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineNotice(
              pendingCount: 2,
              title: '2 laporan belum tersinkron',
              description: 'Aman tersimpan di perangkat.',
            ),
          ),
        ),
      );

      // Should only have title and description, no link
      expect(find.text('2 laporan belum tersinkron'), findsOneWidget);
      expect(find.text('Aman tersimpan di perangkat.'), findsOneWidget);
      // No link text widget (GestureDetector with null action should not be rendered)
    });

    group('factory constructors', () {
      testWidgets('OfflineNotice.syncPending creates correct widget', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineNotice.syncPending(count: 3, onActionTap: () {}),
            ),
          ),
        );

        expect(find.text('3'), findsOneWidget);
        expect(find.text('3 laporan belum tersinkron'), findsOneWidget);
        expect(
          find.text(
            'Aman tersimpan di perangkat. Akan terkirim otomatis saat ada koneksi.',
          ),
          findsOneWidget,
        );
        expect(find.text('Buka Pusat Sinkronisasi →'), findsOneWidget);
      });

      testWidgets('OfflineNotice.offline creates offline notice', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineNotice.offline(
                message: 'Tidak ada koneksi internet',
              ),
            ),
          ),
        );

        expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
        expect(
          find.text('Pastikan Wi-Fi atau data seluler aktif.'),
          findsOneWidget,
        );
      });
    });
  });
}
