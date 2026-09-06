import 'package:sigap/l10n/generated/app_localizations.dart';
import 'package:sigap/theme/sigap_color_scheme.dart';

import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:sigap/core/roles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/widgets/design_system/mobile_title_bar.dart';
import 'package:sigap/widgets/request_error_details.dart';

class SyncCenterScreen extends ConsumerStatefulWidget {
  const SyncCenterScreen({
    super.key,
    this.isWargaSection = false,
    this.standalone = false,
  });
  final bool isWargaSection;
  final bool standalone;
  @override
  ConsumerState<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends ConsumerState<SyncCenterScreen> {
  List<SyncQueueData> _items = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final queue = ref.read(syncQueueRepositoryProvider);
      final pending = await queue.getPendingItems();
      final dead = await queue.getDeadLetterItems();
      if (mounted) {
        setState(() {
          _items = [...pending, ...dead];
          _loading = false;
          _error = null;
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

  Future<void> _sync() async {
    if (_busy) return;
    if (ref.read(offlineModeProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.mobileConnectTheDeviceToTheInternetBeforeSyncing,
          ),
        ),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final queue = ref.read(syncQueueRepositoryProvider);
      // Recover previously saved reports that never received a queue entry.
      final pendingReports = await ref
          .read(reportRepositoryProvider)
          .getPendingReports();
      for (final report in pendingReports) {
        if (await queue.getByIdempotencyKey(report.idempotencyKey) == null) {
          await queue.enqueue(report.idempotencyKey, kind: 'report');
        }
      }
      for (final item in await queue.getPendingItems()) {
        await queue.retryDeadLetter(item.idempotencyKey);
      }
      final result = await ref.read(syncEngineProvider).flushAll();
      ref.invalidate(localReportsProvider);
      ref.invalidate(wargaReportsProvider);
      ref.invalidate(wargaStatsProvider);
      ref.invalidate(pendingCountProvider);
      await _load();
      if (mounted) {
        setState(() {
          _error = result.allSynced ? null : result.errors.join('\n');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (result.allSynced
                  ? AppLocalizations.of(
                      context,
                    )!.successfulSyncCount(result.syncedCount)
                  : AppLocalizations.of(
                      context,
                    )!.mobileSomeSubmissionsAreStillPendingYourDataRemainsSafe),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _retry(SyncQueueData item) async {
    await ref
        .read(syncQueueRepositoryProvider)
        .retryDeadLetter(item.idempotencyKey);
    await _load();
    ref.invalidate(pendingCountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final offline = ref.watch(offlineModeProvider);
    final checking = !ref.watch(connectivityProvider).hasValue;
    void leave() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(
          roleHome[ref.read(authNotifierProvider).userRole] ?? '/dashboard',
        );
      }
    }

    return PopScope(
      canPop: !widget.standalone || context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.standalone) leave();
      },
      child: Scaffold(
        backgroundColor: SigapColorScheme.of(context).bgSurface,
        appBar: MobileTitleBar(
          title: AppLocalizations.of(context)!.mobileSyncCenter,
          subtitle: AppLocalizations.of(
            context,
          )!.waitingSubmissionCount(_items.length),
          onBack: widget.standalone ? leave : null,
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _card(
                Column(
                  children: [
                    SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: SigapColorScheme.of(context).primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sync,
                        size: 28,
                        color: SigapColorScheme.of(context).primary,
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      (checking
                          ? AppLocalizations.of(
                              context,
                            )!.mobileCheckingConnection
                          : offline
                          ? AppLocalizations.of(context)!.mobileYouAreOffline
                          : AppLocalizations.of(
                              context,
                            )!.mobileReadyToSyncData),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      (offline
                          ? AppLocalizations.of(
                              context,
                            )!.mobileQueuedItemsRemainSavedUntilInternetAccessReturns
                          : AppLocalizations.of(
                              context,
                            )!.mobileSendReportsAndSurveyResultsToTheOperatorWorkspace),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: SigapColorScheme.of(context).textTertiary,
                      ),
                    ),
                    SizedBox(height: 18),
                  ],
                ),
              ),
              SizedBox(height: 18),
              if (_loading)
                LinearProgressIndicator()
              else if (_items.isEmpty && _error == null)
                _notice(
                  AppLocalizations.of(
                    context,
                  )!.mobileNoPendingSubmissionsAllDataOnThisDeviceIs,
                )
              else
                ..._items.map((item) {
                  Map<String, dynamic> payload = {};
                  try {
                    payload = (jsonDecode(item.payloadJson ?? '{}') as Map)
                        .cast<String, dynamic>();
                  } catch (_) {}
                  return Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (item.kind == 'visit'
                                      ? AppLocalizations.of(
                                          context,
                                        )!.mobileSurveyResult
                                      : AppLocalizations.of(
                                          context,
                                        )!.mobileResidentReport),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                (item.syncStatus == 3
                                    ? AppLocalizations.of(context)!.gagal
                                    : AppLocalizations.of(
                                        context,
                                      )!.mobilePending),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: SigapColorScheme.of(context).warning,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            ((payload['title'] ??
                                    payload['description'] ??
                                    payload['notes'] ??
                                    item.idempotencyKey)
                                .toString()),
                            style: TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            (item.idempotencyKey),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: SigapColorScheme.of(context).textMuted,
                            ),
                          ),
                          if (item.lastError != null) ...[
                            SizedBox(height: 8),
                            RequestErrorDetails(
                              details: item.lastError!,
                              message: AppLocalizations.of(
                                context,
                              )!.mobileSyncItemFailedExplanation,
                            ),
                          ],
                          if (item.syncStatus == 3)
                            TextButton(
                              onPressed: () => _retry(item),
                              child: Text(
                                AppLocalizations.of(context)!.mobileRetry,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              if (_error != null && _error!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: RequestErrorDetails(
                    details: _error!,
                    message: _items.isEmpty
                        ? AppLocalizations.of(
                            context,
                          )!.mobileSyncLoadFailedExplanation
                        : AppLocalizations.of(
                            context,
                          )!.mobileSomeSubmissionsAreStillPendingYourDataRemainsSafe,
                  ),
                ),
              SizedBox(height: 18),
              FilledButton(
                onPressed: _busy ? null : _sync,
                style: FilledButton.styleFrom(
                  backgroundColor: SigapColorScheme.of(context).primary,
                  padding: EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  (_busy
                      ? AppLocalizations.of(context)!.mobileSyncing
                      : AppLocalizations.of(
                          context,
                        )!.sinkronkanSekarangSemantics),
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 18),
              Text(
                AppLocalizations.of(
                  context,
                )!.mobileTheQueueIsStoredOnThisDevice,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.8,
                  color: SigapColorScheme.of(context).textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SigapColorScheme.of(context).surface,
      border: Border.all(color: SigapColorScheme.of(context).border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
  Widget _notice(String text) => Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: SigapColorScheme.of(context).primaryLight,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      (text),
      style: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: SigapColorScheme.of(context).primaryDark,
      ),
    ),
  );
}
