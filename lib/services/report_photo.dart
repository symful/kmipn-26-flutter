import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Public derivative only. Original bytes travel separately to private evidence storage.
Uint8List publicReportPhoto(Uint8List original) {
  if (original.length < 12) throw const FormatException('Unsupported image');
  var image = img.decodeImage(original);
  if (image == null) throw const FormatException('Unsupported image');
  image = img.bakeOrientation(image);
  if (image.width > 1920 || image.height > 1920) {
    image = img.copyResize(
      image,
      width: image.width >= image.height ? 1920 : null,
      height: image.height > image.width ? 1920 : null,
    );
  }
  image.exif = img.ExifData();
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}
