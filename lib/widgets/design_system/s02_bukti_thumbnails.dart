import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Horizontal scrollable row of image thumbnails for S-02 surveyor task detail screen.
///
/// Displays report evidence photos from warga with rounded square thumbnails.
/// Each thumbnail supports tap-to-zoom functionality via [onThumbnailTap] callback.
///
/// Design tokens used:
/// - Thumbnail size: 72x72px
/// - Border radius: SigapRadius.x9 (9px)
/// - Background: SigapColors.bgSurface (#F4F5F3)
/// - Gap between thumbnails: SigapSpacing.sm (8px)
///
/// Example:
/// ```dart
/// S02BuktiThumbnails(
///   imageUrls: ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'],
///   onThumbnailTap: (index) => _showFullScreenImage(index),
/// )
/// ```
class S02BuktiThumbnails extends StatelessWidget {
  /// List of image URLs to display as thumbnails.
  final List<String> imageUrls;

  /// Callback when a thumbnail is tapped.
  /// Provides the index of the tapped thumbnail.
  final void Function(int index)? onThumbnailTap;

  /// Creates bukti thumbnails widget.
  ///
  /// [imageUrls] is required and should contain valid image URLs.
  /// [onThumbnailTap] is optional and called when user taps a thumbnail.
  const S02BuktiThumbnails({
    super.key,
    required this.imageUrls,
    this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: SigapSpacing.sm),
        itemBuilder: (context, index) {
          return _ThumbnailItem(
            imageUrl: imageUrls[index],
            index: index,
            onTap: onThumbnailTap != null ? () => onThumbnailTap!(index) : null,
          );
        },
      ),
    );
  }
}

class _ThumbnailItem extends StatelessWidget {
  final String imageUrl;
  final int index;
  final VoidCallback? onTap;

  const _ThumbnailItem({
    required this.imageUrl,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: SigapColors.bgSurface,
          borderRadius: BorderRadius.circular(SigapRadius.x9),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const _ImagePlaceholder();
              },
            ),

            // Tap-to-zoom hint overlay (semi-transparent indicator in corner)
            if (onTap != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: SigapColors.textPrimary.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(SigapRadius.x4),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    size: 12,
                    color: SigapColors.surface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SigapColors.bgSurface,
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: SigapColors.textDisabled,
      ),
    );
  }
}
