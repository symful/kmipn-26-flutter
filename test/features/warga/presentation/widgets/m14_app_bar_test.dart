import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/m14_app_bar.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('M14AppBar', () {
    testWidgets('renders back arrow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      expect(find.text('←'), findsOneWidget);
    });

    testWidgets('back arrow has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final backArrow = tester.widget<Text>(find.text('←'));
      expect(backArrow.style?.fontSize, AppTypography.size22);
    });

    testWidgets('back arrow has correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final backArrow = tester.widget<Text>(find.text('←'));
      expect(backArrow.style?.color, AppColors.textSecondary);
    });

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      expect(find.text('Detail laporan'), findsOneWidget);
    });

    testWidgets('title has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final title = tester.widget<Text>(find.text('Detail laporan'));
      expect(title.style?.fontSize, AppTypography.size16);
    });

    testWidgets('title has correct font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final title = tester.widget<Text>(find.text('Detail laporan'));
      expect(title.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('title has correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final title = tester.widget<Text>(find.text('Detail laporan'));
      expect(title.style?.color, AppColors.textPrimary);
    });

    testWidgets('renders dual IDs subtitle with local ID', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      expect(find.textContaining('Lokal #LR-0271'), findsOneWidget);
    });

    testWidgets('renders dual IDs subtitle with server ID', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      expect(find.textContaining('Server #CB-1842'), findsOneWidget);
    });

    testWidgets('subtitle has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      // Find the subtitle text
      final subtitle = tester.widget<Text>(
        find.text('Lokal #LR-0271 · Server #CB-1842'),
      );
      expect(subtitle.style?.fontSize, AppTypography.size11);
    });

    testWidgets('subtitle has IBM Plex Mono font', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final subtitle = tester.widget<Text>(
        find.text('Lokal #LR-0271 · Server #CB-1842'),
      );
      expect(subtitle.style?.fontFamily, 'IBM Plex Mono');
    });

    testWidgets('subtitle has correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final subtitle = tester.widget<Text>(
        find.text('Lokal #LR-0271 · Server #CB-1842'),
      );
      expect(subtitle.style?.color, AppColors.textTertiary);
    });

    testWidgets('renders more button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      expect(find.text('⋯'), findsOneWidget);
    });

    testWidgets('more button has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final moreButton = tester.widget<Text>(find.text('⋯'));
      expect(moreButton.style?.fontSize, AppTypography.size20);
    });

    testWidgets('more button has correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      final moreButton = tester.widget<Text>(find.text('⋯'));
      expect(moreButton.style?.color, AppColors.textSecondary);
    });

    testWidgets('calls onBack when back arrow tapped', (tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14AppBar(
              localId: 'LR-0271',
              serverId: 'CB-1842',
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('←'));
      await tester.pump();

      expect(backTapped, isTrue);
    });

    testWidgets('calls onMore when more button tapped', (tester) async {
      bool moreTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14AppBar(
              localId: 'LR-0271',
              serverId: 'CB-1842',
              onMore: () => moreTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('⋯'));
      await tester.pump();

      expect(moreTapped, isTrue);
    });

    testWidgets('handles null onBack callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      // Should not throw when onBack is null
      await tester.tap(find.text('←'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles null onMore callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-0271', serverId: 'CB-1842'),
          ),
        ),
      );

      // Should not throw when onMore is null
      await tester.tap(find.text('⋯'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays different local and server IDs correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14AppBar(localId: 'LR-9999', serverId: 'CB-1234'),
          ),
        ),
      );

      expect(find.text('Lokal #LR-9999 · Server #CB-1234'), findsOneWidget);
    });
  });
}
