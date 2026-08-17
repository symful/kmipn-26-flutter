import 'dart:convert';
import 'dart:io';

/// Records test evidence including JSON diffs.
///
/// Evidence is saved to .sisyphus/evidence/integration_test/
class EvidenceRecorder {
  final String evidencePath;
  final String testName;
  int _stepCount = 0;

  EvidenceRecorder({required this.evidencePath, required this.testName});

  /// Records a new test step with metadata.
  Future<void> recordStep({
    required String stepName,
    String? description,
    Map<String, dynamic>? requestBody,
    Map<String, dynamic>? responseBody,
    int? httpStatusCode,
  }) async {
    _stepCount++;
    final stepFolder = _createStepFolder(_stepCount, stepName);

    // Save step metadata
    final metadata = {
      'step': _stepCount,
      'name': stepName,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
      'httpStatusCode': httpStatusCode,
    };
    await _saveJson('$stepFolder/metadata.json', metadata);

    // Save request body if provided
    if (requestBody != null) {
      await _saveJson('$stepFolder/request.json', requestBody);
    }

    // Save response body if provided
    if (responseBody != null) {
      await _saveJson('$stepFolder/response.json', responseBody);
    }
  }

  /// Records a JSON diff between expected and actual values.
  Future<void> recordJsonDiff({
    required String diffName,
    required Map<String, dynamic> expected,
    required Map<String, dynamic> actual,
  }) async {
    final diffFolder = '$evidencePath/diffs';
    await Directory(diffFolder).create(recursive: true);

    final diff = {
      'name': diffName,
      'timestamp': DateTime.now().toIso8601String(),
      'expected': expected,
      'actual': actual,
      'diff': _computeJsonDiff(expected, actual),
    };

    final safeName = diffName.replaceAll(RegExp(r'[^\w\-]'), '_');
    await _saveJson('$diffFolder/${safeName}_$_stepCount.json', diff);
  }

  /// Records an assertion failure with context.
  Future<void> recordAssertionFailure({
    required String assertionName,
    required String message,
    Map<String, dynamic>? context,
  }) async {
    final failureFolder = '$evidencePath/failures';
    await Directory(failureFolder).create(recursive: true);

    final failure = {
      'assertion': assertionName,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'step': _stepCount,
      'context': context,
    };

    await _saveJson(
      '$failureFolder/${assertionName}_$_stepCount.json',
      failure,
    );
  }

  String _createStepFolder(int step, String name) {
    final safeName = name.replaceAll(RegExp(r'[^\w\-]'), '_');
    final folder = '$evidencePath/steps/${safeName}_$step';
    Directory(folder).createSync(recursive: true);
    return folder;
  }

  Future<void> _saveJson(String path, Map<String, dynamic> data) async {
    final file = File(path);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Map<String, dynamic> _computeJsonDiff(
    Map<String, dynamic> expected,
    Map<String, dynamic> actual,
  ) {
    final diff = <String, dynamic>{};

    for (final key in {...expected.keys, ...actual.keys}) {
      if (!expected.containsKey(key)) {
        diff[key] = {'status': 'added', 'value': actual[key]};
      } else if (!actual.containsKey(key)) {
        diff[key] = {'status': 'removed', 'value': expected[key]};
      } else if (expected[key] != actual[key]) {
        diff[key] = {
          'status': 'changed',
          'expected': expected[key],
          'actual': actual[key],
        };
      }
    }

    return diff;
  }
}

/// Mixin to add evidence recording to integration tests.
mixin EvidenceRecording {
  EvidenceRecorder? _recorder;

  EvidenceRecorder createRecorder(String testName, String evidencePath) {
    _recorder = EvidenceRecorder(
      evidencePath: evidencePath,
      testName: testName,
    );
    return _recorder!;
  }

  EvidenceRecorder? get recorder => _recorder;
}
