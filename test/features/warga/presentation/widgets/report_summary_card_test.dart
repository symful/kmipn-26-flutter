import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/report_summary_card.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  const kTestReport = ReportSummary(
    initials: 'JL',
    categoryName: 'JALAN',
    condition: 'Berat',
    title: 'Lubang besar di jalan utama, dalam ±40 cm, membahayakan motor.',
    location: 'Jl. Raya Ciburuy',
    accuracy: 'Akurasi baik',
    timestamp: '17 Jul 2026, 09:32',
    impact: 'Keselamatan · akses terganggu',
    photoIndex: '1/3',
  );

  group('ReportSummaryCard', () {
    testWidgets('renders section label correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(find.text('Ringkasan laporan'), findsOneWidget);
    });

    testWidgets('renders category badge with initials', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(find.text('JL'), findsOneWidget);
    });

    testWidgets('renders condition text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(find.text('Kondisi: Berat'), findsOneWidget);
    });

    testWidgets('renders report title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(
        find.text(
          'Lubang besar di jalan utama, dalam ±40 cm, membahayakan motor.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders location row with label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(find.text('Lokasi'), findsOneWidget);
      // Location is combined with accuracy as "Jl. Raya Ciburuy · Akurasi baik"
      expect(find.text('Jl. Raya Ciburuy · Akurasi baik'), findsOneWidget);
    });

    testWidgets('renders time row with label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(find.text('Waktu'), findsOneWidget);
      expect(find.text('17 Jul 2026, 09:32'), findsOneWidget);
    });

    testWidgets('renders impact row with label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(find.text('Dampak'), findsOneWidget);
      expect(find.text('Keselamatan · akses terganggu'), findsOneWidget);
    });

    testWidgets('renders photo placeholder with index', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      expect(find.text('foto 1/3'), findsOneWidget);
    });

    testWidgets('shows edit button when canEditLocation is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      // The edit icon is the ✎ character
      expect(find.text('✎'), findsNWidgets(2)); // Location + Time
    });

    testWidgets('hides location edit button when canEditLocation is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportSummaryCard(
              report: ReportSummary(
                initials: 'JL',
                categoryName: 'JALAN',
                condition: 'Berat',
                title: 'Test',
                location: 'Test location',
                accuracy: 'Akurasi baik',
                timestamp: '17 Jul 2026, 09:32',
                impact: 'Test impact',
                canEditLocation: false,
                canEditTimestamp: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('✎'), findsOneWidget); // Only Time edit button
    });

    testWidgets('hides time edit button when canEditTimestamp is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportSummaryCard(
              report: ReportSummary(
                initials: 'JL',
                categoryName: 'JALAN',
                condition: 'Berat',
                title: 'Test',
                location: 'Test location',
                accuracy: 'Akurasi baik',
                timestamp: '17 Jul 2026, 09:32',
                impact: 'Test impact',
                canEditLocation: true,
                canEditTimestamp: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('✎'), findsOneWidget); // Only Location edit button
    });

    testWidgets('hides all edit buttons when both canEdit are false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportSummaryCard(
              report: ReportSummary(
                initials: 'JL',
                categoryName: 'JALAN',
                condition: 'Berat',
                title: 'Test',
                location: 'Test location',
                accuracy: 'Akurasi baik',
                timestamp: '17 Jul 2026, 09:32',
                impact: 'Test impact',
                canEditLocation: false,
                canEditTimestamp: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('✎'), findsNothing);
    });

    testWidgets('calls onEditLocation when location edit tapped', (
      tester,
    ) async {
      bool editLocationCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportSummaryCard(
              report: kTestReport,
              onEditLocation: () => editLocationCalled = true,
            ),
          ),
        ),
      );

      // Find the first ✎ and tap it (location edit)
      await tester.tap(find.text('✎').first);
      expect(editLocationCalled, isTrue);
    });

    testWidgets('calls onEditTimestamp when time edit tapped', (tester) async {
      bool editTimestampCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportSummaryCard(
              report: kTestReport,
              onEditTimestamp: () => editTimestampCalled = true,
            ),
          ),
        ),
      );

      // Find the second ✎ and tap it (timestamp edit)
      await tester.tap(find.text('✎').last);
      expect(editTimestampCalled, isTrue);
    });

    testWidgets('card has correct background color (bgCard)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      // Find the card container
      final containers = tester.widgetList<Container>(find.byType(Container));
      final cardContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.bgCard,
      );
      expect(cardContainer, isNotNull);
    });

    testWidgets('card has correct border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final cardContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).borderRadius != null,
      );
      final decoration = cardContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.lg));
    });

    testWidgets('category badge has correct background color (primaryLight)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReportSummaryCard(report: kTestReport)),
        ),
      );

      // Find the badge container (should have primaryLight background)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final badgeContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.primaryLight,
      );
      expect(badgeContainer, isNotNull);
    });

    testWidgets('renders with custom photo index', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportSummaryCard(
              report: ReportSummary(
                initials: 'AR',
                categoryName: 'AREA',
                condition: 'Ringan',
                title: 'Test report',
                location: 'Test',
                accuracy: 'Test',
                timestamp: 'Test',
                impact: 'Test',
                photoIndex: '2/5',
              ),
            ),
          ),
        ),
      );

      expect(find.text('foto 2/5'), findsOneWidget);
    });
  });

  group('ReportSummary model', () {
    test('creates instance with all required fields', () {
      const r = ReportSummary(
        initials: 'JB',
        categoryName: 'JAMBAN',
        condition: 'Ringan',
        title: 'Test title',
        location: 'Test location',
        accuracy: 'Test accuracy',
        timestamp: 'Test timestamp',
        impact: 'Test impact',
        photoIndex: '1/2',
        canEditLocation: true,
        canEditTimestamp: false,
      );

      expect(r.initials, 'JB');
      expect(r.categoryName, 'JAMBAN');
      expect(r.condition, 'Ringan');
      expect(r.title, 'Test title');
      expect(r.location, 'Test location');
      expect(r.accuracy, 'Test accuracy');
      expect(r.timestamp, 'Test timestamp');
      expect(r.impact, 'Test impact');
      expect(r.photoIndex, '1/2');
      expect(r.canEditLocation, isTrue);
      expect(r.canEditTimestamp, isFalse);
    });

    test('uses default values for optional fields', () {
      const r = ReportSummary(
        initials: 'LP',
        categoryName: 'LAHANKERING',
        condition: 'Kritis',
        title: 'Test',
        location: 'Test',
        accuracy: 'Test',
        timestamp: 'Test',
        impact: 'Test',
      );

      expect(r.photoIndex, '1/3');
      expect(r.canEditLocation, isTrue);
      expect(r.canEditTimestamp, isTrue);
    });
  });
}
