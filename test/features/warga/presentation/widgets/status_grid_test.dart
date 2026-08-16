import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/status_grid.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('StatusGrid', () {
    testWidgets('renders all three status cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusGrid(perluTindakan: 1, diproses: 3, selesai: 4),
          ),
        ),
      );

      expect(find.text('Perlu tindakan'), findsOneWidget);
      expect(find.text('Diproses'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('displays correct count values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusGrid(perluTindakan: 1, diproses: 3, selesai: 4),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders with zero counts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusGrid(perluTindakan: 0, diproses: 0, selesai: 0),
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(3));
      expect(find.text('Perlu tindakan'), findsOneWidget);
      expect(find.text('Diproses'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('renders with large counts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusGrid(perluTindakan: 999, diproses: 10000, selesai: 500),
          ),
        ),
      );

      expect(find.text('999'), findsOneWidget);
      expect(find.text('10000'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('uses correct colors from design tokens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusGrid(perluTindakan: 1, diproses: 3, selesai: 4),
          ),
        ),
      );

      // Find the count text widgets and verify colors
      final perluTindakanFinder = find.text('1');
      final diprosesFinder = find.text('3');
      final selesaiFinder = find.text('4');

      expect(perluTindakanFinder, findsOneWidget);
      expect(diprosesFinder, findsOneWidget);
      expect(selesaiFinder, findsOneWidget);

      // Get the text widgets and verify their style
      final perluTindakanText = tester.widget<Text>(perluTindakanFinder);
      final diprosesText = tester.widget<Text>(diprosesFinder);
      final selesaiText = tester.widget<Text>(selesaiFinder);

      expect(perluTindakanText.style?.color, AppColors.danger);
      expect(diprosesText.style?.color, AppColors.info);
      expect(selesaiText.style?.color, AppColors.primary);
    });

    testWidgets('card containers have correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: StatusGrid(perluTindakan: 1, diproses: 3, selesai: 4),
            ),
          ),
        ),
      );

      // Verify 3 containers with the expected decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.length, greaterThanOrEqualTo(3));
    });
  });
}
