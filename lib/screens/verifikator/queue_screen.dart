import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';

/// Verifikator queue item model
class VerifikatorQueueItem {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String? category;
  final String? wilayah;
  final String? villageName;
  final String? createdAt;
  final String? priority;
  final double? lat;
  final double? lng;

  VerifikatorQueueItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.category,
    this.wilayah,
    this.villageName,
    this.createdAt,
    this.priority,
    this.lat,
    this.lng,
  });

  factory VerifikatorQueueItem.fromJson(Map<String, dynamic> json) {
    // Use raw slug for id, show dash if empty/null
    final idRaw = json['id'] as String?;
    final statusRaw = json['status'] as String?;
    return VerifikatorQueueItem(
      id: (idRaw != null && idRaw.isNotEmpty) ? idRaw : '-',
      title: json['title'] as String? ?? json['description'] as String? ?? '-',
      description: json['description'] as String?,
      // Show raw status slug or dash - no magic 'JALAN' default
      status: (statusRaw != null && statusRaw.isNotEmpty) ? statusRaw : '-',
      category: json['category'] as String? ?? json['category_name'] as String?,
      wilayah: json['wilayah'] as String? ?? json['village_name'] as String?,
      villageName: json['village_name'] as String?,
      createdAt:
          json['created_at'] as String? ?? json['submitted_at'] as String?,
      priority: json['priority'] as String? ?? json['severity'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  /// Returns formatted time ago string
  String get timeAgo {
    if (createdAt == null) return '-';
    try {
      final dt = DateTime.parse(createdAt!);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays > 0) {
        if (diff.inDays == 1) return 'Kemarin';
        if (diff.inDays < 7) return '${diff.inDays} hari lalu';
        return '${(diff.inDays / 7).floor()} minggu lalu';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} jam yang lalu';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} menit lalu';
      } else {
        return 'Baru saja';
      }
    } catch (_) {
      return '-';
    }
  }

  /// Returns display location (prioritize villageName, fall back to wilayah)
  String get displayLocation => villageName ?? wilayah ?? '-';
}

/// Status extension for verifikator queue
extension VerifikatorStatusExt on String {
  String get statusLabel {
    switch (toLowerCase()) {
      case 'pending':
      case 'submitted':
      case 'under_review':
        return 'Menunggu';
      case 'in_progress':
      case 'processing':
        return 'Diproses';
      case 'verified':
      case 'completed':
        return 'Diverifikasi';
      case 'rejected':
        return 'Ditolak';
      case 'duplicate_merged':
        return 'Duplikat';
      default:
        return this;
    }
  }

  Color statusColor() {
    switch (toLowerCase()) {
      case 'pending':
      case 'submitted':
      case 'under_review':
        return SigapColors.warning;
      case 'in_progress':
      case 'processing':
        return SigapColors.info;
      case 'verified':
      case 'completed':
        return SigapColors.primary;
      case 'rejected':
        return SigapColors.danger;
      case 'duplicate_merged':
        return SigapColors.textTertiary;
      default:
        return SigapColors.textTertiary;
    }
  }
}

/// Provider for verifikator queue counts
final verifikatorQueueCountsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  try {
    final page = await api.getVerifikatorQueue();

    int menunggu = 0;
    int diproses = 0;
    int diverifikasi = 0;
    int ditolak = 0;

    for (final item in page.items) {
      // Use the generated type's status field (ReportStatus enum -> value)
      final status = item.status?.value.toLowerCase() ?? '';
      if (status == 'pending' ||
          status == 'submitted' ||
          status == 'under_review') {
        menunggu++;
      } else if (status == 'in_progress' || status == 'processing') {
        diproses++;
      } else if (status == 'verified' || status == 'completed') {
        diverifikasi++;
      } else if (status == 'rejected') {
        ditolak++;
      }
    }

    return {
      'menunggu': menunggu,
      'diproses': diproses,
      'diverifikasi': diverifikasi,
      'ditolak': ditolak,
      'total': page.items.length,
    };
  } catch (e) {
    return {
      'menunggu': 0,
      'diproses': 0,
      'diverifikasi': 0,
      'ditolak': 0,
      'total': 0,
    };
  }
});

/// Provider for verifikator queue items
final verifikatorQueueProvider = FutureProvider<List<VerifikatorQueueItem>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final page = await api.getVerifikatorQueue();
  // Use typed page.items and convert to local model for UI fields like title
  // The generated type doesn't have all UI fields (title, category, wilayah, villageName)
  // so we rebuild from the raw item data preserved in the generated type
  return page.items.map((item) {
    return VerifikatorQueueItem(
      id: item.id ?? '-',
      title: item.description ?? '-',
      description: item.description,
      status: item.status?.value ?? 'pending',
      category: null,
      wilayah: null,
      villageName: null,
      createdAt: item.createdAt,
      priority: item.priority?.value,
      lat: null,
      lng: null,
    );
  }).toList();
});

