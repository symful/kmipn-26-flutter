import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/similar_case_actions.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('SimilarCaseActions', () {
    testWidgets('renders both action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      expect(find.text('Tambahkan bukti ke kasus ini'), findsOneWidget);
      expect(find.text('Buat terpisah'), findsOneWidget);
    });

    testWidgets('renders primary button with info color background', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      // Find the primary button container (has solid info color background)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final primaryContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.info &&
            (c.decoration as BoxDecoration).borderRadius != null,
      );
      expect(primaryContainer, isNotNull);
    });

    testWidgets('renders secondary button with outlined style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      // Find containers with border (outlined style)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final outlinedContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).border != null,
      );
      expect(outlinedContainer, isNotNull);
    });

    testWidgets('primary button text is white', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      // First "Tambahkan bukti" text should have white color
      final primaryText = textWidgets.firstWhere(
        (t) => t.data == 'Tambahkan bukti ke kasus ini',
      );
      expect((primaryText.style as TextStyle).color, Colors.white);
    });

    testWidgets('secondary button text is info color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final secondaryText = textWidgets.firstWhere(
        (t) => t.data == 'Buat terpisah',
      );
      expect((secondaryText.style as TextStyle).color, AppColors.info);
    });

    testWidgets('calls onLinkToCase when primary button tapped', (
      tester,
    ) async {
      bool linkCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimilarCaseActions(onLinkToCase: () => linkCalled = true),
          ),
        ),
      );

      await tester.tap(find.text('Tambahkan bukti ke kasus ini'));
      expect(linkCalled, isTrue);
    });

    testWidgets('calls onCreateSeparate when secondary button tapped', (
      tester,
    ) async {
      bool separateCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimilarCaseActions(
              onCreateSeparate: () => separateCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buat terpisah'));
      expect(separateCalled, isTrue);
    });

    testWidgets('does not crash when callbacks are null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      // Should not throw when tapping with null callbacks
      await tester.tap(find.text('Tambahkan bukti ke kasus ini'));
      await tester.tap(find.text('Buat terpisah'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses Row with two Expanded children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Expanded), findsNWidgets(2));
    });

    testWidgets('buttons have correct border radius (x9 = 9px)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final boxedContainers = containers.where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).borderRadius != null,
      );

      for (final container in boxedContainers) {
        final borderRadius =
            (container.decoration as BoxDecoration).borderRadius;
        expect(borderRadius, isNotNull);
        // AppRadius.x9 is a double value - verify it's set as BorderRadius.circular(AppRadius.x9)
        final resolved = borderRadius?.resolve(TextDirection.ltr);
        expect(resolved?.topLeft.x, AppRadius.x9);
      }
    });

    testWidgets('primary button has no border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      // Primary button is solid color, no border
      final primaryContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.info,
      );
      final border = (primaryContainer.decoration as BoxDecoration).border;
      expect(border, isNull);
    });

    testWidgets('secondary button has infoChartBar border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SimilarCaseActions())),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final outlinedContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).border != null,
      );
      final border = (outlinedContainer.decoration as BoxDecoration).border;
      expect(border?.top.color, AppColors.infoChartBar);
    });
  });
}
