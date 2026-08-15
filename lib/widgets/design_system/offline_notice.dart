import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

class OfflineNotice extends StatelessWidget {
  final String message;

  const OfflineNotice({super.key, this.message = 'Tidak ada koneksi internet'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: AppTypography.size11_5,
              color: AppColors.warningText,
            ),
          ),
        ),
      ],
    );
  }
}
