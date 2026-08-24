import 'dart:io';
import 'dart:convert';

/// Names of all pre-generated fixture files in `test/fixtures/images/`.
/// Each entry corresponds to an existing fx-*.jpg file.
const kFixtureNames = <String>{
  'fx-road-potholes',
  'fx-bridge-damage',
  'fx-drainage-clog',
  'fx-streetlight-broken',
  'fx-water-pump-cracked',
  'fx-building-crack-small',
  'fx-road-intact-clean',
  'fx-repair-progress',
};

/// Returns the path to a freshly written minimal JPEG (1x1 pixel).
/// Writes to system temp dir; cleans up after test.
Future<String> writeSampleJpeg({String name = 'sample.jpg'}) async {
  // Minimal JPEG (1x1 white pixel) — 125 bytes base64.
  const b64 =
      '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAr/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAMAwEAAhEDEQA/AL+AB//Z';
  final bytes = base64Decode(b64);
  final dir = await Directory.systemTemp.createTemp('sigap_test_');
  final file = File('${dir.path}/$name')..writeAsBytesSync(bytes);
  return file.path;
}

/// Copies a pre-generated fixture file from `test/fixtures/images/` into a
/// temp directory and returns the temp path.
///
/// Throws [ArgumentError] if [fixtureName] is not in [kFixtureNames].
/// No regeneration — simply copies the existing file.
///
/// Example:
///   final path = await writeFixture('fx-road-potholes');
Future<String> writeFixture(String fixtureName) async {
  if (!kFixtureNames.contains(fixtureName)) {
    throw ArgumentError.value(
      fixtureName,
      'fixtureName',
      'Unknown fixture. Available: $kFixtureNames',
    );
  }

  // Map fixture name to actual file name on disk (some have _001 suffix)
  final fileName = '${fixtureName}_001.jpg';
  final sourceDir = Directory('test/fixtures/images');
  final sourcePath = '${sourceDir.path}/$fileName';

  final sourceFile = File(sourcePath);
  if (!sourceFile.existsSync()) {
    throw StateError(
      'Fixture file not found: $sourcePath  '
      '(fixture "$fixtureName" is registered in kFixtureNames but the '
      'actual file is missing from test/fixtures/images/)',
    );
  }

  final tempDir = await Directory.systemTemp.createTemp('sigap_fixture_');
  final destPath = '${tempDir.path}/$fileName';
  await sourceFile.copy(destPath);
  return destPath;
}
