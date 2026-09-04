import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Data point for backlog trend chart.
class BacklogTrendPoint {
  final String day;
  final int laporanCount;
  final int kasusCount;

  const BacklogTrendPoint({
    required this.day,
    required this.laporanCount,
    required this.kasusCount,
  });
}

/// W-02 BacklogTrendChart — 30-day trend visualization using CustomPainter.
///
/// Displays dual-line chart with area fill for:
/// - Laporan (reports/submissions) in [SigapColors.info]
/// - Kasus (verified cases) in [SigapColors.primary]
///
/// No hardcoded values — all dimensions derived from data and layout constraints.
class BacklogTrendChart extends StatelessWidget {
  /// 30-day trend data points, oldest first.
  final List<BacklogTrendPoint> data;

  /// Chart title displayed in header.
  final String title;

  const BacklogTrendChart({
    super.key,
    required this.data,
    this.title = 'Umur backlog kasus',
  });

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: const EdgeInsets.all(SigapSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartHeader(title: title),
          const SizedBox(height: SigapSpacing.md),
          Expanded(
            child: data.isEmpty ? const _EmptyState() : _TrendChart(data: data),
          ),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final String title;

  const _ChartHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: SigapTypography.bodyText,
            fontWeight: FontWeight.w600,
            color: SigapColors.textPrimary,
          ),
        ),
        const _ChartLegend(),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LegendDot(color: SigapColors.info),
        const SizedBox(width: SigapSpacing.xs),
        const Text(
          'laporan',
          style: TextStyle(
            fontSize: SigapTypography.captionSmall,
            color: SigapColors.textTertiary,
          ),
        ),
        const SizedBox(width: SigapSpacing.sm),
        const _LegendDot(color: SigapColors.primary),
        const SizedBox(width: SigapSpacing.xs),
        const Text(
          'kasus',
          style: TextStyle(
            fontSize: SigapTypography.captionSmall,
            color: SigapColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Tidak ada data tren',
        style: TextStyle(
          color: SigapColors.textMuted,
          fontSize: SigapTypography.bodyText,
        ),
      ),
    );
  }
}

/// Dual-line trend chart with area fill, rendered via CustomPainter.
class _TrendChart extends StatelessWidget {
  final List<BacklogTrendPoint> data;

  const _TrendChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartPainter = _BacklogChartPainter(
          data: data,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
        );

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: chartPainter,
        );
      },
    );
  }
}

class _BacklogChartPainter extends CustomPainter {
  final List<BacklogTrendPoint> data;
  final double width;
  final double height;

  static const double _leftPadding = 36.0;
  static const double _bottomPadding = 24.0;
  static const double _topPadding = 8.0;
  static const double _rightPadding = 8.0;

  _BacklogChartPainter({
    required this.data,
    required this.width,
    required this.height,
  });

  /// Derives max Y value from data, minimum 1 to avoid division issues.
  int get _maxY {
    int maxVal = 1;
    for (final point in data) {
      if (point.laporanCount > maxVal) maxVal = point.laporanCount;
      if (point.kasusCount > maxVal) maxVal = point.kasusCount;
    }
    // Round up to nearest nice interval
    return _niceCeil(maxVal);
  }

  /// Round up to a nice interval for axis labeling.
  int _niceCeil(int value) {
    if (value <= 5) return 5;
    if (value <= 10) return 10;
    if (value <= 25) return 25;
    if (value <= 50) return 50;
    if (value <= 100) return 100;
    final mag = (value / 10).ceil() * 10;
    return ((mag / 10).ceil() * 10);
  }

  /// Number of Y-axis grid lines and labels.
  int get _yDivisions => 4;

  double get _chartWidth => width - _leftPadding - _rightPadding;
  double get _chartHeight => height - _topPadding - _bottomPadding;

  double _xPos(int index) {
    if (data.length <= 1) return _leftPadding + _chartWidth / 2;
    return _leftPadding + (index / (data.length - 1)) * _chartWidth;
  }

  double _yPos(int value) {
    final ratio = value / _maxY;
    return _topPadding + _chartHeight * (1 - ratio);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    _drawGrid(canvas);
    _drawAxes(canvas);
    _drawAreaAndLines(canvas);
    _drawLabels(canvas);
  }

