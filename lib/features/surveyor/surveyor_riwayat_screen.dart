import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';

/// S-01 Surveyor Riwayat Screen
///
/// Displays history of submitted survey visits with sync status indicators.
/// Shows all submitted visits regardless of sync status.
class SurveyorRiwayatScreen extends ConsumerStatefulWidget {
  const SurveyorRiwayatScreen({super.key});

  @override
  ConsumerState<SurveyorRiwayatScreen> createState() =>
      _SurveyorRiwayatScreenState();
}

class _SurveyorRiwayatScreenState extends ConsumerState<SurveyorRiwayatScreen> {
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
        final visitData =
            jsonDecode(visit.visitDataJson) as Map<String, dynamic>;
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
    } catch (e, _) {
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
              backgroundColor: AppColors.bgSurface,
              appBar: AppBar(
                backgroundColor: AppColors.bgCard,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Text(
                        Strings.riwayat,
                        style: const TextStyle(
                          fontSize: AppTypography.size19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_visits.length} visit',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Mono',
                          fontSize: AppTypography.size12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && _visits.isEmpty
                  ? _ErrorRetry(error: _error!, onRetry: _load)
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
              color: AppColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderCard, width: 2),
            ),
            child: const Icon(
              Icons.history,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Belum ada riwayat',
            style: TextStyle(
              fontSize: AppTypography.size16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Visit yang dikirim akan muncul di sini',
            style: TextStyle(
              fontSize: AppTypography.size13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitList() {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          final visit = _visits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _VisitCard(
              visit: visit,
              onTap: () {
                context.push('/surveyor/tasks/${visit.taskId}');
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
        return 'Menunggu';
      case 1:
        return 'Terkirim';
      case 2:
        return 'Gagal';
      default:
        return 'Unknown';
    }
  }

  Color get _syncStatusColor {
    switch (visit.syncStatus) {
      case 0:
        return AppColors.warning;
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.danger;
      default:
        return AppColors.textTertiary;
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
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.x12),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
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
              const SizedBox(width: AppSpacing.md),
              // Title and task ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: AppTypography.size13_5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _taskIdDisplay,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: AppTypography.size11,
                        color: AppColors.textTertiary,
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
                    fontSize: AppTypography.size10,
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

class _ErrorRetry extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Gagal memuat riwayat',
              style: TextStyle(
                fontSize: AppTypography.size16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: const TextStyle(
                fontSize: AppTypography.size12,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
