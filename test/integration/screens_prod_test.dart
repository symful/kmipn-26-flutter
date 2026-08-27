// T8 (screen half): pump REAL screens with the real provider graph.
// apiClientProvider is overridden to inject a prod token; everything
// downstream is the production implementation. Data-level prod proofs live
// in prod_data_test.dart.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sigap/features/surveyor/surveyor_home_screen.dart';
import 'package:sigap/features/warga/warga_home_screen.dart';
import 'package:sigap/providers/providers.dart';

import '../helpers/test_tokens.dart';

void main() {
  setUpAll(() async {
    final proc = await Process.run(
      'node',
      ['scripts/setup-runner.mjs'],
      workingDirectory: '../kmipn-26-deno',
      runInShell: true,
    );
    if (proc.exitCode != 0) {
      throw ActionableError(
        'setup-runner failed',
        'Run node scripts/setup-runner.mjs from kmipn-26-deno manually.',
      );
    }
    loadTestManifest();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(
            buildProdClient(tokenFor(TestRole.warga)),
          ),
        ],
        child: MaterialApp(home: child),
      ),
    );
    // settle() never quiesces over live network/drift/timers; pump on timers.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  testWidgets(
    'SCREEN: WargaHomeScreen pumps real providers',
    (tester) async {
      await pumpScreen(tester, const WargaHomeScreen());
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.textContaining('Laporan'), findsWidgets);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets(
    'SCREEN: SurveyorHomeScreen pumps real providers',
    (tester) async {
      await pumpScreen(tester, const SurveyorHomeScreen());
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Tugas hari ini'), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
