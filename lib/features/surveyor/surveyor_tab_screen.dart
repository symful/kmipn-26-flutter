import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/design_system/phone_frame.dart';
import '../../widgets/design_system/status_bar.dart';
import 'presentation/widgets/connectivity_indicator.dart';
import 'presentation/widgets/task_filter_chips.dart';

/// S-01 Surveyor Tab Screen
///
/// Container screen with 2-tab bottom navigation:
/// - Sinkron (sync icon) - main surveyor task list
/// - Riwayat (history icon) - history of submitted visits
///
/// Uses BottomNav5 styling for consistency with PantauDesa design.
class SurveyorTabScreen extends ConsumerStatefulWidget {
  const SurveyorTabScreen({super.key});

  @override
  ConsumerState<SurveyorTabScreen> createState() => _SurveyorTabScreenState();
}

class _SurveyorTabScreenState extends ConsumerState<SurveyorTabScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Column(
        children: [
          StatusBar(),
          Expanded(
            child: Scaffold(
              backgroundColor: SigapColors.bgSurface,
              body: IndexedStack(
                index: _selectedIndex,
                children: const [_SinkronTab(), _RiwayatTab()],
              ),
              bottomNavigationBar: _Surveyor2TabNav(
                selectedIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sinkron tab - main surveyor task list
class _SinkronTab extends ConsumerWidget {
  const _SinkronTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(surveyorTasksProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: SigapColors.bgCard,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tugas hari ini',
                      style: TextStyle(
                        fontSize: SigapTypography.size19,
                        fontWeight: FontWeight.w700,
                        color: SigapColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    tasksAsync.when(
                      data: (tasks) => Text(
                        '${tasks.length} tugas',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Mono',
                          fontSize: SigapTypography.size12,
                          color: SigapColors.textTertiary,
                        ),
                      ),
                      loading: () => const Text(
                        '-',
                        style: TextStyle(color: SigapColors.textTertiary),
                      ),
                      error: (_, __) => const Text(
                        '-',
                        style: TextStyle(color: SigapColors.textTertiary),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const ConnectivityIndicator(status: ConnectivityStatus.online),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SigapSpacing.lg,
              vertical: SigapSpacing.sm,
            ),
            child: TaskFilterChips(selectedIndex: null, onChipSelected: (_) {}),
          ),
        ),
        tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: SigapColors.bgSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SigapColors.borderCard,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.inbox_outlined,
                          size: 40,
                          color: SigapColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: SigapSpacing.lg),
                      const Text(
                        'Tidak ada tugas',
                        style: TextStyle(
                          fontSize: SigapTypography.size16,
                          fontWeight: FontWeight.w600,
                          color: SigapColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.all(SigapSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = tasks[index];
                  final taskId = task.taskId ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: SigapSpacing.md),
                    child: _SinkronTaskCard(
                      title: task.reportTitle ?? '-',
                      taskId: taskId,
                      location: '-',
                      onTap: () {
                        if (taskId.isNotEmpty) {
                          context.push('/surveyor/tasks/$taskId');
                        }
                      },
                    ),
                  );
                }, childCount: tasks.length),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) =>
              SliverFillRemaining(child: Center(child: Text('Error: $error'))),
        ),
      ],
    );
  }
}

/// Task card for Sinkron tab
class _SinkronTaskCard extends StatelessWidget {
  final String title;
  final String taskId;
  final String location;
  final VoidCallback onTap;

  const _SinkronTaskCard({
    required this.title,
    required this.taskId,
    required this.location,
    required this.onTap,
  });

  String get _taskIdDisplay {
    if (taskId.startsWith('TGS-')) return taskId;
    return 'TGS-$taskId';
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
        padding: const EdgeInsets.all(SigapSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SigapColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: SigapColors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SigapSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                      fontFamily: 'IBM Plex Mono',
                      fontSize: SigapTypography.size11,
                      color: SigapColors.textTertiary,
                    ),
                  ),
                  if (location != '-') ...[
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: SigapTypography.size11_5,
                        color: SigapColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SigapColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Riwayat tab - history of submitted visits
class _RiwayatTab extends ConsumerWidget {
  const _RiwayatTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: SigapColors.bgCard,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SigapSpacing.lg),
            child: Row(
              children: [
                const Text(
                  'Riwayat',
                  style: TextStyle(
                    fontSize: SigapTypography.size19,
                    fontWeight: FontWeight.w700,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
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
                const Text(
                  'Belum ada riwayat',
                  style: TextStyle(
                    fontSize: SigapTypography.size16,
                    fontWeight: FontWeight.w600,
                    color: SigapColors.textPrimary,
                  ),
                ),
                const SizedBox(height: SigapSpacing.xs),
                const Text(
                  'Visit yang dikirim akan muncul di sini',
                  style: TextStyle(
                    fontSize: SigapTypography.size13,
                    color: SigapColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 2-tab bottom navigation for surveyor screens.
/// Matches PantauDesa S-01 design.
class _Surveyor2TabNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _Surveyor2TabNav({required this.selectedIndex, required this.onTap});

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    IconData activeIcon,
  ) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected
                  ? SigapColors.primary
                  : SigapColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? SigapColors.primary
                    : SigapColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E7E2), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 9, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Sinkron', Icons.sync_outlined, Icons.sync),
          _buildNavItem(1, 'Riwayat', Icons.history_outlined, Icons.history),
        ],
      ),
    );
  }
}
