import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/m14_parent_case_card.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('M14ParentCaseCard', () {
    testWidgets('renders avatar with initials', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      expect(find.text('JL'), findsOneWidget);
    });

    testWidgets('avatar has correct background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      // Find avatar by looking for the Container with primaryLight color
      // The avatar is a Container with 34x34 dimensions inside a Row
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(M14ParentCaseCard),
          matching: find.byType(Container),
        ),
      );

      // Find the container that has the primaryLight background
      Container? avatarContainer;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.color == AppColors.primaryLight &&
              decoration.borderRadius != null) {
            avatarContainer = container;
            break;
          }
        }
      }

      expect(avatarContainer, isNotNull);
    });

    testWidgets('avatar has correct font family (IBM Plex Mono)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final avatarText = tester.widget<Text>(find.text('JL'));
      expect(avatarText.style?.fontFamily, 'IBM Plex Mono');
    });

    testWidgets('avatar has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final avatarText = tester.widget<Text>(find.text('JL'));
      expect(avatarText.style?.fontSize, AppTypography.size12);
    });

    testWidgets('avatar has correct font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final avatarText = tester.widget<Text>(find.text('JL'));
      expect(avatarText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('avatar has correct text color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final avatarText = tester.widget<Text>(find.text('JL'));
      expect(avatarText.style?.color, AppColors.primaryDark);
    });

    testWidgets('renders "Bagian dari kasus" label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bagian dari kasus'), findsOneWidget);
    });

    testWidgets('label has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('Bagian dari kasus'));
      expect(label.style?.fontSize, AppTypography.size11);
    });

    testWidgets('label has correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final label = tester.widget<Text>(find.text('Bagian dari kasus'));
      expect(label.style?.color, AppColors.textTertiary);
    });

    testWidgets('renders case title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Jalan berlubang dekat Pasar'), findsOneWidget);
    });

    testWidgets('case title has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final title = tester.widget<Text>(
        find.text('Jalan berlubang dekat Pasar'),
      );
      expect(title.style?.fontSize, AppTypography.size13);
    });

    testWidgets('case title has correct font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final title = tester.widget<Text>(
        find.text('Jalan berlubang dekat Pasar'),
      );
      expect(title.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('case title has correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final title = tester.widget<Text>(
        find.text('Jalan berlubang dekat Pasar'),
      );
      expect(title.style?.color, AppColors.textPrimary);
    });

    testWidgets('renders "Lihat →" link', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Lihat \u2192'), findsOneWidget);
    });

    testWidgets('link has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final link = tester.widget<Text>(find.text('Lihat \u2192'));
      expect(link.style?.fontSize, AppTypography.size12_5);
    });

    testWidgets('link has correct font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final link = tester.widget<Text>(find.text('Lihat \u2192'));
      expect(link.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('link has correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final link = tester.widget<Text>(find.text('Lihat \u2192'));
      expect(link.style?.color, AppColors.primary);
    });

    testWidgets('calls onViewCase when link tapped', (tester) async {
      bool viewCaseTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
              onViewCase: () => viewCaseTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Lihat \u2192'));
      await tester.pump();

      expect(viewCaseTapped, isTrue);
    });

    testWidgets('handles null onViewCase callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      // Should not throw when onViewCase is null
      await tester.tap(find.text('Lihat \u2192'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('card has correct background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      // Find the outer Container with the card decoration
      final cardContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(M14ParentCaseCard),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.bgCard);
    });

    testWidgets('card has correct border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'JL',
                title: 'Jalan berlubang dekat Pasar',
              ),
            ),
          ),
        ),
      );

      final cardContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(M14ParentCaseCard),
          matching: find.byType(Container).first,
        ),
      );
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(
        (decoration.borderRadius as BorderRadius).topLeft.x,
        AppRadius.x12,
      );
    });

    testWidgets('displays different case titles correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14ParentCaseCard(
              parentCase: ParentCase(
                initials: 'AR',
                title: 'Pipa air bocor RW 02',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pipa air bocor RW 02'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
    });

    testWidgets('ParentCase model has const constructor', (tester) async {
      const parentCase = ParentCase(initials: 'JL', title: 'Test case');
      expect(parentCase.initials, 'JL');
      expect(parentCase.title, 'Test case');
    });
  });
}
