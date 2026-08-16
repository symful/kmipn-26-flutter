import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/similar_cases_banner.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  const kTestCase = SimilarCase(
    id: 'report-1',
    initials: 'JL',
    title: 'Jalan berlubang dekat Pasar',
    distance: '42 m',
    similarityPercent: 86,
    reportCount: 5,
  );

  const kTestCase2 = SimilarCase(
    id: 'report-2',
    initials: 'PJ',
    title: 'Penerangan jalan mati',
    distance: '120 m',
    similarityPercent: 72,
    reportCount: 3,
  );

  group('SimilarCasesBanner', () {
    testWidgets('renders banner with blue background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [])),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.infoBg);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.lg));
    });

    testWidgets('displays correct count label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [kTestCase])),
        ),
      );

      expect(
        find.text('1 kasus serupa ditemukan di dekat sini'),
        findsOneWidget,
      );
    });

    testWidgets('displays plural count label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(cases: [kTestCase, kTestCase2]),
          ),
        ),
      );

      expect(
        find.text('2 kasus serupa ditemukan di dekat sini'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Lihat Semua" when onViewAll is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(cases: [kTestCase], onViewAll: _noop),
          ),
        ),
      );

      expect(find.text('Lihat Semua'), findsOneWidget);
    });

    testWidgets('hides "Lihat Semua" when onViewAll is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [kTestCase])),
        ),
      );

      expect(find.text('Lihat Semua'), findsNothing);
    });

    testWidgets('shows first case when collapsed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(cases: [kTestCase], onViewAll: _noop),
          ),
        ),
      );

      expect(find.text('Jalan berlubang dekat Pasar'), findsOneWidget);
      expect(find.text('42 m · kemiripan 86% · 5 laporan'), findsOneWidget);
    });

    testWidgets('hides first case when collapsed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(cases: [kTestCase], onViewAll: null),
          ),
        ),
      );

      // When onViewAll is null, the collapsed state still shows first case
      expect(find.text('Jalan berlubang dekat Pasar'), findsOneWidget);
    });

    testWidgets('toggles to expanded state on "Lihat Semua" tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(
              cases: const [kTestCase, kTestCase2],
              onViewAll: _noop,
            ),
          ),
        ),
      );

      // Initially collapsed - should show "Lihat Semua"
      expect(find.text('Lihat Semua'), findsOneWidget);
      expect(find.text('Tutup'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();

      // Now expanded - should show "Tutup"
      expect(find.text('Tutup'), findsOneWidget);
      expect(find.text('Lihat Semua'), findsNothing);

      // Both cases should be visible
      expect(find.text('Jalan berlubang dekat Pasar'), findsOneWidget);
      expect(find.text('Penerangan jalan mati'), findsOneWidget);
    });

    testWidgets('toggles back to collapsed on "Tutup" tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(
              cases: const [kTestCase, kTestCase2],
              onViewAll: _noop,
            ),
          ),
        ),
      );

      // Expand
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();

      // Collapse
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      expect(find.text('Lihat Semua'), findsOneWidget);
    });

    testWidgets('calls onViewAll when toggle is tapped', (tester) async {
      bool viewAllCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(
              cases: const [kTestCase],
              onViewAll: () => viewAllCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Lihat Semua'));
      expect(viewAllCalled, isTrue);
    });

    testWidgets('renders avatar with initials', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [kTestCase])),
        ),
      );

      expect(find.text('JL'), findsOneWidget);
    });

    testWidgets('renders "Tambahkan bukti ke kasus ini" button', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [kTestCase])),
        ),
      );

      expect(find.text('Tambahkan bukti ke kasus ini'), findsOneWidget);
    });

    testWidgets('renders "Buat terpisah" button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [kTestCase])),
        ),
      );

      expect(find.text('Buat terpisah'), findsOneWidget);
    });

    testWidgets('calls onAddEvidence when primary button tapped', (
      tester,
    ) async {
      SimilarCase? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SimilarCasesBanner(
              cases: const [kTestCase],
              onAddEvidence: (c) => selected = c,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tambahkan bukti ke kasus ini'));
      expect(selected?.id, 'report-1');
    });

    testWidgets('shows 0 count when cases list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [])),
        ),
      );

      // Banner shows "0 kasus serupa ditemukan di dekat sini" even with empty list
      expect(
        find.text('0 kasus serupa ditemukan di dekat sini'),
        findsOneWidget,
      );
      // No case cards rendered
      expect(find.text('Tambahkan bukti ke kasus ini'), findsNothing);
    });

    testWidgets('renders multiple cases when expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SimilarCasesBanner(
                cases: const [kTestCase, kTestCase2],
                onViewAll: _noop,
              ),
            ),
          ),
        ),
      );

      // Expand
      await tester.tap(find.text('Lihat Semua'));
      await tester.pumpAndSettle();

      // Both cases shown
      expect(find.text('Jalan berlubang dekat Pasar'), findsOneWidget);
      expect(find.text('Penerangan jalan mati'), findsOneWidget);
    });

    testWidgets('avatar has correct background color (primaryLight)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SimilarCasesBanner(cases: [kTestCase])),
        ),
      );

      // Find the avatar container (first Container after the header row)
      final containers = tester.widgetList<Container>(find.byType(Container));
      // The avatar is a 34x34 container with primaryLight background
      final avatarContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.primaryLight,
      );
      expect(avatarContainer.constraints?.maxWidth, 34);
      expect(avatarContainer.constraints?.maxHeight, 34);
    });
  });

  group('SimilarCase model', () {
    test('creates instance with all required fields', () {
      const c = SimilarCase(
        id: 'x',
        initials: 'AB',
        title: 'Test title',
        distance: '10 m',
        similarityPercent: 95,
        reportCount: 2,
      );

      expect(c.id, 'x');
      expect(c.initials, 'AB');
      expect(c.title, 'Test title');
      expect(c.distance, '10 m');
      expect(c.similarityPercent, 95);
      expect(c.reportCount, 2);
    });
  });
}

void _noop() {}
