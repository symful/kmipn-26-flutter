import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

/// Returns the XFile for the given fixture [slug].
///
/// Looks up the file under `test/fixtures/images/<slug>.jpg`
/// and throws if not found.
Future<XFile> fixtureImage(String slug) async {
  final file = File('test/fixtures/images/$slug.jpg');
  if (!await file.exists()) {
    throw Exception("Fixture image not found: $slug.jpg");
  }
  return XFile(file.path);
}

/// Loads the fixture manifest from `test/fixtures/images/manifest.json`.
Map<String, dynamic> fixtureManifest() {
  final file = File('test/fixtures/images/manifest.json');
  if (!file.existsSync()) {
    throw Exception('Fixture manifest not found: manifest.json');
  }
  final content = file.readAsStringSync();
  return jsonDecode(content) as Map<String, dynamic>;
}
