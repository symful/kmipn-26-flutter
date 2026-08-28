import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sigap_card.dart';

void main() {
  group('SigapCard', () {
    testWidgets('renders child and finds one widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SigapCard(child: Text('Hello'))),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('has default padding of 16px all sides', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SigapCard(child: SizedBox(width: 100, height: 100)),
          ),
        ),
      );

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      // First Container is the base card
      expect(containers.first.padding, const EdgeInsets.all(16));
    });

    testWidgets('accepts custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SigapCard(
              padding: EdgeInsets.all(8),
              child: SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      expect(containers.first.padding, const EdgeInsets.all(8));
    });

    testWidgets('borderLeftColor produces a 4px-wide left colored strip', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SigapCard(
              borderLeftColor: SigapColors.perluTindakan,
              child: const Text('severity card'),
            ),
          ),
        ),
      );

      // Find all Positioned widgets — the left border is a Positioned with width=4
      final positioned = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .toList();

      // positioned[0] = left border strip (width=4, full height)
      // positioned[1] = top border strip (if present)
      expect(positioned.length, greaterThanOrEqualTo(1));

      // Left border is the first Positioned with width=4
      final leftBorder = positioned.first;
      expect(leftBorder.width, 4);
      expect(leftBorder.left, 0);
      expect(leftBorder.top, 0);
      expect(leftBorder.bottom, 0);
    });

    testWidgets('borderTopColor produces a 3px-tall top colored strip', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SigapCard(
              borderTopColor: SigapColors.selesai,
              child: const Text('status card'),
            ),
          ),
        ),
      );

      final positioned = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .toList();

      expect(positioned.length, greaterThanOrEqualTo(1));

      // Top border is the first Positioned with height=3
      final topBorder = positioned.first;
      expect(topBorder.height, 3);
      expect(topBorder.top, 0);
    });

    testWidgets('both borderLeftColor and borderTopColor can coexist', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SigapCard(
              borderLeftColor: SigapColors.perluTindakan,
              borderTopColor: SigapColors.selesai,
              child: const Text('combo card'),
            ),
          ),
        ),
      );

      final positioned = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .toList();

      // 2 positioned: left border (width=4) + top border (height=3)
      expect(positioned.length, 2);

      // Find left border (width=4)
      final leftBorder = positioned.first;
      expect(leftBorder.width, 4);

      // Find top border (height=3)
      final topBorder = positioned[1];
      expect(topBorder.height, 3);
    });

    testWidgets('surface color is SigapColors.surface', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SigapCard(child: Text('surface test'))),
        ),
      );

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final baseCard = containers.first;
      final decoration = baseCard.decoration as BoxDecoration;

      expect(decoration.color, SigapColors.surface);
    });

    testWidgets('base card border radius is 12 (SigapRadius.x12)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SigapCard(child: Text('radius test'))),
        ),
      );

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final baseCard = containers.first;
      final decoration = baseCard.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(SigapRadius.x12));
    });

    testWidgets('base card has uniform 1px SigapColors.border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SigapCard(child: Text('border test'))),
        ),
      );

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final baseCard = containers.first;
      final decoration = baseCard.decoration as BoxDecoration;

      expect(decoration.border, Border.all(color: SigapColors.border));
    });
  });
}
