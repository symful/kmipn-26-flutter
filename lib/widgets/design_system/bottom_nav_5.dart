import 'package:flutter/material.dart';
import 'package:sigap/l10n/strings.dart';
import 'package:sigap/theme/tokens.dart';
import 'package:sigap/components/app_icons.dart';

enum BottomNavVariant { warga, surveyor }

class BottomNav5 extends StatelessWidget {
  final BottomNavVariant variant;
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNav5({
    super.key,
    required this.variant,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == BottomNavVariant.surveyor) {
      return _buildSurveyorNav();
    }
    return _buildWargaNav();
  }

  Widget _buildWargaNav() {
    return Container(
      height: SigapSpacing.x90,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: SigapColors.borderCard, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        SigapSpacing.x12,
        SigapSpacing.x9,
        SigapSpacing.x12,
        SigapSpacing.xl,
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Left side items: Beranda, Peta
          const Positioned(
            left: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WargaNavItem(label: Strings.beranda, index: 0),
                SizedBox(width: SigapSpacing.xl),
                _WargaNavItem(label: Strings.peta, index: 1),
              ],
            ),
          ),
          // Right side items: Laporan, Akun
          const Positioned(
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WargaNavItem(label: Strings.laporan, index: 3),
                SizedBox(width: SigapSpacing.xl),
                _WargaNavItem(label: Strings.akun, index: 4),
              ],
            ),
          ),
          // Center FAB with negative top margin (protrudes above nav bar)
          Positioned(top: -14, child: _buildFAB()),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: SigapColors.primary,
              borderRadius: BorderRadius.circular(SigapRadius.x16),
              boxShadow: SigapShadows.fab,
            ),
            child: const _PlusIcon(),
          ),
          SizedBox(height: SigapSpacing.x4),
          Text(
            Strings.buat,
            style: TextStyle(
              fontSize: SigapTypography.size10,
              fontWeight: FontWeight.w600,
              color: SigapColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyorNav() {
    final items = [
      ('Tugas', Icons.assignment_outlined, Icons.assignment),
      (
        'Peta',
        AppIcons.map.icon ?? Icons.map_outlined,
        AppIcons.mapFilled.icon ?? Icons.map,
      ),
      ('Sinkron', Icons.refresh_outlined, AppIcons.sync.icon ?? Icons.sync),
      ('Riwayat', Icons.history_outlined, Icons.history),
      (
        'Akun',
        AppIcons.person.icon ?? Icons.person_outlined,
        AppIcons.personFilled.icon ?? Icons.person,
      ),
    ];

    return Container(
      height: SigapSpacing.x90,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: SigapColors.borderCard, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        SigapSpacing.sm,
        SigapSpacing.x9,
        SigapSpacing.sm,
        SigapSpacing.xl,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (i) {
          final (label, icon, activeIcon) = items[i];
          return SizedBox(
            width: 60,
            child: _SurveyorNavItem(
              label: label,
              icon: selectedIndex == i ? activeIcon : icon,
              isSelected: selectedIndex == i,
              onTap: () => onTap(i),
            ),
          );
        }),
      ),
    );
  }
}

/// Widget for warga nav items with custom icons per PantauDesa M-05 spec
class _WargaNavItem extends StatelessWidget {
  final String label;
  final int index;

  const _WargaNavItem({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    // Access BottomNav5's selectedIndex via context
    final nav = context.findAncestorWidgetOfExactType<BottomNav5>();
    final selectedIndex = nav?.selectedIndex ?? 0;
    final onTap = nav?.onTap ?? (_) {};
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 18, height: 18, child: _buildIcon(isSelected)),
          SizedBox(height: SigapSpacing.x4),
          Text(
            label,
            style: TextStyle(
              fontSize: SigapTypography.size10,
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w400, // w400 per M-05 inactive spec
              color: isSelected
                  ? SigapColors.primary
                  : SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isSelected) {
    final color = isSelected ? SigapColors.primary : SigapColors.textTertiary;

    switch (index) {
      case 0: // Beranda - rounded square
        return CustomPaint(
          painter: _RoundedSquarePainter(color: color, borderRadius: 5),
        );
      case 1: // Peta - diamond
        return Transform.rotate(
          angle: 0.785398,
          child: CustomPaint(
            painter: _RoundedSquarePainter(color: color, borderRadius: 3),
          ),
        );
      case 3: // Laporan - rectangle
        return SizedBox(
          width: 16,
          height: 18,
          child: CustomPaint(
            painter: _RoundedSquarePainter(
              color: color,
              borderRadius: 3,
              isRectangle: true,
            ),
          ),
        );
      case 4: // Akun - circle
        return CustomPaint(painter: _CirclePainter(color: color));
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Nav item for surveyor variant using Material icons
class _SurveyorNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SurveyorNavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? SigapColors.primary : SigapColors.textTertiary,
          ),
          SizedBox(height: SigapSpacing.x4),
          Text(
            label,
            style: TextStyle(
              fontSize: SigapTypography.size10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? SigapColors.primary
                  : SigapColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for rounded square icons
class _RoundedSquarePainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final bool isRectangle;

  _RoundedSquarePainter({
    required this.color,
    required this.borderRadius,
    this.isRectangle = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _RoundedSquarePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// Custom painter for circle icons
class _CirclePainter extends CustomPainter {
  final Color color;

  _CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 2) / 2;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Plus icon for FAB matching PantauDesa M-05 spec
class _PlusIcon extends StatelessWidget {
  const _PlusIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(20, 20), painter: _PlusIconPainter());
  }
}

class _PlusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Horizontal bar: positioned 9px from top, 2px from left
    canvas.drawLine(const Offset(2, 9), const Offset(18, 9), paint);

    // Vertical bar: positioned 9px from left, 2px from top
    canvas.drawLine(const Offset(9, 2), const Offset(9, 18), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
