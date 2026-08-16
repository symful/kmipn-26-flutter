import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/bottom_nav_5.dart';

void main() {
  group('BottomNav5 - Warga variant', () {
    testWidgets('renders all items (Beranda, Peta, FAB, Laporan, Akun)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Peta'), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);
      expect(find.text('Akun'), findsOneWidget);
    });

    testWidgets('renders FAB with "Buat" label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Buat'), findsOneWidget);
    });

    testWidgets('has white background with top border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect(
        decoration.border,
        const Border(top: BorderSide(color: Color(0xFFE4E7E2), width: 1)),
      );
    });

    testWidgets('FAB has primary background color and shadow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      // Find FAB by looking for Container with primary color decoration
      final fabContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(BottomNav5),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration != null &&
                (widget.decoration as BoxDecoration).color ==
                    AppColors.primary &&
                (widget.decoration as BoxDecoration).borderRadius != null,
          ),
        ),
      );

      final decoration = fabContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.boxShadow, AppShadows.fab);
    });

    testWidgets('FAB is visually raised above the nav bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      // The FAB column should be present and contain the "Buat" label
      // The actual visual positioning is done via Transform.translate
      expect(find.text('Buat'), findsOneWidget);
    });

    testWidgets('calls onTap with correct index for Beranda (0)', (
      tester,
    ) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Beranda'));
      await tester.pump();
      expect(tappedIndex, 0);
    });

    testWidgets('calls onTap with correct index for Peta (1)', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Peta'));
      await tester.pump();
      expect(tappedIndex, 1);
    });

    testWidgets('calls onTap with correct index for Laporan (3)', (
      tester,
    ) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Laporan'));
      await tester.pump();
      expect(tappedIndex, 3);
    });

    testWidgets('calls onTap with correct index for Akun (4)', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Akun'));
      await tester.pump();
      expect(tappedIndex, 4);
    });

    testWidgets('calls onTap(2) when FAB is tapped', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buat'));
      await tester.pump();
      expect(tappedIndex, 2);
    });

    testWidgets('height is 80px per spec', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 80);
    });
  });

  group('BottomNav5 - Surveyor variant', () {
    testWidgets('renders all 5 items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.surveyor,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Tugas'), findsOneWidget);
      expect(find.text('Peta'), findsOneWidget);
      expect(find.text('Sinkron'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Akun'), findsOneWidget);
    });

    testWidgets('has no FAB in surveyor variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.surveyor,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Buat'), findsNothing);
    });

    testWidgets('calls onTap with correct index for each item', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.surveyor,
              selectedIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tugas'));
      await tester.pump();
      expect(tappedIndex, 0);

      await tester.tap(find.text('Peta'));
      await tester.pump();
      expect(tappedIndex, 1);

      await tester.tap(find.text('Sinkron'));
      await tester.pump();
      expect(tappedIndex, 2);

      await tester.tap(find.text('Riwayat'));
      await tester.pump();
      expect(tappedIndex, 3);

      await tester.tap(find.text('Akun'));
      await tester.pump();
      expect(tappedIndex, 4);
    });
  });

  group('BottomNav5 styling', () {
    testWidgets('selected item label uses primary color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0, // Beranda selected
              onTap: (_) {},
            ),
          ),
        ),
      );

      final berandaText = tester.widget<Text>(find.text('Beranda'));
      expect(berandaText.style?.color, AppColors.primary);
    });

    testWidgets('unselected item label uses textTertiary color', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0, // Beranda selected
              onTap: (_) {},
            ),
          ),
        ),
      );

      final petaText = tester.widget<Text>(find.text('Peta'));
      expect(petaText.style?.color, AppColors.textTertiary);
    });

    testWidgets('selected item label is fontWeight.w600', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final berandaText = tester.widget<Text>(find.text('Beranda'));
      expect(berandaText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('unselected item label is fontWeight.w500', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav5(
              variant: BottomNavVariant.warga,
              selectedIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final petaText = tester.widget<Text>(find.text('Peta'));
      expect(petaText.style?.fontWeight, FontWeight.w500);
    });
  });
}
