import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/location_row_edit.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('LocationRowEdit', () {
    testWidgets('renders location label and address with accuracy', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Jl. Raya Ciburuy · Akurasi baik '), findsOneWidget);
    });

    testWidgets('renders edit icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('edit icon uses primary color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.edit_outlined));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('label uses textTertiary color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('Lokasi'));
      expect(label.style?.color, AppColors.textTertiary);
    });

    testWidgets('label uses size12 typography', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('Lokasi'));
      expect(label.style?.fontSize, AppTypography.size12);
    });

    testWidgets('value uses textPrimary color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      // The value row contains the address text
      final valueText = tester.widget<Text>(
        find.text('Jl. Raya Ciburuy · Akurasi baik '),
      );
      expect(valueText.style?.color, AppColors.textPrimary);
    });

    testWidgets('value uses fontWeight 600', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final valueText = tester.widget<Text>(
        find.text('Jl. Raya Ciburuy · Akurasi baik '),
      );
      expect(valueText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('value uses size12 typography', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final valueText = tester.widget<Text>(
        find.text('Jl. Raya Ciburuy · Akurasi baik '),
      );
      expect(valueText.style?.fontSize, AppTypography.size12);
    });

    testWidgets('calls onEdit when edit icon tapped', (tester) async {
      bool editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
              onEdit: () => editCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editCalled, isTrue);
    });

    testWidgets('does not crash when onEdit is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(tester.takeException(), isNull);
    });

    testWidgets('has top border with bgSoft color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final border = container.decoration as BoxDecoration;
      expect(border.border, isNotNull);
      expect(border.border?.top.color, AppColors.bgSoft);
    });

    testWidgets('uses Row with spaceBetween alignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    });

    testWidgets('icon size is 14px', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy',
              accuracy: 'Akurasi baik',
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.edit_outlined));
      expect(icon.size, 14);
    });

    testWidgets('handles long address text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(
              address: 'Jl. Raya Ciburuy No. 123 RT 05 RW 02 Desa Sukamekar',
              accuracy: 'Akurasi rendah',
            ),
          ),
        ),
      );

      expect(find.textContaining('Jl. Raya Ciburuy'), findsOneWidget);
      expect(find.textContaining('Akurasi rendah'), findsOneWidget);
    });

    testWidgets('handles empty accuracy text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationRowEdit(address: 'Jl. Raya Ciburuy', accuracy: ''),
          ),
        ),
      );

      expect(find.text('Jl. Raya Ciburuy ·  '), findsOneWidget);
    });
  });
}
