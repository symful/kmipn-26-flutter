import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Full-screen photo viewer with swipe navigation and pinch-to-zoom.
///
/// Use [PhotoFullScreen.show] to launch this as a modal full-screen route.
class PhotoFullScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const PhotoFullScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  /// Launch the full-screen photo viewer as a modal route.
  static Future<void> show(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PhotoFullScreen(photos: photos, initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<PhotoFullScreen> createState() => _PhotoFullScreenState();
}

class _PhotoFullScreenState extends State<PhotoFullScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SigapColors.textPrimary,
      appBar: AppBar(
        backgroundColor: SigapColors.textPrimary,
        foregroundColor: SigapColors.surface,
        title: Text('${_currentIndex + 1} / ${widget.photos.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.photos[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: SigapColors.surface,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
