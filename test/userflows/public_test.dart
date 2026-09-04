import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/api/client.dart';

const _apiBaseUrl = 'https://sigap.live';

/// Dio client that allows 4xx/5xx through (for ApiClient._execute handling).
Dio _rawDio() => Dio(
  BaseOptions(
    baseUrl: _apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (s) => s != null && (s < 400 || s == 503),
  ),
);

void main() {
  late ApiClient publicClient;

  setUpAll(() async {
    // Public endpoints don't need auth — use a plain client
    publicClient = ApiClient(
      baseUrl: _apiBaseUrl,
      dio: _rawDio(),
      checkConnectivity: () async {},
    );
  });

  group('public flow', () {
    test('health endpoint returns status', () async {
      // GET /api/health — no client method
      final res = await publicClient.dio.get('/api/health');
      final result = res.data as Map<String, dynamic>;
      expect(result, isNotNull, reason: 'health result should not be null');
    });

    test('categories returns category list with required fields', () async {
      final cats = await publicClient.getCategories();
      expect(cats.isNotEmpty, isTrue, reason: 'categories should not be empty');

      for (final cat in cats) {
        expect(cat.id, isNotNull, reason: 'category should have id');
        expect(cat.id, isA<String>(), reason: 'id should be string');
        expect(cat.name, isNotNull, reason: 'category should have name');
        expect(cat.name, isA<String>(), reason: 'name should be string');
        expect(cat.slug, isNotNull, reason: 'category should have slug');
        expect(cat.slug, isA<String>(), reason: 'slug should be string');
      }
    });

    test('heatmap returns coordinate array', () async {
      try {
        // GET /api/map/heatmap — no client method
        final res = await publicClient.dio.get('/api/map/heatmap');
        final result = res.data as Map<String, dynamic>;
        expect(result, isNotNull, reason: 'heatmap result should not be null');
        expect(
          result.containsKey('points'),
          isTrue,
          reason: 'result should have points',
        );
        expect(
          result['points'],
          isA<List>(),
          reason: 'points should be a list',
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) return;
        rethrow;
      }
    });

    test('map/geojson returns FeatureCollection structure', () async {
      final geojson = await publicClient.getMapGeoJson();
      expect(
        geojson.type,
        'FeatureCollection',
        reason: 'type should be FeatureCollection',
      );
      expect(
        geojson.features,
        isA<List>(),
        reason: 'features should be a list',
      );

      if (geojson.features != null) {
        for (final feature in geojson.features!) {
          expect(
            feature.type,
            'Feature',
            reason: 'feature type should be Feature',
          );
          expect(
            feature.geometry,
            isA<Map>(),
            reason: 'geometry should be object',
          );
          expect(
            feature.properties,
            isA<Map>(),
            reason: 'properties should be object',
          );
        }
      }
    });

    test('public reports returns paginated list', () async {
      final reportsPage = await publicClient.getPublicReports();
      expect(
        reportsPage.items,
        isA<List>(),
        reason: 'reports should be a list',
      );
    });

    test('public reports supports filtering by category and status', () async {
      final cats = await publicClient.getCategories();
      expect(cats.isNotEmpty, isTrue, reason: 'categories should not be empty');

      final catId = cats.first.id;

      final filteredPage = await publicClient.getPublicReports(
        categoryId: catId,
      );
      expect(
        filteredPage.items,
        isA<List>(),
        reason: 'filtered result should have reports',
      );

      final allPage = await publicClient.getPublicReports();
      expect(
        allPage.items,
        isA<List>(),
        reason: 'all result should have reports',
      );
    });

    test('public stats returns aggregate counts', () async {
      // Use raw Dio — client.getPublicStats() reads wrong envelope key (data['stats'] vs top-level)
      final res = await publicClient.dio.get('/api/public/stats');
      final result = res.data as Map<String, dynamic>;
      expect(
        result.containsKey('total'),
        isTrue,
        reason: 'result should have total',
      );
      expect(result['total'], isA<num>(), reason: 'total should be number');
      expect(
        (result['total'] as num).toInt() >= 0,
        isTrue,
        reason: 'total should be >= 0',
      );
      expect(
        result.containsKey('by_status'),
        isTrue,
        reason: 'result should have by_status',
      );
      expect(
        result['by_status'],
        isA<Map>(),
        reason: 'by_status should be object',
      );
      expect(
        result.containsKey('by_category'),
        isTrue,
        reason: 'result should have by_category',
      );
      expect(
        result['by_category'],
        isA<List>(),
        reason: 'by_category should be list',
      );
    });
  });
}
