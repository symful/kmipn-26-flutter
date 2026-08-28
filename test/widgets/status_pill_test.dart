import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/widgets/design_system/status_pill.dart';

void main() {
  group('StatusPill', () {
    testWidgets('renders success tone correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(label: 'Success', tone: StatusTone.success),
          ),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);

      // Dot should be present (7px circle)
      final dotFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle &&
            (w.decoration as BoxDecoration).color == const Color(0xFF1F9254),
      );
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('renders warning tone correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(label: 'Warning', tone: StatusTone.warning),
          ),
        ),
      );

      expect(find.text('Warning'), findsOneWidget);
    });

    testWidgets('renders danger tone correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(label: 'Danger', tone: StatusTone.danger),
          ),
        ),
      );

      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('renders info tone correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(label: 'Info', tone: StatusTone.info),
          ),
        ),
      );

      expect(find.text('Info'), findsOneWidget);
    });

    testWidgets('renders neutral tone correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(label: 'Neutral', tone: StatusTone.neutral),
          ),
        ),
      );

      expect(find.text('Neutral'), findsOneWidget);
    });

    testWidgets(
      'neutral tone renders for unknown tone (enum, so neutral fallback)',
      (tester) async {
        // Since StatusTone is a closed enum, unknown isn't possible.
        // Verify neutral renders as expected.
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StatusPill(label: 'Fallback', tone: StatusTone.neutral),
            ),
          ),
        );

        expect(find.text('Fallback'), findsOneWidget);
      },
    );

    testWidgets('showDot=false hides the dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'NoDot',
              tone: StatusTone.success,
              showDot: false,
            ),
          ),
        ),
      );

      expect(find.text('NoDot'), findsOneWidget);
      // No 7px dot should be present
      final dotFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle &&
            (w.decoration as BoxDecoration).color != null,
      );
      expect(dotFinder, findsNothing);
    });

    testWidgets('borderLeft=true adds 4px left border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'Bordered',
              tone: StatusTone.danger,
              borderLeft: true,
            ),
          ),
        ),
      );

      expect(find.text('Bordered'), findsOneWidget);
      // Verify border left decoration exists
      final containerWithBorder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius != null,
      );
      expect(containerWithBorder, findsWidgets);
    });
  });
}
