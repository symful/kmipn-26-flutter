import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class StatusBar extends StatelessWidget {
  final String time;

  const StatusBar({super.key, this.time = '09:41'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      // Design: padding 0 24px (horizontal only)
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time: font-size 13, font-weight 600, tabular nums via FontFeature
          Text(
            time,
            style: TextStyle(
              fontSize: SigapTypography.size13,
              fontWeight: FontWeight.w600,
              color: SigapColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          // Signal bars + battery per M-05 spec (line 54)
          Row(
            children: [
              _buildSignalBars(),
              const SizedBox(width: 5),
              _buildBatteryIcon(),
            ],
          ),
        ],
      ),
    );
  }

  /// Signal bars icon per M-05 spec: wifi outline + small fill
  Widget _buildSignalBars() {
    return Row(
      children: [
        // Wifi outline rectangle: 16x9, border 1.4px
        Container(
          width: 16,
          height: 9,
          decoration: BoxDecoration(
            border: Border.all(color: SigapColors.textPrimary, width: 1.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Small fill rectangle: 6x9
        Container(
          width: 6,
          height: 9,
          decoration: BoxDecoration(
            color: SigapColors.textPrimary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryIcon() {
    return Row(
      children: [
        // Battery outline: 16x9, border 1.4px, color #17191c
        Container(
          width: 16,
          height: 9,
          decoration: BoxDecoration(
            border: Border.all(
              color: SigapColors.textPrimary,
              width: 1.4, // Design: 1.4px border
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 6,
              height: 9,
              margin: const EdgeInsets.only(right: 1),
              decoration: BoxDecoration(
                color: SigapColors.textPrimary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
