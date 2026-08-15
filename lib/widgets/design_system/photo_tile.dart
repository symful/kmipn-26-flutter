import 'package:flutter/material.dart';

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
          color: const Color(0xFFCFd3CC),
          width: 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Center(
        child: Icon(Icons.add, color: Color(0xFF8A9099), size: 24),
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
          colors: [Color(0xFFE2F1EE), Color(0xFFE4E7E2)],
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
              style: const TextStyle(fontSize: 11, color: Color(0xFF616770)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
