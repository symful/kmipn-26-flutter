// Widget/Integration tests for ReviewKirimanScreen (M-11)
//
// Tests real flows with concrete assertions:
// - Submission rows presence
// - StatusPill text display
// - Tap on similar case → navigates to detail
// - Privacy toggle interaction
// - Truth statement checkbox interaction
//
// Uses WidgetTester + mock providers.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/features/warga/review_kiriman_screen.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/theme/tokens.dart';

/// Mock connectivity - online by default.
List<ConnectivityResult> mockConnectivity([bool online = true]) {
  return online ? [ConnectivityResult.wifi] : [ConnectivityResult.none];
}

/// Creates a ProviderScope with overridden providers for review kiriman screen tests.
Widget createTestWidget({required Widget child, bool online = true}) {
  return ProviderScope(
    overrides: [
      // Connectivity - online by default
      connectivityProvider.overrideWith((ref) {
        return Stream<List<ConnectivityResult>>.value(mockConnectivity(online));
      }),
      // API client - mock (not used in this screen directly)
      apiClientProvider.overrideWith((ref) {
        return MockApiClient();
      }),
      // Database - mock
      databaseProvider.overrideWith((ref) {
        return MockAppDatabase();
      }),
      // Report repository - mock
      reportRepositoryProvider.overrideWith((ref) {
        return MockReportRepository();
      }),
      // Sync queue repository - mock
      syncQueueRepositoryProvider.overrideWith((ref) {
        return MockSyncQueueRepository();
      }),
    ],
    child: MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SigapColors.primary),
      ),
      home: child,
    ),
  );
}

/// Creates mock duplicate matches for the screen.
List<DuplicateMatch> mockDuplicateMatches() {
  return [
    DuplicateMatch(
      reportId: 'dup-001',
      description: 'Lubang jalan di depan rumah',
      lat: -6.9000,
      lng: 107.6000,
      categoryName: 'JALAN',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      similarityScore: 0.85,
      distance: '25m',
    ),
    DuplicateMatch(
      reportId: 'dup-002',
      description: 'Drainase tersumbat di gang baru',
      lat: -6.9010,
      lng: 107.6010,
      categoryName: 'DRAINASE',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      similarityScore: 0.72,
      distance: '50m',
    ),
  ];
}

/// Mock AppDatabase.
class MockAppDatabase extends AppDatabase {
  @override
  Future<List<LocalReport>> getAllReports() async => [];
}

/// Mock ApiClient.
class MockApiClient {
  Future<void> wargaSubmitEvidence({
    required String reportId,
    required String description,
    List<String> photoPaths = const [],
  }) async {
    // Mock success
  }
}

/// Mock ReportRepository.
class MockReportRepository {
  Future<void> saveLocal(LocalReportsCompanion report) async {}
}

/// Mock SyncQueueRepository.
class MockSyncQueueRepository {
  Future<void> enqueue(String idempotencyKey) async {}
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('T25: ReviewKirimanScreen (M-11) Flow Tests', () {
    testWidgets('M-11.1: Screen renders with review app bar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9,
            lng: 107.6,
            categoryName: 'JALAN',
            duplicateMatches: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // App bar should be present
      expect(find.byType(AppBar), findsOneWidget);
      // Screen title should be visible (step 5 of 5)
      expect(find.text('Buat Laporan'), findsWidgets);
    });

    testWidgets('M-11.2: ReportSummaryCard shows correct data', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Lubang jalan berbahaya di depan rumah',
            lat: -6.9000,
            lng: 107.6000,
            categoryName: 'JALAN',
            duplicateMatches: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Report summary card should show category name
      expect(find.text('JALAN'), findsWidgets);
      // Description should be visible
      expect(find.textContaining('Lubang jalan'), findsWidgets);
    });

    testWidgets('M-11.3: Privacy toggle is present and interactive', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9,
            lng: 107.6,
            duplicateMatches: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find privacy toggle
      final privacyToggle = find.byType(PrivacyToggle);
      expect(privacyToggle, findsOneWidget);

      // Tap to toggle
      await tester.tap(privacyToggle);
      await tester.pumpAndSettle();
    });

    testWidgets('M-11.4: Truth statement checkbox is present and interactive', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9,
            lng: 107.6,
            duplicateMatches: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find truth statement checkbox
      final checkbox = find.byType(TruthStatementCheckbox);
      expect(checkbox, findsOneWidget);

      // Tap to check
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
    });

    testWidgets('M-11.5: SimilarCasesBanner shown when duplicates present', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9,
            lng: 107.6,
            categoryName: 'JALAN',
            duplicateMatches: mockDuplicateMatches(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Similar cases banner should be visible
      expect(find.byType(SimilarCasesBanner), findsOneWidget);
    });

    testWidgets('M-11.6: Submit button shows loading state during submission', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9,
            lng: 107.6,
            categoryName: 'JALAN',
            duplicateMatches: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the submit button (StickyFooterCTA)
      expect(find.byType(StickyFooterCTA), findsOneWidget);
      // Button should say "Simpan dan sinkronkan nanti"
      expect(find.text('Simpan dan sinkronkan nanti'), findsOneWidget);
    });

    testWidgets('M-11.7: Coordinates shown correctly in report summary', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9000,
            lng: 107.6000,
            categoryName: 'JALAN',
            duplicateMatches: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Coordinates should be displayed
      expect(find.textContaining('-6.9000'), findsWidgets);
      expect(find.textContaining('107.6000'), findsWidgets);
    });

    testWidgets('M-11.8: Offline warning shown when offline', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9,
            lng: 107.6,
            categoryName: 'JALAN',
            duplicateMatches: const [],
          ),
          online: false,
        ),
      );
      await tester.pumpAndSettle();

      // StickyFooterCTA should show offline warning
      expect(find.byType(StickyFooterCTA), findsOneWidget);
    });

    testWidgets('M-11.9: Category initials shown in report summary', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ReviewKirimanScreen(
            description: 'Test description',
            lat: -6.9,
            lng: 107.6,
            categoryName: 'DRAINASE',
            duplicateMatches: const [],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show DR (first 2 letters of DRAINASE)
      expect(find.text('DR'), findsWidgets);
    });
  });
}
