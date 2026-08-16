import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/kasus_terdekat_cards.dart';

void main() {
  group('KasusTerdekatCard', () {
    testWidgets('renders initials, title, and subtitle correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KasusTerdekatCard(
              initials: 'JL',
              title: 'Jalan berlubang dekat Pasar',
              rw: 'RW 04',
              distanceMeters: 320,
              laporanCount: 5,
              status: KasusStatus.sedangDitangani,
            ),
          ),
        ),
      );

      expect(find.text('JL'), findsOneWidget);
      expect(find.text('Jalan berlubang dekat Pasar'), findsOneWidget);
      expect(find.text('RW 04 · 320 m · 5 laporan pendukung'), findsOneWidget);
    });

    testWidgets('displays correct distance format for meters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KasusTerdekatCard(
              initials: 'JL',
              title: 'Test case',
              rw: 'RW 01',
              distanceMeters: 320,
              laporanCount: 2,
              status: KasusStatus.sedangDitangani,
            ),
          ),
        ),
      );

      expect(find.text('RW 01 · 320 m · 2 laporan pendukung'), findsOneWidget);
    });

    testWidgets('displays correct distance format for kilometers', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KasusTerdekatCard(
              initials: 'AR',
              title: 'Test case',
              rw: 'RW 02',
              distanceMeters: 1200,
              laporanCount: 3,
              status: KasusStatus.terverifikasi,
            ),
          ),
        ),
      );

      expect(find.text('RW 02 · 1.2 km · 3 laporan pendukung'), findsOneWidget);
    });

    testWidgets(
      'shows "Sedang ditangani" status pill for sedangDitangani status',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KasusTerdekatCard(
                initials: 'JL',
                title: 'Jalan berlubang',
                rw: 'RW 04',
                distanceMeters: 320,
                laporanCount: 5,
                status: KasusStatus.sedangDitangani,
              ),
            ),
          ),
        );

        expect(find.text('Sedang ditangani'), findsOneWidget);
      },
    );

    testWidgets('shows "Terverifikasi" status pill for terverifikasi status', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KasusTerdekatCard(
              initials: 'AR',
              title: 'Pipa air bocor',
              rw: 'RW 02',
              distanceMeters: 780,
              laporanCount: 2,
              status: KasusStatus.terverifikasi,
            ),
          ),
        ),
      );

      expect(find.text('Terverifikasi'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KasusTerdekatCard(
              initials: 'JL',
              title: 'Jalan berlubang',
              rw: 'RW 04',
              distanceMeters: 320,
              laporanCount: 5,
              status: KasusStatus.sedangDitangani,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(KasusTerdekatCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders with zero distance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KasusTerdekatCard(
              initials: 'JL',
              title: 'Test case',
              rw: 'RW 01',
              distanceMeters: 0,
              laporanCount: 1,
              status: KasusStatus.terverifikasi,
            ),
          ),
        ),
      );

      expect(find.text('RW 01 · 0 m · 1 laporan pendukung'), findsOneWidget);
    });
  });

  group('KasusTerdekatSection', () {
    testWidgets('renders header with "Kasus terdekat" title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KasusTerdekatSection(cases: const []),
            ),
          ),
        ),
      );

      expect(find.text('Kasus terdekat'), findsOneWidget);
    });

    testWidgets('renders "Lihat peta" link', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KasusTerdekatSection(cases: const []),
            ),
          ),
        ),
      );

      expect(find.text('Lihat peta'), findsOneWidget);
    });

    testWidgets('calls onLihatPeta when "Lihat peta" is tapped', (
      tester,
    ) async {
      var lihatPetaTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KasusTerdekatSection(
                cases: const [],
                onLihatPeta: () => lihatPetaTapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Lihat peta'));
      expect(lihatPetaTapped, isTrue);
    });

    testWidgets('renders multiple case cards', (tester) async {
      const testCases = [
        KasusTerdekatCase(
          initials: 'JL',
          title: 'Jalan berlubang dekat Pasar',
          rw: 'RW 04',
          distanceMeters: 320,
          laporanCount: 5,
          status: KasusStatus.sedangDitangani,
        ),
        KasusTerdekatCase(
          initials: 'AR',
          title: 'Pipa air bocor RW 02',
          rw: 'RW 02',
          distanceMeters: 780,
          laporanCount: 2,
          status: KasusStatus.terverifikasi,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KasusTerdekatSection(cases: testCases),
            ),
          ),
        ),
      );

      expect(find.text('JL'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
      expect(find.text('Jalan berlubang dekat Pasar'), findsOneWidget);
      expect(find.text('Pipa air bocor RW 02'), findsOneWidget);
    });

    testWidgets('calls onCaseTap with correct case when card is tapped', (
      tester,
    ) async {
      const testCases = [
        KasusTerdekatCase(
          initials: 'JL',
          title: 'Jalan berlubang dekat Pasar',
          rw: 'RW 04',
          distanceMeters: 320,
          laporanCount: 5,
          status: KasusStatus.sedangDitangani,
        ),
        KasusTerdekatCase(
          initials: 'AR',
          title: 'Pipa air bocor RW 02',
          rw: 'RW 02',
          distanceMeters: 780,
          laporanCount: 2,
          status: KasusStatus.terverifikasi,
        ),
      ];

      KasusTerdekatCase? tappedCase;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KasusTerdekatSection(
                cases: testCases,
                onCaseTap: (kasus) => tappedCase = kasus,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pipa air bocor RW 02'));
      expect(tappedCase?.initials, equals('AR'));
      expect(tappedCase?.title, equals('Pipa air bocor RW 02'));
    });

    testWidgets('renders empty when cases list is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KasusTerdekatSection(cases: const []),
            ),
          ),
        ),
      );

      expect(find.text('Kasus terdekat'), findsOneWidget);
      expect(find.byType(KasusTerdekatCard), findsNothing);
    });
  });

  group('KasusTerdekatCase', () {
    test('creates instance with correct values', () {
      const kasus = KasusTerdekatCase(
        initials: 'JL',
        title: 'Jalan berlubang dekat Pasar',
        rw: 'RW 04',
        distanceMeters: 320,
        laporanCount: 5,
        status: KasusStatus.sedangDitangani,
      );

      expect(kasus.initials, equals('JL'));
      expect(kasus.title, equals('Jalan berlubang dekat Pasar'));
      expect(kasus.rw, equals('RW 04'));
      expect(kasus.distanceMeters, equals(320));
      expect(kasus.laporanCount, equals(5));
      expect(kasus.status, equals(KasusStatus.sedangDitangani));
    });
  });
}
