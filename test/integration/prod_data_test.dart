// T8 (data half): REAL prod API through the real ApiClient — plain VM tests
// where real sockets are permitted. Complements screens_prod_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_tokens.dart';
import 'package:sigap/api/exceptions.dart';

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
    final fresh = File("../kmipn-26-deno/.run/tokens.json");
    final dst = File(".run/tokens.json");
    await dst.parent.create(recursive: true);
    await fresh.copy(dst.path);
    loadTestManifest();
  });

  test(
    'PROD DATA: warga categories + own reports via real ApiClient',
    () async {
      final client = buildProdClient(tokenFor(TestRole.warga));
      final cats = await client.getCategories();
      expect(
        cats.length,
        greaterThanOrEqualTo(3),
        reason: 'FLOW-A step2: >=3 categories from prod',
      );
      final reports = await client.getWargaReports();
      expect(reports.items.length, greaterThanOrEqualTo(0));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'PROD DATA: surveyor task list via real ApiClient',
    () async {
      final client = buildProdClient(tokenFor(TestRole.surveyor));
      final page = await client.surveyorGetTasks();
      expect(page.tasks.length, greaterThanOrEqualTo(0));
      for (final t in page.tasks) {
        expect(t.taskId, isNotNull);
        expect(t.reportId, isNotNull);
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'PROD DATA: executive dashboard + regional + trend',
    () async {
      final client = buildProdClient(tokenFor(TestRole.pengambilKeputusan));
      final dash = await client.getExecutiveDashboard();
      expect(dash.total, isNotNull);
      final regional = await client.getExecutiveRegionalStats();
      expect(regional, isNotNull);
      final trend = await client.getExecutiveTrendAnalysis('weekly');
      expect(trend, isNotNull);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'PROD DATA: notifications list + mark-read xor',
    () async {
      final client = buildProdClient(tokenFor(TestRole.warga));
      final page = await client.getNotifications();
      expect(page, isNotNull);
      if (page.entries.isNotEmpty) {
        final first = page.entries.first;
        final beforeUnread = page.entries.where((n) => n.read == null).length;
        await client.markNotificationRead(first.id!);
        final after = await client.getNotifications();
        final afterUnread = after.entries.where((n) => n.read == null).length;
        expect(afterUnread, lessThanOrEqualTo(beforeUnread));
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'PROD DATA: admin-daerah scoped dashboard',
    () async {
      final client = buildProdClient(tokenFor(TestRole.adminDaerah));
      final stats = await client.getStats();
      expect(stats.dashboard, isNotNull);
      expect(stats.dashboard!['total_reports'], isNotNull);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
