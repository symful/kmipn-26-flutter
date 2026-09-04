import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

/// Returns the appropriate [ImageSource] for the current platform.
///
/// On mobile (Android/iOS), uses [ImageSource.camera] as requested.
/// On desktop (Windows/macOS/Linux) and web, falls back to [ImageSource.gallery]
/// because desktop platforms require a cameraDelegate to be registered for
/// camera access, and most desktop environments don't have a built-in camera.
ImageSource cameraSource() {
  if (kIsWeb) return ImageSource.gallery;
  if (Platform.isAndroid || Platform.isIOS) return ImageSource.camera;
  return ImageSource.gallery;
}
