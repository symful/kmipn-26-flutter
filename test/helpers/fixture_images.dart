import 'dart:io';
import 'dart:convert';

/// Returns the File for the given fixture [slug].
///
/// Looks up the file under `test/fixtures/images/<slug>.jpg`
/// and throws if not found.
File fixtureImage(String slug) {
  final file = File('test/fixtures/images/$slug.jpg');
  // Resolve to absolute path so the file can be found regardless of cwd
  final absolutePath = file.absolute.path;
  final absoluteFile = File(absolutePath);
  if (!absoluteFile.existsSync()) {
    throw Exception("Fixture image not found: $slug.jpg at $absolutePath");
  }
  return absoluteFile;
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
