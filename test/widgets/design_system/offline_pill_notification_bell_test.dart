import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/offline_pill.dart';
import 'package:sigap/widgets/design_system/notification_bell.dart';

void main() {
  group('OfflinePill', () {
    testWidgets('renders Offline text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflinePill())),
      );

      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('has warning background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflinePill())),
      );

      // Find widget with warning background
      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      expect(decoratedBoxes.isNotEmpty, true);
    });

    testWidgets('has 7x7px dot with warning color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflinePill())),
      );

      // Find the DecoratedBox with the circle
      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );
      final circleBox = decoratedBoxes.firstWhere(
        (box) =>
            box.decoration is BoxDecoration &&
            (box.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      final circleDecoration = circleBox.decoration as BoxDecoration;

      expect(circleDecoration.color, AppColors.warning);
    });

    testWidgets('has text with correct style (size 11, weight 600)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: OfflinePill())),
      );

      final text = tester.widget<Text>(find.text('Offline'));
      expect(text.style?.fontSize, AppTypography.size11);
      expect(text.style?.fontWeight, FontWeight.w600);
      expect(text.style?.color, AppColors.warningText);
    });
  });

  group('NotificationBell', () {
    testWidgets('renders notification bell icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationBell())),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders without badge when unreadCount is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationBell())),
      );

      // Default unreadCount is 0, so no badge should be present
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('shows badge when unreadCount is greater than 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationBell(unreadCount: 5)),
        ),
      );

      // When unreadCount > 0, Positioned badge should be present
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('hides badge when unreadCount is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationBell(unreadCount: 0)),
        ),
      );

      // When unreadCount is 0, no Positioned widget (badge) should be present
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('shows badge when unreadCount is 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationBell(unreadCount: 1)),
        ),
      );

      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('badge is positioned correctly (top: -4, right: -4)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationBell(unreadCount: 3)),
        ),
      );

      final positioneds = tester.widgetList<Positioned>(
        find.byType(Positioned),
      );
      expect(positioneds.isNotEmpty, true);

      final badgePositioned = positioneds.first;
      expect(badgePositioned.top, -4);
      expect(badgePositioned.right, -4);
    });

    testWidgets('badge displays correct count text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationBell(unreadCount: 5)),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('badge displays 99+ when count exceeds 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationBell(unreadCount: 150)),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('badge has danger color and circle shape', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: NotificationBell(unreadCount: 1)),
        ),
      );

      // Find the Positioned and get its child Container
      final positioneds = tester.widgetList<Positioned>(
        find.byType(Positioned),
      );
      final badgePositioned = positioneds.first;
      final badgeContainer = badgePositioned.child as Container;

      final decoration = badgeContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.danger);
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('icon container has correct dimensions (34x34)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationBell())),
      );

      // Find the Stack and check its children
      final stack = tester.widget<Stack>(find.byType(Stack).first);
      final firstChild = stack.children.first;
      expect(firstChild, isA<Container>());

      final iconContainer = firstChild as Container;
      expect(iconContainer.constraints?.maxWidth, 34);
      expect(iconContainer.constraints?.maxHeight, 34);
    });

    testWidgets(
      'icon container has correct styling (white bg, border, 10px radius)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: NotificationBell())),
        );

        // Find the Container inside the Stack
        final stack = tester.widget<Stack>(find.byType(Stack).first);
        final firstChild = stack.children.first;

        final iconContainer = firstChild as Container;
        final decoration = iconContainer.decoration as BoxDecoration;

        expect(iconContainer.constraints?.maxWidth, 34);
        expect(iconContainer.constraints?.maxHeight, 34);
        expect(decoration.color, AppColors.bgCard);
        expect(
          decoration.borderRadius,
          BorderRadius.circular(AppRadius.md),
        ); // 10px
      },
    );
  });
}
