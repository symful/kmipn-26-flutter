import 'package:sigap/widgets/request_error_details.dart';
import 'package:intl/intl.dart';
import 'package:sigap/utils/server_timestamp.dart';
import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/api/client.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sigap/providers/providers.dart';

class ReportHistoryScreen extends ConsumerStatefulWidget {
  const ReportHistoryScreen({super.key});
  @override
  ConsumerState<ReportHistoryScreen> createState() =>
      _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends ConsumerState<ReportHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<({SurveyVisit visit, String? taskId, String? title})> _visits = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final tasks = await client.getTasks();
      final details = await Future.wait(
        tasks.tasks
            .where((task) => task.taskId != null)
            .map((task) => client.getTaskDetail(task.taskId!)),
      );
      final visits = details
          .expand(
            (detail) => detail.visits.map(
              (visit) => (
                visit: visit,
                taskId: detail.taskId,
                title: detail.reportTitle,
              ),
            ),
          )
          .toList();
      visits.sort(
        (a, b) => (b.visit.createdAt ?? '').compareTo(a.visit.createdAt ?? ''),
      );
      if (mounted) {
        setState(() {
          _visits = visits;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SigapColorScheme.of(context).bgScreen,
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.mobileSurveyHistory),
          Text(
            (AppLocalizations.of(
              context,
            )!.submittedResultCount(_visits.length)),
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
    body: _loading
        ? Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RequestErrorDetails(details: _error!),
                TextButton(
                  onPressed: _load,
                  child: Text(AppLocalizations.of(context)!.mobileRetry),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_visits.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.mobileNoSurveyResultsYetSubmittedResultsWillAppearHere,
                    ),
                  ),
                ..._visits.map(
                  (visit) => Card(
                    child: ListTile(
                      onTap: () => context.push('/tasks/${visit.taskId}'),
                      title: Text(
                        visit.title ??
                            AppLocalizations.of(context)!.fieldSurveyLabel,
                      ),
                      subtitle: Text(
                        '${visit.visit.findings ?? ''}\n${_formatVisitTime(context, visit.visit.createdAt)}',
                      ),
                      isThreeLine: true,
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}

String _formatVisitTime(BuildContext context, String? timestamp) {
  final parsed = parseServerTimestamp(timestamp);
  if (parsed == null) return '';
  return DateFormat.yMMMd(
    AppLocalizations.of(context)!.localeName,
  ).add_Hm().format(parsed.toLocal());
}
