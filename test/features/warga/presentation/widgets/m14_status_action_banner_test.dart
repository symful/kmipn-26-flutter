import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/m14_status_action_banner.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  final kTestDeadline = DateTime(2026, 7, 19);

  group('M14StatusActionBanner', () {
    testWidgets('renders banner with warning background', (tester) async {
      final kTestBannerData = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description:
            'Verifikator meminta 1 foto tambahan dari sisi yang berbeda agar lubang terlihat jelas.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: kTestBannerData)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.warningBg);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadius.lg));
    });

    testWidgets('displays "Perlu tindakan Anda" status badge', (tester) async {
      final kTestBannerData = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Verifikator meminta 1 foto tambahan.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: kTestBannerData)),
        ),
      );

      expect(find.text('Perlu tindakan Anda'), findsOneWidget);
    });

    testWidgets('displays "Sedang diperiksa" status badge when diproses', (
      tester,
    ) async {
      final data = M14StatusBannerData(
        status: M14ReportStatus.diproses,
        description: 'Laporan sedang diverifikasi.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: data)),
        ),
      );

      expect(find.text('Sedang diperiksa'), findsOneWidget);
    });

    testWidgets('displays "Selesai" status badge when selesai', (tester) async {
      final data = M14StatusBannerData(
        status: M14ReportStatus.selesai,
        description: 'Laporan telah selesai diproses.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: data)),
        ),
      );

      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      final kTestBannerData = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Verifikator meminta 1 foto tambahan.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: kTestBannerData)),
        ),
      );

      expect(
        find.text('Verifikator meminta 1 foto tambahan. Tenggat 19 Jul 2026.'),
        findsOneWidget,
      );
    });

    testWidgets('displays deadline in correct format', (tester) async {
      final kTestBannerData = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Test description.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: kTestBannerData)),
        ),
      );

      // Date is inline in the description text, not a separate widget
      expect(find.textContaining('19 Jul 2026'), findsOneWidget);
    });

    testWidgets(
      'displays "Lengkapi laporan" button when onActionTap provided',
      (tester) async {
        final data = M14StatusBannerData(
          status: M14ReportStatus.perluTindakan,
          description: 'Test description.',
          deadline: kTestDeadline,
          onActionTap: _noop,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: M14StatusActionBanner(data: data)),
          ),
        );

        expect(find.text('Lengkapi laporan'), findsOneWidget);
      },
    );

    testWidgets('hides CTA button when onActionTap is null', (tester) async {
      final kTestBannerData = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Test description.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: kTestBannerData)),
        ),
      );

      expect(find.text('Lengkapi laporan'), findsNothing);
    });

    testWidgets('calls onActionTap when button tapped', (tester) async {
      bool actionCalled = false;

      final data = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Test description.',
        deadline: kTestDeadline,
        onActionTap: () => actionCalled = true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: data)),
        ),
      );

      await tester.tap(find.text('Lengkapi laporan'));
      expect(actionCalled, isTrue);
    });

    testWidgets('status badge has correct warning color', (tester) async {
      final kTestBannerData = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Test description.',
        deadline: kTestDeadline,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: kTestBannerData)),
        ),
      );

      // Find container with warning background color
      final containers = tester.widgetList<Container>(find.byType(Container));
      final badgeContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.warning,
      );
      expect(badgeContainer, isNotNull);
    });

    testWidgets('CTA button has primary color', (tester) async {
      final data = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Test description.',
        deadline: kTestDeadline,
        onActionTap: _noop,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: M14StatusActionBanner(data: data)),
        ),
      );

      // Find the CTA button container
      final containers = tester.widgetList<Container>(find.byType(Container));
      final buttonContainer = containers.lastWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == AppColors.primary,
      );
      expect(buttonContainer, isNotNull);
    });
  });

  group('M14ReportStatus enum', () {
    test('has three status values', () {
      expect(M14ReportStatus.values.length, 3);
      expect(M14ReportStatus.values, contains(M14ReportStatus.perluTindakan));
      expect(M14ReportStatus.values, contains(M14ReportStatus.diproses));
      expect(M14ReportStatus.values, contains(M14ReportStatus.selesai));
    });
  });

  group('M14StatusBannerData model', () {
    test('creates instance with all required fields', () {
      final data = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Test description',
        deadline: kTestDeadline,
      );

      expect(data.status, M14ReportStatus.perluTindakan);
      expect(data.description, 'Test description');
      expect(data.deadline, kTestDeadline);
      expect(data.onActionTap, isNull);
    });

    test('creates instance with onActionTap callback', () {
      void callback() {}
      final data = M14StatusBannerData(
        status: M14ReportStatus.perluTindakan,
        description: 'Test',
        deadline: kTestDeadline,
        onActionTap: callback,
      );

      expect(data.onActionTap, callback);
    });
  });
}

void _noop() {}
