import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

enum PhotoTileVariant { filled, empty, withLabel }

class PhotoTile extends StatelessWidget {
  final Widget? photo;
  final String? label;
  final PhotoTileVariant variant;
  final VoidCallback? onTap;

  const PhotoTile({
    super.key,
    this.photo,
    this.label,
    required this.variant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: variant == PhotoTileVariant.empty
            ? _buildEmpty()
            : variant == PhotoTileVariant.withLabel
            ? _buildWithLabel()
            : _buildFilled(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: SigapColors.borderSoft,
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Center(
        child: Icon(Icons.add, color: SigapColors.textDisabled, size: 24),
      ),
    );
  }

  Widget _buildFilled() {
    if (photo != null) return photo!;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigapColors.primaryLight, SigapColors.borderCard],
        ),
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }

  Widget _buildWithLabel() {
    return Column(
      children: [
        Expanded(child: _buildFilled()),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 11,
                color: SigapColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
