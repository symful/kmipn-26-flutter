import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/warga_home_screen.dart';

void main() {
  group('WargaReportItem.fromServer', () {
    test('returns null when lat is null', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Test report',
        'lat': null,
        'lng': 106.8,
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNull);
    });

    test('returns null when lng is null', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Test report',
        'lat': -6.2,
        'lng': null,
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNull);
    });

    test('returns null when both lat and lng are null', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Test report',
        'lat': null,
        'lng': null,
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNull);
    });

    test(
      'returns null when lat is missing from root but present in location',
      () {
        final serverReport = <String, dynamic>{
          'id': '123',
          'description': 'Test report',
          'location': {'lat': null, 'lng': 106.8},
        };

        final item = WargaReportItem.fromServer(serverReport);

        expect(item, isNull);
      },
    );

    test(
      'returns null when lng is missing from root but present in location',
      () {
        final serverReport = <String, dynamic>{
          'id': '123',
          'description': 'Test report',
          'location': {'lat': -6.2, 'lng': null},
        };

        final item = WargaReportItem.fromServer(serverReport);

        expect(item, isNull);
      },
    );

    test('returns null when both lat and lng are missing from location', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Test report',
        'location': <String, dynamic>{},
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNull);
    });

    test('creates item when lat/lng are valid doubles', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Valid report',
        'lat': -6.2,
        'lng': 106.8,
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNotNull);
      expect(item!.lat, -6.2);
      expect(item.lng, 106.8);
    });

    test('creates item when lat/lng come from location object', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Valid report from location',
        'location': {'lat': -6.3, 'lng': 106.9},
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNotNull);
      expect(item!.lat, -6.3);
      expect(item.lng, 106.9);
    });

    test('prefers root lat/lng over location object', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Report with both',
        'lat': -7.0,
        'lng': 107.0,
        'location': {'lat': -6.3, 'lng': 106.9},
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNotNull);
      expect(item!.lat, -7.0);
      expect(item.lng, 107.0);
    });

    test('falls back to location lat/lng when root is missing', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Report with only location',
        'location': {'lat': -6.5, 'lng': 106.7},
      };

      final item = WargaReportItem.fromServer(serverReport);

      expect(item, isNotNull);
      expect(item!.lat, -6.5);
      expect(item.lng, 106.7);
    });

    test('does NOT fall back to 0 when lat is null', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Report with null lat',
        'lat': null,
        'lng': 106.8,
      };

      final item = WargaReportItem.fromServer(serverReport);

      // Must return null, NOT an item with lat=0
      expect(item, isNull);
    });

    test('does NOT fall back to 0 when lng is null', () {
      final serverReport = <String, dynamic>{
        'id': '123',
        'description': 'Report with null lng',
        'lat': -6.2,
        'lng': null,
      };

      final item = WargaReportItem.fromServer(serverReport);

      // Must return null, NOT an item with lng=0
      expect(item, isNull);
    });
  });
}
