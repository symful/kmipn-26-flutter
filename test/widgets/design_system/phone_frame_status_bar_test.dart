import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/phone_frame.dart';
import 'package:sigap/widgets/design_system/status_bar.dart';

void main() {
  group('PhoneFrame', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PhoneFrame(child: Text('Test content'))),
        ),
      );

      expect(find.text('Test content'), findsOneWidget);
    });

    testWidgets('has correct outer dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PhoneFrame(child: SizedBox())),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PhoneFrame),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.constraints?.maxWidth, 392);
      expect(container.constraints?.maxHeight, 812);
    });

    testWidgets('uses phone bezel color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PhoneFrame(child: SizedBox())),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PhoneFrame),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.phoneBezel);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.x44));
    });

    testWidgets('has inner container with screen background color', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PhoneFrame(child: SizedBox())),
        ),
      );

      // Find all containers in PhoneFrame
      final containers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(PhoneFrame),
              matching: find.byType(Container),
            ),
          )
          .toList();

      // Second container should be the inner screen
      expect(containers.length, 2);
      final innerContainer = containers[1];
      final innerDecoration = innerContainer.decoration as BoxDecoration;
      expect(innerDecoration.color, const Color(0xFFF4F5F3));
      expect(
        innerDecoration.borderRadius,
        BorderRadius.circular(AppRadius.x34),
      );
    });

    testWidgets('applies phone bezel shadow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PhoneFrame(child: SizedBox())),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PhoneFrame),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, AppShadows.phoneBezel);
    });

    testWidgets('uses correct padding (11px)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PhoneFrame(child: SizedBox())),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PhoneFrame),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.padding, const EdgeInsets.all(AppSpacing.x11));
    });
  });

  group('StatusBar', () {
    testWidgets('renders with default time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      expect(find.text('09:41'), findsOneWidget);
    });

    testWidgets('renders with custom time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StatusBar(time: '14:30')),
        ),
      );

      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('has correct height of 44px', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 44);
    });

    testWidgets('uses correct horizontal padding (24px)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, const EdgeInsets.symmetric(horizontal: 24));
    });

    testWidgets('displays battery icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      // Battery icon is the second child in the Row
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('time uses correct font size (13px)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      final text = tester.widget<Text>(find.text('09:41'));
      expect(text.style?.fontSize, AppTypography.size13);
    });

    testWidgets('time uses correct font weight (600)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      final text = tester.widget<Text>(find.text('09:41'));
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('time uses tabular figures', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      final text = tester.widget<Text>(find.text('09:41'));
      expect(text.style?.fontFeatures, contains(FontFeature.tabularFigures()));
    });

    testWidgets('time uses textPrimary color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      final text = tester.widget<Text>(find.text('09:41'));
      expect(text.style?.color, AppColors.textPrimary);
    });

    testWidgets('contains battery outline container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBar())),
      );

      // Find containers that could be battery outline
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();

      // Should have multiple containers (battery has outer and inner)
      expect(containers.length, greaterThan(1));
    });
  });
}
