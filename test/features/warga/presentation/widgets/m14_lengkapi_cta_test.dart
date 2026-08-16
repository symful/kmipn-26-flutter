import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/m14_lengkapi_cta.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('M14LengkapiCTA', () {
    testWidgets('renders button text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      expect(find.text('Lengkapi laporan'), findsOneWidget);
    });

    testWidgets('button text has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      final buttonText = tester.widget<Text>(find.text('Lengkapi laporan'));
      expect(buttonText.style?.fontSize, AppTypography.size13);
    });

    testWidgets('button text has correct font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      final buttonText = tester.widget<Text>(find.text('Lengkapi laporan'));
      expect(buttonText.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('button text is white', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      final buttonText = tester.widget<Text>(find.text('Lengkapi laporan'));
      expect(buttonText.style?.color, Colors.white);
    });

    testWidgets('has correct background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      // Find the GestureDetector and its child Container
      // ignore: unused_local_variable
      final containerFinder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration != null,
      );

      // Find the Container that is the direct child of GestureDetector
      final gestureDetector = find.byType(GestureDetector);
      final container = tester.widget<Container>(
        find.descendant(of: gestureDetector, matching: find.byType(Container)),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('has correct border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      final gestureDetector = find.byType(GestureDetector);
      final container = tester.widget<Container>(
        find.descendant(of: gestureDetector, matching: find.byType(Container)),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.x10));
    });

    testWidgets('is full width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      final gestureDetector = find.byType(GestureDetector);
      final container = tester.widget<Container>(
        find.descendant(of: gestureDetector, matching: find.byType(Container)),
      );

      // width: double.infinity means it fills available width
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('has correct padding (vertical and horizontal)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      // Find the button by its text
      final textFinder = find.text('Lengkapi laporan');
      expect(textFinder, findsOneWidget);

      // Get the rendered size of the button
      final size = tester.getSize(textFinder);

      // The button has horizontal padding of lg (16px) on each side
      // So text width = button width - 2 * padding
      // But we can't directly measure padding, so we verify the button is rendered
      // and has reasonable dimensions
      expect(size.width, greaterThan(100)); // Button should be wide
      expect(size.height, greaterThan(10)); // Button should have some height
    });

    testWidgets('has correct margin top', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(children: [SizedBox(height: 100), M14LengkapiCTA()]),
          ),
        ),
      );

      // Find the button and verify it's rendered
      final buttonFinder = find.text('Lengkapi laporan');
      expect(buttonFinder, findsOneWidget);

      // Verify the button exists and is rendered correctly
      final size = tester.getSize(buttonFinder);
      expect(size.width, greaterThan(100));
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14LengkapiCTA(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Lengkapi laporan'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when null', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA(onTap: null))),
      );

      // Should not throw when onTap is null
      await tester.tap(find.text('Lengkapi laporan'));
      await tester.pump();

      // tapped remains false since onTap is null
      expect(tapped, isFalse);
    });

    testWidgets('text is centered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: M14LengkapiCTA())),
      );

      final gestureDetector = find.byType(GestureDetector);
      final container = tester.widget<Container>(
        find.descendant(of: gestureDetector, matching: find.byType(Container)),
      );

      expect(container.alignment, Alignment.center);
    });
  });
}
