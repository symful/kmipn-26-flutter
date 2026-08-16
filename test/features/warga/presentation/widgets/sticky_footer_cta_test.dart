import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/sticky_footer_cta.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('StickyFooterCTA', () {
    testWidgets('renders with default label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StickyFooterCTA())),
      );

      expect(find.text('Simpan dan sinkronkan nanti'), findsOneWidget);
    });

    testWidgets('renders with custom button label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StickyFooterCTA(buttonLabel: 'Kirim Laporan')),
        ),
      );

      expect(find.text('Kirim Laporan'), findsOneWidget);
    });

    testWidgets('does not show offline notice when isOffline is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StickyFooterCTA(isOffline: false)),
        ),
      );

      expect(
        find.text('Tidak ada koneksi — laporan akan masuk antrean.'),
        findsNothing,
      );
    });

    testWidgets('shows offline notice when isOffline is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StickyFooterCTA(isOffline: true)),
        ),
      );

      expect(
        find.text('Tidak ada koneksi — laporan akan masuk antrean.'),
        findsOneWidget,
      );
    });

    testWidgets('shows amber dot when offline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StickyFooterCTA(isOffline: true)),
        ),
      );

      // Find the amber dot container
      final dotFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == AppColors.warning &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(dotFinder, findsOneWidget);
    });

    testWidgets('calls onSubmit when button tapped', (tester) async {
      bool submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyFooterCTA(onSubmit: () => submitCalled = true),
          ),
        ),
      );

      await tester.tap(find.text('Simpan dan sinkronkan nanti'));
      await tester.pump();

      expect(submitCalled, isTrue);
    });

    testWidgets('does not call onSubmit when isLoading', (tester) async {
      bool submitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyFooterCTA(
              isLoading: true,
              onSubmit: () => submitCalled = true,
            ),
          ),
        ),
      );

      // When loading, the button shows CircularProgressIndicator, not text
      // So tapping the loading indicator should not trigger onSubmit
      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();

      expect(submitCalled, isFalse);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StickyFooterCTA(isLoading: true)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('button has correct background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StickyFooterCTA())),
      );

      final buttonContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(StickyFooterCTA),
          matching: find.byType(Container).last,
        ),
      );

      final decoration = buttonContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('button has correct border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StickyFooterCTA())),
      );

      final buttonContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(StickyFooterCTA),
          matching: find.byType(Container).last,
        ),
      );

      final decoration = buttonContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.x12));
    });

    testWidgets('footer has white background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StickyFooterCTA())),
      );

      // The outer container should have bgCard color
      final footerFinder = find.byType(StickyFooterCTA);
      // ignore: unused_local_variable
      final footerWidget = tester.widget<StickyFooterCTA>(footerFinder);

      // Verify by checking the first Container has bgCard
      final containers = tester.widgetList<Container>(
        find.descendant(of: footerFinder, matching: find.byType(Container)),
      );

      // First container should have bgCard background (the footer container)
      final firstContainer = containers.first;
      expect(
        firstContainer.decoration,
        isA<BoxDecoration>().having((d) => d.color, 'color', AppColors.bgCard),
      );
    });

    testWidgets('footer has top border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StickyFooterCTA())),
      );

      final footerFinder = find.byType(StickyFooterCTA);
      final containers = tester.widgetList<Container>(
        find.descendant(of: footerFinder, matching: find.byType(Container)),
      );

      final firstContainer = containers.first;
      final decoration = firstContainer.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect((decoration.border as Border).top.color, AppColors.borderCard);
    });
  });
}
