import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// A timeline event entry showing a status change with actor attribution.
///
/// Used in M-14 Detail Laporan screen to show report history.
///
/// Design spec: PantauDesa Screens.dc.html lines 229-236
class TimelineEvent {
  /// The status/title of this timeline entry (e.g., "Perlu dilengkapi").
  final String title;

  /// The timestamp and actor info (e.g., "17 Jul, 14:20 · oleh verifikator RW").
  final String meta;

  /// Whether this is the most recent/active event (shows amber highlight).
  final bool isActive;

  const TimelineEvent({
    required this.title,
    required this.meta,
    this.isActive = false,
  });
}

/// A vertical timeline widget showing report history with actor names.
///
/// Displays a list of [TimelineEvent] entries with dots, connecting lines,
/// timestamps, and actor attribution.
///
/// Design spec: PantauDesa Screens.dc.html lines 229-236
class VerticalTimeline extends StatelessWidget {
  /// The list of timeline events to display, in chronological order (oldest first).
  final List<TimelineEvent> events;

  /// Optional header text (default: "Perjalanan laporan").
  final String? headerText;

  const VerticalTimeline({super.key, required this.events, this.headerText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          headerText ?? 'Perjalanan laporan',
          style: const TextStyle(
            fontSize: SigapTypography.size12,
            fontWeight: FontWeight.w700,
            color: SigapColors.textTertiary,
            letterSpacing: SigapTypography.letterSpacingLabel,
          ),
        ),
        const SizedBox(height: SigapSpacing.x4),
        // Timeline entries
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(children: _buildTimelineEntries()),
        ),
      ],
    );
  }

  List<Widget> _buildTimelineEntries() {
    if (events.isEmpty) return [];

    final List<Widget> entries = [];
    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      final isLast = i == events.length - 1;
      entries.add(_TimelineEntry(event: event, isLast: isLast));
    }
    return entries;
  }
}

class _TimelineEntry extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const _TimelineEntry({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dot and line column
          _buildDotColumn(),
          const SizedBox(width: 12),
          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildDotColumn() {
    return SizedBox(
      width: 20,
      child: Column(
        children: [
          // Dot
          _buildDot(),
          // Line (if not last)
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                constraints: const BoxConstraints(minHeight: 22),
                color: SigapColors.borderCard,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    if (event.isActive) {
      // Active event: 13px amber dot with white border and amber shadow ring
      return Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SigapColors.warning,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: SigapColors.warning, spreadRadius: 2, blurRadius: 0),
          ],
        ),
      );
    } else {
      // Normal event: 11px teal dot with 1px top margin
      return Container(
        width: 11,
        height: 11,
        margin: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: SigapColors.primary,
        ),
      );
    }
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: SigapTypography.size13,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            event.meta,
            style: const TextStyle(
              fontSize: SigapTypography.size11,
              color: SigapColors.textTertiary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
