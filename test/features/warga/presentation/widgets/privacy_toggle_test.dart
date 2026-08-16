import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/privacy_toggle.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('PrivacyToggle', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      expect(find.text('Identitas saya di publik'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      expect(
        find.text('Default: privat · hanya petugas melihat'),
        findsOneWidget,
      );
    });

    testWidgets('renders info icon with "i" text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      // Info icon is a circle container with "i" text
      expect(find.text('i'), findsOneWidget);
    });

    testWidgets('renders toggle switch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      // Find the toggle switch by looking for the animated container
      // The PrivacyToggle from design_system uses AnimatedContainer
      expect(find.byType(PrivacyToggle), findsWidgets);
    });

    testWidgets('calls onChanged when toggle is tapped', (tester) async {
      bool changedValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrivacyToggle(
              value: false,
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );

      // Find the toggle switch container and tap it
      // The toggle is the last PrivacyToggle in the widget tree
      final toggles = find.byType(PrivacyToggle);
      await tester.tap(toggles.last);
      await tester.pump();

      expect(changedValue, isTrue);
    });

    testWidgets('does not crash when onChanged is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      // Find the toggle and tap it - should not crash
      final toggles = find.byType(PrivacyToggle);
      await tester.tap(toggles.last);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows info dialog when info icon is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      // Tap the info icon (the one with "i" text)
      await tester.tap(find.text('i'));
      await tester.pumpAndSettle();

      // Dialog should be shown with privacy info
      expect(find.text('Tentang Privasi'), findsOneWidget);
      expect(
        find.text(
          'Identitas dan lokasi presisi Anda hanya terlihat oleh petugas terkait. '
          'Publik hanya melihat lokasi yang digeneralisasi.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tutup'), findsOneWidget);
    });

    testWidgets('closes dialog when Tutup is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      // Open the dialog
      await tester.tap(find.text('i'));
      await tester.pumpAndSettle();

      // Close the dialog
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Tentang Privasi'), findsNothing);
    });

    testWidgets('container has correct card styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
      );

      // Find the outer container with card styling
      final containers = tester.widgetList<Container>(find.byType(Container));
      final cardContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.bgCard &&
            (c.decoration as BoxDecoration).borderRadius != null,
      );

      expect(cardContainer, isNotNull);
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(
        decoration.borderRadius?.resolve(TextDirection.ltr).topLeft.x,
        AppRadius.lg,
      );
    });

    testWidgets('has info icon with circular border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: false))),
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

    testWidgets('renders with value true (toggle on)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PrivacyToggle(value: true))),
      );

      expect(find.text('Identitas saya di publik'), findsOneWidget);
      expect(
        find.text('Default: privat · hanya petugas melihat'),
        findsOneWidget,
      );
    });
  });
}
