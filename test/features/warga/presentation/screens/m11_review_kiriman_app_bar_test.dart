import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/screens/m11_review_kiriman_app_bar.dart';
import 'package:sigap/widgets/design_system/stepper_5.dart';

void main() {
  group('M11ReviewKirimanAppBar', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 5)),
        ),
      );

      expect(find.text('Review laporan'), findsOneWidget);
    });

    testWidgets('renders back arrow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 5)),
        ),
      );

      expect(find.text('←'), findsOneWidget);
    });

    testWidgets('renders stepper widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 5)),
        ),
      );

      expect(find.byType(Stepper5), findsOneWidget);
    });

    testWidgets('displays correct step in subtitle for step 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 1)),
        ),
      );

      expect(find.text('Langkah 1 dari 5'), findsOneWidget);
    });

    testWidgets('displays correct step in subtitle for step 3', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 3)),
        ),
      );

      expect(find.text('Langkah 3 dari 5'), findsOneWidget);
    });

    testWidgets('displays correct step in subtitle for step 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 5)),
        ),
      );

      expect(find.text('Langkah 5 dari 5'), findsOneWidget);
    });

    testWidgets('passes currentStep to Stepper5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 4)),
        ),
      );

      final stepper5 = tester.widget<Stepper5>(find.byType(Stepper5));
      expect(stepper5.currentStep, 4);
    });

    testWidgets('calls onBack when back arrow tapped', (tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M11ReviewKirimanAppBar(
              currentStep: 5,
              onBack: () => backPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('←'));
      await tester.pump();

      expect(backPressed, true);
    });

    testWidgets('does not throw when onBack is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 5)),
        ),
      );

      // Should not throw when tapping back with null callback
      await tester.tap(find.text('←'));
      await tester.pump();
    });

    testWidgets('renders correctly at step 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 2)),
        ),
      );

      expect(find.text('Langkah 2 dari 5'), findsOneWidget);
      expect(find.byType(Stepper5), findsOneWidget);
    });

    testWidgets('renders correctly at step 4', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M11ReviewKirimanAppBar(currentStep: 4)),
        ),
      );

      expect(find.text('Langkah 4 dari 5'), findsOneWidget);
      expect(find.byType(Stepper5), findsOneWidget);
    });
  });
}
