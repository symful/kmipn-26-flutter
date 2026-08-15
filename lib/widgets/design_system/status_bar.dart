import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String time;

  const StatusBar({super.key, this.time = '09:41'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Row(children: [_buildBatteryIcon()]),
        ],
      ),
    );
  }

  Widget _buildBatteryIcon() {
    return Row(
      children: [
        const Icon(Icons.wifi, size: 16),
        const SizedBox(width: 4),
        const Icon(Icons.signal_cellular_alt, size: 16),
        const SizedBox(width: 4),
        Container(
          width: 16,
          height: 9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 6,
              height: 5,
              margin: const EdgeInsets.only(right: 1),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