/// W-02 KPI Card for verifikator queue counts
class _VerifikatorKpiCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _VerifikatorKpiCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: SigapSpacing.md,
          horizontal: SigapSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: SigapColors.bgCard,
          borderRadius: BorderRadius.circular(SigapRadius.md),
          border: Border.all(color: SigapColors.borderCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: SigapTypography.size22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: SigapTypography.size10,
                color: SigapColors.textTertiary,
                height: SigapTypography.lineHeight125,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI Section with 4 counters: Menunggu, Diproses, Diverifikasi, Ditolak
class _VerifikatorKpiSection extends ConsumerWidget {
  const _VerifikatorKpiSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(verifikatorQueueCountsProvider);

    return countsAsync.when(
      data: (counts) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
        child: Row(
          children: [
            _VerifikatorKpiCard(
              count: counts['menunggu'] ?? 0,
              label: 'Menunggu',
              color: SigapColors.warning,
            ),
            const SizedBox(width: SigapSpacing.sm),
            _VerifikatorKpiCard(
              count: counts['diproses'] ?? 0,
              label: 'Diproses',
              color: SigapColors.info,
            ),
            const SizedBox(width: SigapSpacing.sm),
            _VerifikatorKpiCard(
              count: counts['diverifikasi'] ?? 0,
              label: 'Diverifikasi',
              color: SigapColors.primary,
            ),
            const SizedBox(width: SigapSpacing.sm),
            _VerifikatorKpiCard(
              count: counts['ditolak'] ?? 0,
              label: 'Ditolak',
              color: SigapColors.danger,
            ),
          ],
        ),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
        child: Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? SigapSpacing.sm : 0),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: SigapColors.bgSurface,
                    borderRadius: BorderRadius.circular(SigapRadius.md),
                    border: Border.all(color: SigapColors.borderCard),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SigapColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
        child: Container(
          height: 60,
          padding: const EdgeInsets.all(SigapSpacing.md),
          decoration: BoxDecoration(
            color: SigapColors.bgSurface,
            borderRadius: BorderRadius.circular(SigapRadius.md),
            border: Border.all(color: SigapColors.borderCard),
          ),
          child: const Row(
            children: [
              Icon(Icons.error_outline, color: SigapColors.danger, size: 20),
              SizedBox(width: SigapSpacing.sm),
              Text(
                'Gagal memuat statistik',
                style: TextStyle(
                  color: SigapColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for queue card
class _QueueCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      padding: const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        border: Border.all(color: SigapColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: SigapColors.borderCard,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: SigapSpacing.sm),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: SigapColors.borderCard,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: SigapColors.borderCard,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SigapSpacing.md),
              Container(
                height: 24,
                width: 70,
                decoration: BoxDecoration(
                  color: SigapColors.borderCard,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
              ),
            ],
          ),
          const SizedBox(height: SigapSpacing.md),
          Container(height: 1, color: SigapColors.borderCard),
          const SizedBox(height: SigapSpacing.md),
          Row(
            children: [
              Container(
                height: 22,
                width: 60,
                decoration: BoxDecoration(
                  color: SigapColors.borderCard,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
              ),
              const SizedBox(width: SigapSpacing.sm),
              Container(
                height: 22,
                width: 80,
                decoration: BoxDecoration(
                  color: SigapColors.borderCard,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
              ),
              const Spacer(),
              Container(
                height: 32,
                width: 70,
                decoration: BoxDecoration(
                  color: SigapColors.borderCard,
                  borderRadius: BorderRadius.circular(SigapRadius.sm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Queue card widget with status pill, category badge, time ago, wilayah
class _VerifikatorQueueCard extends StatelessWidget {
  final VerifikatorQueueItem item;
  final VoidCallback onTap;

  const _VerifikatorQueueCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SigapSpacing.md),
      child: Material(
        color: SigapColors.bgCard,
        borderRadius: BorderRadius.circular(SigapRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SigapRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(SigapSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: SigapColors.borderCard),
              borderRadius: BorderRadius.circular(SigapRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID + Status pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.sm,
                        vertical: SigapSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: SigapColors.bgSoft,
                        borderRadius: BorderRadius.circular(SigapRadius.sm),
                      ),
                      child: Text(
                        '#${item.id.length > 8 ? item.id.substring(0, 8) : item.id}',
                        style: const TextStyle(
                          fontSize: SigapTypography.size11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          color: SigapColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: SigapSpacing.sm),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SigapSpacing.sm,
                        vertical: SigapSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: item.status.statusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SigapRadius.pill),
                      ),
                      child: Text(
                        item.status.statusLabel,
                        style: TextStyle(
                          fontSize: SigapTypography.size11,
                          fontWeight: FontWeight.w600,
                          color: item.status.statusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SigapSpacing.sm),

                // Title/description
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: SigapTypography.size14,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: SigapSpacing.xs),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: SigapTypography.size12,
                      color: SigapColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: SigapSpacing.md),
                Container(height: 1, color: SigapColors.borderCard),
                const SizedBox(height: SigapSpacing.md),

                // Bottom row: Category, wilayah, time ago, action
                Row(
                  children: [
                    // Category badge
                    if (item.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SigapSpacing.sm,
                          vertical: SigapSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: SigapColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SigapRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 12,
                              color: SigapColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.category!,
                              style: const TextStyle(
                                fontSize: SigapTypography.size11,
                                color: SigapColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SigapSpacing.sm),
                    ],

                    // Location/wilayah
                    if (item.displayLocation != '-') ...[
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: SigapColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.displayLocation,
                                style: const TextStyle(
                                  fontSize: SigapTypography.size11,
                                  color: SigapColors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      const Spacer(),

                    // Time ago
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: SigapColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                            fontSize: SigapTypography.size11,
                            color: SigapColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Main Verifikator Queue Screen (W-02)
class VerifikatorQueueScreen extends ConsumerStatefulWidget {
  const VerifikatorQueueScreen({super.key});

  @override
  ConsumerState<VerifikatorQueueScreen> createState() =>
      _VerifikatorQueueScreenState();
}

class _VerifikatorQueueScreenState
    extends ConsumerState<VerifikatorQueueScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(verifikatorQueueProvider);

    return Scaffold(
      backgroundColor: SigapColors.bgSurface,
      body: Column(
        children: [
          // App bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.lg,
              vertical: SigapSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: SigapColors.bgCard,
              border: Border(bottom: BorderSide(color: SigapColors.borderCard)),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Antrean Verifikasi',
                          style: TextStyle(
                            fontSize: SigapTypography.size20,
                            fontWeight: FontWeight.w700,
                            color: SigapColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Verifikator',
                          style: TextStyle(
                            fontSize: SigapTypography.size12,
                            color: SigapColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: SigapColors.textSecondary,
                    ),
                    onPressed: () {
                      ref.invalidate(verifikatorQueueProvider);
                      ref.invalidate(verifikatorQueueCountsProvider);
                    },
                  ),
                ],
              ),
            ),
          ),

          // KPI Section
          const SizedBox(height: SigapSpacing.md),
          const _VerifikatorKpiSection(),
          const SizedBox(height: SigapSpacing.lg),

          // Queue list
          Expanded(
            child: queueAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(verifikatorQueueProvider);
                    ref.invalidate(verifikatorQueueCountsProvider);
                    await ref.read(verifikatorQueueProvider.future);
                  },
                  color: SigapColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SigapSpacing.lg,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _VerifikatorQueueCard(
                        item: item,
                        onTap: () =>
                            context.push('/verifikator/cases/${item.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: SigapSpacing.lg,
                ),
                itemCount: 5,
                itemBuilder: (_, __) => _QueueCardSkeleton(),
              ),
              error: (error, _) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.inbox_outlined,
              size: 40,
              color: SigapColors.textTertiary,
            ),
          ),
          const SizedBox(height: SigapSpacing.lg),
          const Text(
            'Tidak ada antrean',
            style: TextStyle(
              fontSize: SigapTypography.size16,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: SigapSpacing.xs),
          const Text(
            'Antrean verifikasi akan muncul di sini',
            style: TextStyle(
              fontSize: SigapTypography.size13,
              color: SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SigapSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SigapColors.danger,
            ),
            const SizedBox(height: SigapSpacing.lg),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: SigapTypography.size16,
                fontWeight: FontWeight.w600,
                color: SigapColors.textPrimary,
              ),
            ),
            const SizedBox(height: SigapSpacing.sm),
            Text(
              error,
              style: const TextStyle(
                fontSize: SigapTypography.size12,
                color: SigapColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: SigapSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(verifikatorQueueProvider);
                ref.invalidate(verifikatorQueueCountsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SigapColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final labels = [
      Strings.beranda,
      'Tugas',
      Strings.peta,
      Strings.notifikasi,
      Strings.profil,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: SigapColors.bgCard,
        border: Border(top: BorderSide(color: SigapColors.borderCard)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedNavIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIcon(index),
                        size: 24,
                        color: _selectedNavIndex == index
                            ? SigapColors.primary
                            : SigapColors.textTertiary,
                      ),
                      const SizedBox(height: SigapSpacing.x4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: SigapTypography.size10,
                          fontWeight: _selectedNavIndex == index
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedNavIndex == index
                              ? SigapColors.primary
                              : SigapColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    final isActive = _selectedNavIndex == index;
    switch (index) {
      case 0:
        return isActive ? Icons.home_rounded : Icons.home_outlined;
      case 1:
        return isActive ? Icons.assignment_rounded : Icons.assignment_outlined;
      case 2:
        return isActive ? Icons.map_rounded : Icons.map_outlined;
      case 3:
        return isActive
            ? Icons.notifications_rounded
            : Icons.notifications_outlined;
      case 4:
        return isActive ? Icons.person_rounded : Icons.person_outline;
      default:
        return Icons.circle;
    }
  }
}
