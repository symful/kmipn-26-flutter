import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/m14_privacy_notice.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('M14PrivacyNotice', () {
    testWidgets('renders info icon with "i" text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      expect(find.text('i'), findsOneWidget);
    });

    testWidgets('renders full privacy text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      expect(
        find.text(
          'Identitas & lokasi presisi Anda hanya terlihat oleh petugas terkait. '
          'Publik melihat lokasi yang digeneralisasi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders compact privacy text when compact is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M14PrivacyNotice(compact: true)),
        ),
      );

      expect(
        find.text(
          'Identitas & lokasi presisi hanya terlihat petugas. '
          'Publik melihat lokasi digeneralisasi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not render compact text when compact is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      expect(
        find.text(
          'Identitas & lokasi presisi hanya terlihat petugas. '
          'Publik melihat lokasi digeneralisasi.',
        ),
        findsNothing,
      );
    });

    testWidgets('container has correct background color (bgSoft)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.bgSoft);
    });

    testWidgets('container has 11px border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(
        decoration.borderRadius?.resolve(TextDirection.ltr).topLeft.x,
        11.0,
      );
    });

    testWidgets('has info icon with circular border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      // Find containers with circular shape
      final containers = tester.widgetList<Container>(find.byType(Container));
      final circularContainers = containers.where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(circularContainers.length, greaterThan(0));
    });

    testWidgets('info icon uses textTertiary color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      // Find the "i" text widget
      final iText = tester.widget<Text>(find.text('i'));
      expect(iText.style?.color, AppColors.textTertiary);
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14PrivacyNotice())),
      );

      expect(find.byType(M14PrivacyNotice), findsOneWidget);
    });

    testWidgets('renders inside scrollable parent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: const [M14PrivacyNotice(), SizedBox(height: 100)],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(M14PrivacyNotice), findsOneWidget);
      // Can scroll past it
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pump();
    });
  });
}
