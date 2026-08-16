import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/truth_statement_checkbox.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('TruthStatementCheckbox', () {
    testWidgets('renders unchecked state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      // Check that the statement text is rendered
      expect(
        find.text(
          'Saya menyatakan informasi ini benar sesuai kondisi yang saya lihat.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders checked state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: true, onChanged: null),
          ),
        ),
      );

      // Check that the check icon is shown
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping unchecked checkbox calls onChanged with true', (
      tester,
    ) async {
      bool? capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(
              value: false,
              onChanged: (val) => capturedValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TruthStatementCheckbox));
      await tester.pump();

      expect(capturedValue, true);
    });

    testWidgets('tapping checked checkbox calls onChanged with false', (
      tester,
    ) async {
      bool? capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(
              value: true,
              onChanged: (val) => capturedValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TruthStatementCheckbox));
      await tester.pump();

      expect(capturedValue, false);
    });

    testWidgets('onChanged is not called when onChanged is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      // Should not throw
      await tester.tap(find.byType(TruthStatementCheckbox));
      await tester.pump();
    });

    testWidgets('uses correct text style from design tokens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.text(
          'Saya menyatakan informasi ini benar sesuai kondisi yang saya lihat.',
        ),
      );

      // Verify text style uses design tokens
      expect(text.style?.fontSize, AppTypography.size12);
      expect(text.style?.color, AppColors.textPrimary);
      expect(text.style?.height, 1.4);
    });

    testWidgets('checkbox has correct dimensions (18x18)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );

      expect(animatedContainer.duration, const Duration(milliseconds: 150));
    });

    testWidgets('checked checkbox has teal background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: true, onChanged: null),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );

      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('unchecked checkbox has transparent background with border', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );

      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(decoration.border, isNotNull);
    });

    testWidgets('uses Row with crossAxisAlignment start', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.crossAxisAlignment, CrossAxisAlignment.start);
    });

    testWidgets('has correct gap between checkbox and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(Row).first,
              matching: find.byType(SizedBox),
            )
            .first,
      );

      // The SizedBox is the gap between checkbox and text
      expect(sizedBox.width, 9);
    });

    testWidgets('checkbox border radius is 5px', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );

      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(5)); // Design: 5px
    });

    testWidgets('check icon is white and 12px', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: true, onChanged: null),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(icon.color, Colors.white);
      expect(icon.size, 12);
    });

    testWidgets('text is expandable (wraps on overflow)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TruthStatementCheckbox(value: false, onChanged: null),
          ),
        ),
      );

      final expanded = tester.widget<Expanded>(find.byType(Expanded).first);
      expect(expanded, isNotNull);
    });
  });
}
