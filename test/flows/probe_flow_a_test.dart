import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_tokens.dart';
import '../../lib/api/api_client.dart';
import '../../lib/api/exceptions.dart';

const _baseUrl = 'https://kmipn-26-deno.careday17.workers.dev';

ApiClient _client(String token) => ApiClient(
  baseUrl: _baseUrl,
  dio: Dio(
    BaseOptions(baseUrl: _baseUrl, headers: {'Authorization': 'Bearer $token'}),
  ),
  checkConnectivity: () async {},
);

void main() {
  test('probe FLOW-A endpoints raw', () async {
    final tok = tokenFor(TestRole.warga);
    print('TOKENJSON=' + jsonEncode(tok));
    print('TOKEN len= tail=... head=');
    final client = _client(tok);

    Future<void> probe(String name, Future<Object?> Function() fn) async {
      try {
        final r = await fn();
        print(
          'PROBE $name -> OK ${r is List ? "list(${r.length})" : r.runtimeType}',
        );
      } on ApiException catch (e) {
        print(
          'PROBE $name -> ApiException status=${e.statusCode} endpoint=${e.endpoint} body=${e.body}',
        );
      } catch (e) {
        print('PROBE $name -> ${e.runtimeType}: $e');
      }
    }

    await probe('GET /api/categories', () => client.getCategories());
    await probe('GET /api/auth/me', () => client.getAuthMe());
    await probe(
      'GET nearby',
      () => client.getNearbyReports(lat: -6.2, lng: 106.8),
    );
    await probe(
      'GET duplicates',
      () => client.getDuplicateCases(lat: -6.2, lng: 106.8),
    );
    await probe('POST createReport', () async {
      final up = await client.uploadReportPhotoAnon(
        filePath: '../kmipn-26-deno/.run/none.png',
        idempotencyKey: 'probe-up-${DateTime.now().millisecondsSinceEpoch}',
      );
      return up;
    });
    await probe('GET auth/me again', () => client.getAuthMe());
    await probe('GET duplicates WITH categoryId', () async {
      final cats = await client.getCategories();
      final cid = cats.where((c) => c.id != null).first.id!;
      print('  using categoryId=$cid');
      return await client.getDuplicateCases(
        lat: -6.2,
        lng: 106.8,
        categoryId: cid,
      );
    });
    await probe('POST createReport minimal', () async {
      final cats = await client.getCategories();
      return await client.createReport(
        idempotencyKey: 'probe-cr-${DateTime.now().millisecondsSinceEpoch}',
        categoryId: cats.where((c) => c.id != null).first.id!,
        description: 'Probe test report description long enough',
        lat: -6.2,
        lng: 106.8,
      );
    });
    await probe('GET warga stats', () => client.getWargaStats());
  });
}
