import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sigap/features/verifikator/case_detail_screen.dart';
import 'package:sigap/api/types.g.dart';
import 'package:sigap/providers/providers.dart';
import 'package:sigap/api/api_client.dart';

class MockApiClient extends Fake implements ApiClient {
  final CaseDetail mockCaseDetail;
  final TimelineEnvelope? mockTimeline;

  MockApiClient({required this.mockCaseDetail, this.mockTimeline});

  @override
  Future<CaseDetail> getVerifikatorCase(String caseId) async {
    return mockCaseDetail;
  }

  @override
  Future<AiAssessmentResult> getAiAssessment(String caseId) async {
    return AiAssessmentResult(
      confidenceScore: 0.5,
      supportingFactors: [],
      riskFactors: [],
      duplicateCandidates: [],
    );
  }

  @override
  Future<TimelineEnvelope> getReportTimeline(String caseId) async {
    return mockTimeline ?? TimelineEnvelope(events: []);
  }

  @override
  Future<List<UserResponse>> getSurveyors() async {
    return [
      UserResponse(
        id: 's1',
        email: 'survey1@test.com',
        name: 'Surveyor 1',
        role: 'SURVEYOR',
      ),
    ];
  }

  @override
  Future<DecideResult> decideVerifikatorCase({
    required String caseId,
    required String decision,
    required String reason,
    String? duplicateOfReportId,
    String? surveyorId,
    String? assignedUnitId,
    String? deadline,
  }) async {
    return DecideResult(decision: decision, status: 'verified');
  }
}

CaseDetail buildMockCase({
  String status = 'submitted',
  String? title = 'Test Report Title',
  String? description = 'Test report description for verification',
}) {
  return CaseDetail(
    report: Report(
      id: 'r1',
      title: title,
      description: description,
      status: ReportStatus.fromJson(status),
      category: 'Jalan',
      location: {'lat': -6.9, 'lng': 107.61},
      photos: [],
      createdAt: '2026-08-20T10:00:00Z',
    ),
  );
}

void main() {
  testWidgets('VerifikasiCaseDetailScreen renders 6 decision buttons', (
    tester,
  ) async {
    final mockClient = MockApiClient(mockCaseDetail: buildMockCase());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(mockClient)],
        child: MaterialApp(home: VerifikasiCaseDetailScreen(caseId: 'r1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Valid'), findsOneWidget);
    expect(find.text('Lengkapi'), findsOneWidget);
    expect(find.text('Survei'), findsOneWidget);
    expect(find.text('Duplikat'), findsOneWidget);
    expect(find.text('Diluar'), findsOneWidget);
    expect(find.text('Tolak'), findsOneWidget);
  });
}
