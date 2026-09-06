part of '../client.dart';

class ReverseGeocodedAddress {
  final String address, addressArea;
  final double latitude, longitude;
  final String? kelurahan, kecamatan, kabupaten, provinsi, source, attribution;
  const ReverseGeocodedAddress({
    required this.address,
    required this.addressArea,
    required this.latitude,
    required this.longitude,
    this.kelurahan,
    this.kecamatan,
    this.kabupaten,
    this.provinsi,
    this.source,
    this.attribution,
  });
  factory ReverseGeocodedAddress.fromJson(Map<String, dynamic> json) =>
      ReverseGeocodedAddress(
        address: json['address'] as String,
        addressArea: json['address_area'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        kelurahan: json['kelurahan'] as String?,
        kecamatan: json['kecamatan'] as String?,
        kabupaten: json['kabupaten'] as String?,
        provinsi: json['provinsi'] as String?,
        source: json['source'] as String?,
        attribution: json['attribution'] as String?,
      );
}

/// GeoJSON geometry object with type and coordinates.
class GeoJSONGeometry {
  final String? type;
  final Object? coordinates;
  const GeoJSONGeometry({this.type, this.coordinates});

  factory GeoJSONGeometry.fromJson(Map<String, dynamic> json) {
    return GeoJSONGeometry(
      type: json['type'] as String?,
      coordinates: json['coordinates'],
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'coordinates': coordinates};
}

/// GeoJSON properties object.
class GeoJSONProperties {
  final String? name;
  final String? category;
  final String? status;
  final String? description;
  final String? reportId;
  final String? categoryId;
  final String? addressArea;
  final DateTime? createdAt;

  const GeoJSONProperties({
    this.name,
    this.category,
    this.status,
    this.description,
    this.reportId,
    this.categoryId,
    this.addressArea,
    this.createdAt,
  });

  factory GeoJSONProperties.fromJson(Map<String, dynamic> json) {
    return GeoJSONProperties(
      name: (json['title'] ?? json['name']) as String?,
      category:
          (json['category_name'] ?? json['category_id'] ?? json['category'])
              as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      reportId: (json['report_id'] ?? json['id']) as String?,
      categoryId: json['category_id']?.toString(),
      addressArea: json['address_area']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'status': status,
    'description': description,
    'report_id': reportId,
    'category_id': categoryId,
    'address_area': addressArea,
    'created_at': createdAt?.toIso8601String(),
  };
}

class Facility {
  final String? id;
  final String? name;
  final String? type;
  final ReportLocation? location;
  Facility({this.id, this.name, this.type, this.location});

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      location: json['location'] != null
          ? ReportLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GeoJSONFeatureCollection {
  final String? type;
  final List<GeoJSONFeature>? features;
  GeoJSONFeatureCollection({this.type, this.features});

  factory GeoJSONFeatureCollection.fromJson(Map<String, dynamic> json) {
    return GeoJSONFeatureCollection(
      type: json['type'] as String?,
      features: (json['features'] as List?)
          ?.map((e) => GeoJSONFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GeoJSONFeature {
  final String? type;
  final GeoJSONGeometry? geometry;
  final GeoJSONProperties? properties;
  GeoJSONFeature({this.type, this.geometry, this.properties});

  factory GeoJSONFeature.fromJson(Map<String, dynamic> json) {
    return GeoJSONFeature(
      type: json['type'] as String?,
      geometry: json['geometry'] != null
          ? GeoJSONGeometry.fromJson(json['geometry'] as Map<String, dynamic>)
          : null,
      properties: json['properties'] != null
          ? GeoJSONProperties.fromJson(
              json['properties'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'geometry': geometry?.toJson(),
    'properties': properties?.toJson(),
  };
}

class NearbyReport {
  final String? photoUrl;
  final String? village;
  final int? reportCount;
  final String? id;
  final String? title;
  final String? category;
  final String? status;
  final ReportLocation? location;
  final double? distance;
  NearbyReport({
    this.photoUrl,
    this.village,
    this.reportCount,
    this.id,
    this.title,
    this.category,
    this.status,
    this.location,
    this.distance,
  });

  factory NearbyReport.fromJson(Map<String, dynamic> json) {
    return NearbyReport(
      photoUrl: json['photo_url']?.toString(),
      village: (json['village'] ?? json['kelurahan'])?.toString(),
      reportCount: (json['report_count'] as num?)?.toInt(),
      id: json['id'] as String?,
      title: json['title'] as String?,
      category: (json['category_name'] ?? json['category'])?.toString(),
      status: json['status'] as String?,
      location: json['location'] != null
          ? ReportLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      distance: ((json['distance_m'] ?? json['distance']) as num?)?.toDouble(),
    );
  }
}
