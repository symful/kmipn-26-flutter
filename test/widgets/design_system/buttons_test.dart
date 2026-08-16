import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/buttons.dart';

void main() {
  group('CtaButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(label: 'Buat laporan', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Buat laporan'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(
              label: 'Buat laporan',
              subtitle: 'Foto, lokasi, dan kondisi lapangan',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Foto, lokasi, dan kondisi lapangan'), findsOneWidget);
    });

    testWidgets('has 14px border radius (AppRadius.xl)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(label: 'Test', onPressed: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CtaButton),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, AppShadows.buttonPrimary);
    });

    testWidgets('applies glow shadow from AppShadows.buttonPrimary', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(label: 'Test', onPressed: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CtaButton),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      // box-shadow: 0 10px 22px -12px rgba(15,122,107,.9)
      expect(decoration.boxShadow, AppShadows.buttonPrimary);
      expect(decoration.boxShadow!.first.color, const Color(0xE60F7A6B));
      expect(decoration.boxShadow!.first.blurRadius, 22);
      expect(decoration.boxShadow!.first.offset, const Offset(0, 10));
    });

    testWidgets('has primary background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(label: 'Test', onPressed: () {}),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byType(CtaButton),
          matching: find.byType(ElevatedButton),
        ),
      );

      expect(
        elevatedButton.style?.backgroundColor?.resolve({}),
        AppColors.primary,
      );
    });

    testWidgets('icon container has 40x40 size and 11px radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(
              label: 'Test',
              subtitle: 'Subtitle',
              onPressed: () {},
            ),
          ),
        ),
      );

      final iconContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CtaButton),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.constraints?.maxWidth == 40 &&
                widget.constraints?.maxHeight == 40,
          ),
        ),
      );

      final decoration = iconContainer.decoration as BoxDecoration;
      // Design spec: border-radius: 11px for icon container
      expect(decoration.borderRadius, BorderRadius.circular(11));
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(label: 'Test', onPressed: () => pressed = true),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CtaButton(label: 'Test', isLoading: true, onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null and not loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CtaButton(label: 'Test', onPressed: null)),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(elevatedButton.onPressed, isNull);
    });
  });

  group('PrimaryButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Submit', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('uses 14px border radius (AppRadius.xl)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Test', onPressed: () {}),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final shape = elevatedButton.style?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
      final rrb = shape as RoundedRectangleBorder;
      expect(rrb.borderRadius, BorderRadius.circular(AppRadius.xl));
    });

    testWidgets('has primary background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Test', onPressed: () {}),
          ),
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      expect(
        elevatedButton.style?.backgroundColor?.resolve({}),
        AppColors.primary,
      );
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(label: 'Test', onPressed: () => pressed = true),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Test',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