  void _drawGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = SigapColors.border.withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 0; i <= _yDivisions; i++) {
      final y = _topPadding + (_chartHeight / _yDivisions) * i;
      canvas.drawLine(
        Offset(_leftPadding, y),
        Offset(width - _rightPadding, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas) {
    final axisPaint = Paint()
      ..color = SigapColors.border
      ..strokeWidth = 1;

    // Y-axis
    canvas.drawLine(
      Offset(_leftPadding, _topPadding),
      Offset(_leftPadding, height - _bottomPadding),
      axisPaint,
    );

    // X-axis
    canvas.drawLine(
      Offset(_leftPadding, height - _bottomPadding),
      Offset(width - _rightPadding, height - _bottomPadding),
      axisPaint,
    );
  }

  void _drawAreaAndLines(Canvas canvas) {
    if (data.length < 2) return;

    final laporanPath = Path();
    final kasusPath = Path();
    final laporanFillPath = Path();
    final kasusFillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = _xPos(i);
      final yLaporan = _yPos(data[i].laporanCount);
      final yKasus = _yPos(data[i].kasusCount);

      if (i == 0) {
        laporanPath.moveTo(x, yLaporan);
        kasusPath.moveTo(x, yKasus);
        laporanFillPath.moveTo(x, height - _bottomPadding);
        laporanFillPath.lineTo(x, yLaporan);
        kasusFillPath.moveTo(x, height - _bottomPadding);
        kasusFillPath.lineTo(x, yKasus);
      } else {
        laporanPath.lineTo(x, yLaporan);
        kasusPath.lineTo(x, yKasus);
        laporanFillPath.lineTo(x, yLaporan);
        kasusFillPath.lineTo(x, yKasus);
      }
    }

    // Close fill paths
    final lastX = _xPos(data.length - 1);
    laporanFillPath.lineTo(lastX, height - _bottomPadding);
    laporanFillPath.close();
    kasusFillPath.lineTo(lastX, height - _bottomPadding);
    kasusFillPath.close();

    // Draw area fills with gradients
    final laporanFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          SigapColors.info.withOpacity(0.25),
          SigapColors.info.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    final kasusFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          SigapColors.primary.withOpacity(0.2),
          SigapColors.primary.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(laporanFillPath, laporanFillPaint);
    canvas.drawPath(kasusFillPath, kasusFillPaint);

    // Draw lines
    final laporanLinePaint = Paint()
      ..color = SigapColors.info
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final kasusLinePaint = Paint()
      ..color = SigapColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(laporanPath, laporanLinePaint);
    canvas.drawPath(kasusPath, kasusLinePaint);

    // Draw data points
    _drawDataPoints(canvas, laporanPath, SigapColors.info);
    _drawDataPoints(canvas, kasusPath, SigapColors.primary);
  }

  void _drawDataPoints(Canvas canvas, Path linePath, Color color) {
    final metric = linePath.computeMetrics();
    for (final m in metric) {
      final totalLength = m.length;
      const dotInterval = 40.0;
      double distance = 0;
      while (distance < totalLength) {
        final tangent = m.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3, Paint()..color = color);
          canvas.drawCircle(
            tangent.position,
            5,
            Paint()
              ..color = color.withOpacity(0.3)
              ..style = PaintingStyle.fill,
          );
        }
        distance += dotInterval;
      }
    }
  }

  void _drawLabels(Canvas canvas) {
    final textStyle = const TextStyle(
      color: SigapColors.textTertiary,
      fontSize: SigapTypography.captionMicro,
    );

    // Y-axis labels
    for (int i = 0; i <= _yDivisions; i++) {
      final value = ((_yDivisions - i) / _yDivisions * _maxY).round();
      final y = _topPadding + (_chartHeight / _yDivisions) * i;

      final textSpan = TextSpan(text: value.toString(), style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          _leftPadding - textPainter.width - 4,
          y - textPainter.height / 2,
        ),
      );
    }

    // X-axis labels — show first, middle, and last
    if (data.isNotEmpty) {
      final labelIndices = <int>[];
      if (data.length == 1) {
        labelIndices.add(0);
      } else if (data.length == 2) {
        labelIndices.addAll([0, 1]);
      } else {
        labelIndices.add(0);
        labelIndices.add(data.length ~/ 2);
        labelIndices.add(data.length - 1);
      }

      for (final idx in labelIndices) {
        final x = _xPos(idx);
        final textSpan = TextSpan(text: data[idx].day, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, height - _bottomPadding + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BacklogChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}

/// Signature matches existing SigapCard used throughout the codebase.
class SigapCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderLeftColor;

  const SigapCard({
    super.key,
    required this.child,
    this.padding,
    this.borderLeftColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(SigapSpacing.md),
      decoration: BoxDecoration(
        color: SigapColors.surface,
        borderRadius: BorderRadius.circular(SigapRadius.md),
        border: Border.all(color: SigapColors.border),
      ),
      child: child,
    );
  }
}
