import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/design_system.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';

/// S-01 Riwayat Screen
///
/// Displays history of submitted survey visits with sync status indicators.
/// Shows all submitted visits regardless of sync status.
class RiwayatScreen extends ConsumerStatefulWidget {
  const RiwayatScreen({super.key});

  @override
  ConsumerState<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends ConsumerState<RiwayatScreen> {
  List<_VisitItem> _visits = [];
  bool _loading = true;
  String? _error;

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
      final taskRepo = ref.read(surveyorTaskRepositoryProvider);
      final allVisits = await taskRepo.getAllVisits();

      // Parse visit data and create visit items
      final items = <_VisitItem>[];
      for (final visit in allVisits) {
        final decoded = jsonDecode(visit.visitDataJson);
        final visitData = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{};
        items.add(
          _VisitItem(
            idempotencyKey: visit.idempotencyKey,
            taskId: visit.taskId,
            visitData: visitData,
            syncStatus: visit.syncStatus,
            createdAt: visit.createdAt,
          ),
        );
      }

      setState(() {
        _visits = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              appBar: AppBar(
                backgroundColor: SigapColors.bgCard,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SigapSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Text(
                        Strings.riwayat,
                        style: const TextStyle(
                          fontSize: SigapTypography.size19,
                          fontWeight: FontWeight.w700,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_visits.length} visit',
                        style: const TextStyle(
                          fontFamily: SigapTypography.fontFamilyMono,
                          fontSize: SigapTypography.size12,
                          color: SigapColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(SigapSpacing.lg),
                      child: SkeletonLoader.list(),
                    )
                  : _error != null && _visits.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(SigapSpacing.xl),
                      child: ErrorRetryView(
                        message: Strings.gagalMemuatRiwayat,
                        onRetry: _load,
                      ),
                    )
                  : _visits.isEmpty
                  ? _buildEmpty()
                  : _buildVisitList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SigapColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: SigapColors.borderCard, width: 2),
            ),
            child: const Icon(
              Icons.history,
              size: 40,
              color: SigapColors.textTertiary,
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),
          Text(
            Strings.belumAdaRiwayat,
            style: const TextStyle(
              fontSize: SigapTypography.size16,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          Text(
            Strings.visitYangDikirimAkanMuncul,
            style: const TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitList() {
    return RefreshIndicator(
      onRefresh: _load,
      color: SigapColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(SigapSpacing.lg),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          final visit = _visits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: SigapSpacing.md),
            child: _VisitCard(
              visit: visit,
              onTap: () {
                context.push('/tasks/${visit.taskId}');
              },
            ),
          );
        },
      ),
    );
  }
}

class _VisitItem {
  final String idempotencyKey;
  final String taskId;
  final Map<String, dynamic> visitData;
  final int syncStatus;
  final DateTime createdAt;

  _VisitItem({
    required this.idempotencyKey,
    required this.taskId,
    required this.visitData,
    required this.syncStatus,
    required this.createdAt,
  });
}

class _VisitCard extends StatelessWidget {
  final _VisitItem visit;
  final VoidCallback onTap;

  const _VisitCard({required this.visit, required this.onTap});

  String get _syncStatusLabel {
    switch (visit.syncStatus) {
      case 0:
        return Strings.menunggu;
      case 1:
        return Strings.terkirim;
      case 2:
        return Strings.gagal;
      default:
        return Strings.unknown;
    }
  }

  Color get _syncStatusColor {
    switch (visit.syncStatus) {
      case 0:
        return SigapColors.warning;
      case 1:
        return SigapColors.primary;
      case 2:
        return SigapColors.danger;
      default:
        return SigapColors.textTertiary;
    }
  }

  IconData get _syncStatusIcon {
    switch (visit.syncStatus) {
      case 0:
        return Icons.schedule;
      case 1:
        return Icons.check_circle;
      case 2:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String get _title {
    final title = visit.visitData['title'] as String?;
    if (title != null && title.isNotEmpty) return title;
    return 'Visit #${visit.taskId}';
  }

  String get _taskIdDisplay {
    if (visit.taskId.startsWith('TGS-')) {
      return visit.taskId;
    }
    return 'TGS-${visit.taskId}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.x12),
          border: Border.all(color: SigapColors.borderCard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SigapSpacing.md),
          child: Row(
            children: [
              // Sync status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _syncStatusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_syncStatusIcon, color: _syncStatusColor, size: 20),
              ),
              const SizedBox(width: SigapSpacing.md),
              // Title and task ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: SigapTypography.size13_5,
                        fontWeight: FontWeight.w600,
                        color: SigapColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _taskIdDisplay,
                      style: const TextStyle(
                        fontFamily: SigapTypography.fontFamilyMono,
                        fontSize: SigapTypography.size11,
                        color: SigapColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Sync status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _syncStatusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _syncStatusLabel,
                  style: TextStyle(
                    fontSize: SigapTypography.size10,
                    fontWeight: FontWeight.w600,
                    color: _syncStatusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
