import 'package:flutter/material.dart';
import 'package:sigap/theme/tokens.dart';

/// Direction names for the 4 photo corners.
enum FotoSudutDirection {
  utara('Utara'),
  timur('Timur'),
  selatan('Selatan'),
  barat('Barat');

  final String label;
  const FotoSudutDirection(this.label);
}

/// Status of a single photo spot.
enum FotoSpotStatus {
  /// No photo captured yet.
  empty,

  /// Photo has been captured.
  captured,

  /// Photo was captured but user wants to retake.
  retake,
}

/// Data for a single photo spot in the grid.
class FotoSpot {
  final FotoSudutDirection direction;
  final FotoSpotStatus status;
  final String? photoPath;

  const FotoSpot({
    required this.direction,
    this.status = FotoSpotStatus.empty,
    this.photoPath,
  });
}

/// 2x2 grid of photo capture spots (4 corners: Utara, Timur, Selatan, Barat).
///
/// Each spot displays a labeled placeholder box that can show a captured photo thumbnail.
/// Tapping a spot triggers [onPhotoTap] callback for capture/retake.
///
/// Design tokens used:
/// - Grid gap: AppSpacing.sm (8px)
/// - Photo spot size: flexible (fills grid cell)
/// - Placeholder border radius: AppRadius.md (10px)
/// - Label font: AppTypography.size11, fontWeight 600
/// - Status indicator: small rounded pill
///
/// Example:
/// ```dart
/// S04FotoSudut(
///   capturedPhotos: {
///     'utara': '/path/to/utara.jpg',
///     'timur': null,
///     'selatan': '/path/to/selatan.jpg',
///     'barat': '/path/to/barat.jpg',
///   },
///   onPhotoTap: (direction) => _capturePhoto(direction),
/// )
/// ```
class S04FotoSudut extends StatelessWidget {
  /// Map of direction name to captured photo path/url.
  /// Directions: 'utara', 'timur', 'selatan', 'barat'.
  /// Null or absent means no photo captured.
  final Map<String, String?> capturedPhotos;

  /// Callback when user taps a photo spot.
  /// Provides the direction name as string.
  final void Function(String direction)? onPhotoTap;

  /// Creates the foto sudut grid widget.
  ///
  /// [capturedPhotos] is required and maps direction names to photo paths.
  /// [onPhotoTap] is called when user taps a spot to capture/retake photo.
  const S04FotoSudut({
    super.key,
    required this.capturedPhotos,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.0,
      children: FotoSudutDirection.values.map((direction) {
        final directionName = direction.name;
        final photoPath = capturedPhotos[directionName];
        final hasPhoto = photoPath != null && photoPath.isNotEmpty;

        return _FotoSpotTile(
          direction: direction,
          photoPath: photoPath,
          status: hasPhoto ? FotoSpotStatus.captured : FotoSpotStatus.empty,
          onTap: onPhotoTap != null ? () => onPhotoTap!(directionName) : null,
        );
      }).toList(),
    );
  }
}

class _FotoSpotTile extends StatelessWidget {
  final FotoSudutDirection direction;
  final String? photoPath;
  final FotoSpotStatus status;
  final VoidCallback? onTap;

  const _FotoSpotTile({
    required this.direction,
    required this.photoPath,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: hasPhoto ? AppColors.primary : AppColors.borderCard,
            width: hasPhoto ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo or placeholder content
            if (hasPhoto)
              _CapturedPhoto(photoPath: photoPath!)
            else
              _PhotoPlaceholder(direction: direction),

            // Direction label at top-left
            Positioned(
              top: AppSpacing.x6,
              left: AppSpacing.x6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x6,
                  vertical: AppSpacing.x4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppRadius.x4),
                ),
                child: Text(
                  direction.label,
                  style: const TextStyle(
                    fontSize: AppTypography.size11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Status indicator at bottom-right
            Positioned(
              bottom: AppSpacing.x6,
              right: AppSpacing.x6,
              child: _StatusIndicator(
                status: hasPhoto
                    ? FotoSpotStatus.captured
                    : FotoSpotStatus.empty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapturedPhoto extends StatelessWidget {
  final String photoPath;

  const _CapturedPhoto({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    // Check if it's a network URL or local file path
    final isNetwork =
        photoPath.startsWith('http://') || photoPath.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PhotoErrorPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const _PhotoLoadingPlaceholder();
        },
      );
    } else {
      return Image.asset(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _PhotoErrorPlaceholder(),
      );
    }
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final FotoSudutDirection direction;

  const _PhotoPlaceholder({required this.direction});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 28,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.x4),
          Text(
            'Tap untuk foto',
            style: TextStyle(
              fontSize: AppTypography.size10,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoLoadingPlaceholder extends StatelessWidget {
  const _PhotoLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _PhotoErrorPlaceholder extends StatelessWidget {
  const _PhotoErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 28,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: AppSpacing.x4),
          Text(
            'Gagal memuat',
            style: TextStyle(
              fontSize: AppTypography.size10,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final FotoSpotStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final String text;
    final IconData icon;

    switch (status) {
      case FotoSpotStatus.captured:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        text = 'Tersimpan';
        icon = Icons.check;
        break;
      case FotoSpotStatus.retake:
        backgroundColor = AppColors.warning;
        textColor = Colors.white;
        text = 'Ulangi';
        icon = Icons.refresh;
        break;
      default:
        backgroundColor = AppColors.textDisabled.withValues(alpha: 0.8);
        textColor = Colors.white;
        text = 'Kosong';
        icon = Icons.add;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x6,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: AppSpacing.x4),
          Text(
            text,
            style: TextStyle(
              fontSize: AppTypography.size9,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
