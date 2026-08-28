import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/widgets/design_system/sync_status_indicator.dart';

void main() {
  group('SyncStatusIndicator', () {
    // -----------------------------------------------------------------------
    // Helper: pump the widget inside a minimal Material shell
    // -----------------------------------------------------------------------
    Future<void> pumpIndicator(WidgetTester tester, SyncState state) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: SyncStatusIndicator(state: state)),
          ),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // Online
    // -------------------------------------------------------------------------
    testWidgets('online renders check icon and "Online" label', (tester) async {
      await pumpIndicator(tester, SyncState.online);
      await tester.pumpAndSettle();

      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('online has correct semantics label', (tester) async {
      await pumpIndicator(tester, SyncState.online);
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(SyncStatusIndicator));
      // Semantics merges the explicit label with text from children
      expect(semantics.label, startsWith('Sync status: Online'));
    });

    test('online uses teal SigapColors tokens', () {
      const state = SyncState.online;
      final indicator = SyncStatusIndicator(state: state);

      expect(indicator.backgroundColor, SigapColors.primaryLight);
      expect(indicator.foregroundColor, SigapColors.primaryDark);
      expect(indicator.borderColor, SigapColors.successBorder);
      expect(indicator.dotColor, SigapColors.primary);
      expect(indicator.label, 'Online');
    });

    // -------------------------------------------------------------------------
    // Offline
    // -------------------------------------------------------------------------
    testWidgets('offline renders dot and "Offline" label', (tester) async {
      await pumpIndicator(tester, SyncState.offline);
      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsOneWidget);
      // Dot (circle) — not check icon, not spinner
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('offline has correct semantics label', (tester) async {
      await pumpIndicator(tester, SyncState.offline);
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(SyncStatusIndicator));
      expect(semantics.label, startsWith('Sync status: Offline'));
    });

    test('offline uses amber SigapColors tokens', () {
      const state = SyncState.offline;
      final indicator = SyncStatusIndicator(state: state);

      expect(indicator.backgroundColor, SigapColors.warningBg);
      expect(indicator.foregroundColor, SigapColors.warningText);
      expect(indicator.borderColor, SigapColors.warningBorder);
      expect(indicator.dotColor, SigapColors.warning);
      expect(indicator.label, 'Offline');
    });

    // -------------------------------------------------------------------------
    // Syncing
    // -------------------------------------------------------------------------
    testWidgets(
      'syncing renders CircularProgressIndicator and "Syncing" label',
      (tester) async {
        await pumpIndicator(tester, SyncState.syncing);
        await tester.pump();

        expect(find.text('Syncing'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('syncing has correct semantics label', (tester) async {
      await pumpIndicator(tester, SyncState.syncing);
      await tester.pump();

      final semantics = tester.getSemantics(find.byType(SyncStatusIndicator));
      expect(semantics.label, startsWith('Sync status: Syncing'));
    });

    test('syncing uses amber SigapColors tokens', () {
      const state = SyncState.syncing;
      final indicator = SyncStatusIndicator(state: state);

      expect(indicator.backgroundColor, SigapColors.warningBg);
      expect(indicator.foregroundColor, SigapColors.warningText);
      expect(indicator.borderColor, SigapColors.warningBorder);
      expect(indicator.dotColor, SigapColors.warning);
      expect(indicator.label, 'Syncing');
    });

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------
    testWidgets('error renders dot and "Error" label', (tester) async {
      await pumpIndicator(tester, SyncState.error);
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      // Dot — not check icon, not spinner
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('error has correct semantics label', (tester) async {
      await pumpIndicator(tester, SyncState.error);
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(SyncStatusIndicator));
      expect(semantics.label, startsWith('Sync status: Error'));
    });

    test('error uses red/danger SigapColors tokens', () {
      const state = SyncState.error;
      final indicator = SyncStatusIndicator(state: state);

      expect(indicator.backgroundColor, SigapColors.dangerBg);
      expect(indicator.foregroundColor, SigapColors.dangerTextStrong);
      expect(indicator.borderColor, SigapColors.dangerBorder);
      expect(indicator.dotColor, SigapColors.danger);
      expect(indicator.label, 'Error');
    });

    // -------------------------------------------------------------------------
    // Structural: SyncStatusIndicator widget itself renders for all states
    // -------------------------------------------------------------------------
    testWidgets('SyncStatusIndicator widget itself renders for all states', (
      tester,
    ) async {
      for (final state in SyncState.values) {
        await pumpIndicator(tester, state);
        // Use pump() instead of pumpAndSettle() because syncing state has
        // a CircularProgressIndicator which never settles.
        await tester.pump();

        expect(
          find.byType(SyncStatusIndicator),
          findsOneWidget,
          reason: 'State $state should render one SyncStatusIndicator',
        );
      }
    });
  });
}
