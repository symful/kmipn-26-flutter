// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

class $LocalReportsTable extends LocalReports
    with TableInfo<$LocalReportsTable, LocalReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 2000,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exifDataJsonMeta = const VerificationMeta(
    'exifDataJson',
  );
  @override
  late final GeneratedColumn<String> exifDataJson = GeneratedColumn<String>(
    'exif_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('submitted'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idempotencyKey,
    categoryId,
    description,
    lat,
    lng,
    photoPath,
    exifDataJson,
    deviceId,
    status,
    syncStatus,
    createdAt,
    updatedAt,
    serverId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('exif_data_json')) {
      context.handle(
        _exifDataJsonMeta,
        exifDataJson.isAcceptableOrUnknown(
          data['exif_data_json']!,
          _exifDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idempotencyKey};
  @override
  LocalReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReport(
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      exifDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exif_data_json'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
    );
  }

  @override
  $LocalReportsTable createAlias(String alias) {
    return $LocalReportsTable(attachedDatabase, alias);
  }
}

class LocalReport extends DataClass implements Insertable<LocalReport> {
  final String idempotencyKey;
  final String categoryId;
  final String description;
  final double lat;
  final double lng;
  final String? photoPath;
  final String? exifDataJson;
  final String? deviceId;
  final String status;
  final int syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? serverId;
  const LocalReport({
    required this.idempotencyKey,
    required this.categoryId,
    required this.description,
    required this.lat,
    required this.lng,
    this.photoPath,
    this.exifDataJson,
    this.deviceId,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['category_id'] = Variable<String>(categoryId);
    map['description'] = Variable<String>(description);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || exifDataJson != null) {
      map['exif_data_json'] = Variable<String>(exifDataJson);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<int>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    return map;
  }

  LocalReportsCompanion toCompanion(bool nullToAbsent) {
    return LocalReportsCompanion(
      idempotencyKey: Value(idempotencyKey),
      categoryId: Value(categoryId),
      description: Value(description),
      lat: Value(lat),
      lng: Value(lng),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      exifDataJson: exifDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(exifDataJson),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      status: Value(status),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
    );
  }

  factory LocalReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReport(
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      description: serializer.fromJson<String>(json['description']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      exifDataJson: serializer.fromJson<String?>(json['exifDataJson']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      serverId: serializer.fromJson<String?>(json['serverId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'categoryId': serializer.toJson<String>(categoryId),
      'description': serializer.toJson<String>(description),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'photoPath': serializer.toJson<String?>(photoPath),
      'exifDataJson': serializer.toJson<String?>(exifDataJson),
      'deviceId': serializer.toJson<String?>(deviceId),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'serverId': serializer.toJson<String?>(serverId),
    };
  }

  LocalReport copyWith({
    String? idempotencyKey,
    String? categoryId,
    String? description,
    double? lat,
    double? lng,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> exifDataJson = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    String? status,
    int? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> serverId = const Value.absent(),
  }) => LocalReport(
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    exifDataJson: exifDataJson.present ? exifDataJson.value : this.exifDataJson,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverId: serverId.present ? serverId.value : this.serverId,
  );
  LocalReport copyWithCompanion(LocalReportsCompanion data) {
    return LocalReport(
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      description: data.description.present
          ? data.description.value
          : this.description,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      exifDataJson: data.exifDataJson.present
          ? data.exifDataJson.value
          : this.exifDataJson,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReport(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('photoPath: $photoPath, ')
          ..write('exifDataJson: $exifDataJson, ')
          ..write('deviceId: $deviceId, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idempotencyKey,
    categoryId,
    description,
    lat,
    lng,
    photoPath,
    exifDataJson,
    deviceId,
    status,
    syncStatus,
    createdAt,
    updatedAt,
    serverId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReport &&
          other.idempotencyKey == this.idempotencyKey &&
          other.categoryId == this.categoryId &&
          other.description == this.description &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.photoPath == this.photoPath &&
          other.exifDataJson == this.exifDataJson &&
          other.deviceId == this.deviceId &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverId == this.serverId);
}

class LocalReportsCompanion extends UpdateCompanion<LocalReport> {
  final Value<String> idempotencyKey;
  final Value<String> categoryId;
  final Value<String> description;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String?> photoPath;
  final Value<String?> exifDataJson;
  final Value<String?> deviceId;
  final Value<String> status;
  final Value<int> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> serverId;
  final Value<int> rowid;
  const LocalReportsCompanion({
    this.idempotencyKey = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.description = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.exifDataJson = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalReportsCompanion.insert({
    required String idempotencyKey,
    required String categoryId,
    required String description,
    required double lat,
    required double lng,
    this.photoPath = const Value.absent(),
    this.exifDataJson = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.serverId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : idempotencyKey = Value(idempotencyKey),
       categoryId = Value(categoryId),
       description = Value(description),
       lat = Value(lat),
       lng = Value(lng),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalReport> custom({
    Expression<String>? idempotencyKey,
    Expression<String>? categoryId,
    Expression<String>? description,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? photoPath,
    Expression<String>? exifDataJson,
    Expression<String>? deviceId,
    Expression<String>? status,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? serverId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (categoryId != null) 'category_id': categoryId,
      if (description != null) 'description': description,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (photoPath != null) 'photo_path': photoPath,
      if (exifDataJson != null) 'exif_data_json': exifDataJson,
      if (deviceId != null) 'device_id': deviceId,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverId != null) 'server_id': serverId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalReportsCompanion copyWith({
    Value<String>? idempotencyKey,
    Value<String>? categoryId,
    Value<String>? description,
    Value<double>? lat,
    Value<double>? lng,
    Value<String?>? photoPath,
    Value<String?>? exifDataJson,
    Value<String?>? deviceId,
    Value<String>? status,
    Value<int>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? serverId,
    Value<int>? rowid,
  }) {
    return LocalReportsCompanion(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photoPath: photoPath ?? this.photoPath,
      exifDataJson: exifDataJson ?? this.exifDataJson,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (exifDataJson.present) {
      map['exif_data_json'] = Variable<String>(exifDataJson.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalReportsCompanion(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('photoPath: $photoPath, ')
          ..write('exifDataJson: $exifDataJson, ')
          ..write('deviceId: $deviceId, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idempotencyKey,
    retryCount,
    nextRetryAt,
    lastError,
    syncStatus,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextRetryAtMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idempotencyKey};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String idempotencyKey;
  final int retryCount;
  final DateTime nextRetryAt;
  final String? lastError;
  final int syncStatus;
  final DateTime? updatedAt;
  const SyncQueueData({
    required this.idempotencyKey,
    required this.retryCount,
    required this.nextRetryAt,
    this.lastError,
    required this.syncStatus,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['retry_count'] = Variable<int>(retryCount);
    map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['sync_status'] = Variable<int>(syncStatus);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      idempotencyKey: Value(idempotencyKey),
      retryCount: Value(retryCount),
      nextRetryAt: Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      syncStatus: Value(syncStatus),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  SyncQueueData copyWith({
    String? idempotencyKey,
    int? retryCount,
    DateTime? nextRetryAt,
    Value<String?> lastError = const Value.absent(),
    int? syncStatus,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => SyncQueueData(
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    retryCount: retryCount ?? this.retryCount,
    nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    syncStatus: syncStatus ?? this.syncStatus,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idempotencyKey,
    retryCount,
    nextRetryAt,
    lastError,
    syncStatus,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.idempotencyKey == this.idempotencyKey &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> idempotencyKey;
  final Value<int> retryCount;
  final Value<DateTime> nextRetryAt;
  final Value<String?> lastError;
  final Value<int> syncStatus;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.idempotencyKey = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String idempotencyKey,
    this.retryCount = const Value.absent(),
    required DateTime nextRetryAt,
    this.lastError = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : idempotencyKey = Value(idempotencyKey),
       nextRetryAt = Value(nextRetryAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? idempotencyKey,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<int>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? idempotencyKey,
    Value<int>? retryCount,
    Value<DateTime>? nextRetryAt,
    Value<String?>? lastError,
    Value<int>? syncStatus,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, iconName, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final int id;
  final String name;
  final String? iconName;
  final int sortOrder;
  const LocalCategory({
    required this.id,
    required this.name,
    this.iconName,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      sortOrder: Value(sortOrder),
    );
  }

  factory LocalCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String?>(iconName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LocalCategory copyWith({
    int? id,
    String? name,
    Value<String?> iconName = const Value.absent(),
    int? sortOrder,
  }) => LocalCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName.present ? iconName.value : this.iconName,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.sortOrder == this.sortOrder);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> iconName;
  final Value<int> sortOrder;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.iconName = const Value.absent(),
    required int sortOrder,
  }) : name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<LocalCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? iconName,
    Value<int>? sortOrder,
  }) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $LocalPhotosTable extends LocalPhotos
    with TableInfo<$LocalPhotosTable, LocalPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _reportIdempotencyKeyMeta =
      const VerificationMeta('reportIdempotencyKey');
  @override
  late final GeneratedColumn<String> reportIdempotencyKey =
      GeneratedColumn<String>(
        'report_idempotency_key',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES local_reports (idempotency_key)',
        ),
      );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exifDataJsonMeta = const VerificationMeta(
    'exifDataJson',
  );
  @override
  late final GeneratedColumn<String> exifDataJson = GeneratedColumn<String>(
    'exif_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<int> capturedAt = GeneratedColumn<int>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reportIdempotencyKey,
    filePath,
    exifDataJson,
    capturedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('report_idempotency_key')) {
      context.handle(
        _reportIdempotencyKeyMeta,
        reportIdempotencyKey.isAcceptableOrUnknown(
          data['report_idempotency_key']!,
          _reportIdempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reportIdempotencyKeyMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('exif_data_json')) {
      context.handle(
        _exifDataJsonMeta,
        exifDataJson.isAcceptableOrUnknown(
          data['exif_data_json']!,
          _exifDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reportIdempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_idempotency_key'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      exifDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exif_data_json'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LocalPhotosTable createAlias(String alias) {
    return $LocalPhotosTable(attachedDatabase, alias);
  }
}

class LocalPhoto extends DataClass implements Insertable<LocalPhoto> {
  final int id;
  final String reportIdempotencyKey;
  final String filePath;
  final String? exifDataJson;
  final int capturedAt;
  final int syncStatus;
  const LocalPhoto({
    required this.id,
    required this.reportIdempotencyKey,
    required this.filePath,
    this.exifDataJson,
    required this.capturedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['report_idempotency_key'] = Variable<String>(reportIdempotencyKey);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || exifDataJson != null) {
      map['exif_data_json'] = Variable<String>(exifDataJson);
    }
    map['captured_at'] = Variable<int>(capturedAt);
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  LocalPhotosCompanion toCompanion(bool nullToAbsent) {
    return LocalPhotosCompanion(
      id: Value(id),
      reportIdempotencyKey: Value(reportIdempotencyKey),
      filePath: Value(filePath),
      exifDataJson: exifDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(exifDataJson),
      capturedAt: Value(capturedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LocalPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPhoto(
      id: serializer.fromJson<int>(json['id']),
      reportIdempotencyKey: serializer.fromJson<String>(
        json['reportIdempotencyKey'],
      ),
      filePath: serializer.fromJson<String>(json['filePath']),
      exifDataJson: serializer.fromJson<String?>(json['exifDataJson']),
      capturedAt: serializer.fromJson<int>(json['capturedAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reportIdempotencyKey': serializer.toJson<String>(reportIdempotencyKey),
      'filePath': serializer.toJson<String>(filePath),
      'exifDataJson': serializer.toJson<String?>(exifDataJson),
      'capturedAt': serializer.toJson<int>(capturedAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  LocalPhoto copyWith({
    int? id,
    String? reportIdempotencyKey,
    String? filePath,
    Value<String?> exifDataJson = const Value.absent(),
    int? capturedAt,
    int? syncStatus,
  }) => LocalPhoto(
    id: id ?? this.id,
    reportIdempotencyKey: reportIdempotencyKey ?? this.reportIdempotencyKey,
    filePath: filePath ?? this.filePath,
    exifDataJson: exifDataJson.present ? exifDataJson.value : this.exifDataJson,
    capturedAt: capturedAt ?? this.capturedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  LocalPhoto copyWithCompanion(LocalPhotosCompanion data) {
    return LocalPhoto(
      id: data.id.present ? data.id.value : this.id,
      reportIdempotencyKey: data.reportIdempotencyKey.present
          ? data.reportIdempotencyKey.value
          : this.reportIdempotencyKey,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      exifDataJson: data.exifDataJson.present
          ? data.exifDataJson.value
          : this.exifDataJson,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPhoto(')
          ..write('id: $id, ')
          ..write('reportIdempotencyKey: $reportIdempotencyKey, ')
          ..write('filePath: $filePath, ')
          ..write('exifDataJson: $exifDataJson, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    reportIdempotencyKey,
    filePath,
    exifDataJson,
    capturedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPhoto &&
          other.id == this.id &&
          other.reportIdempotencyKey == this.reportIdempotencyKey &&
          other.filePath == this.filePath &&
          other.exifDataJson == this.exifDataJson &&
          other.capturedAt == this.capturedAt &&
          other.syncStatus == this.syncStatus);
}

class LocalPhotosCompanion extends UpdateCompanion<LocalPhoto> {
  final Value<int> id;
  final Value<String> reportIdempotencyKey;
  final Value<String> filePath;
  final Value<String?> exifDataJson;
  final Value<int> capturedAt;
  final Value<int> syncStatus;
  const LocalPhotosCompanion({
    this.id = const Value.absent(),
    this.reportIdempotencyKey = const Value.absent(),
    this.filePath = const Value.absent(),
    this.exifDataJson = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  LocalPhotosCompanion.insert({
    this.id = const Value.absent(),
    required String reportIdempotencyKey,
    required String filePath,
    this.exifDataJson = const Value.absent(),
    required int capturedAt,
    this.syncStatus = const Value.absent(),
  }) : reportIdempotencyKey = Value(reportIdempotencyKey),
       filePath = Value(filePath),
       capturedAt = Value(capturedAt);
  static Insertable<LocalPhoto> custom({
    Expression<int>? id,
    Expression<String>? reportIdempotencyKey,
    Expression<String>? filePath,
    Expression<String>? exifDataJson,
    Expression<int>? capturedAt,
    Expression<int>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reportIdempotencyKey != null)
        'report_idempotency_key': reportIdempotencyKey,
      if (filePath != null) 'file_path': filePath,
      if (exifDataJson != null) 'exif_data_json': exifDataJson,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  LocalPhotosCompanion copyWith({
    Value<int>? id,
    Value<String>? reportIdempotencyKey,
    Value<String>? filePath,
    Value<String?>? exifDataJson,
    Value<int>? capturedAt,
    Value<int>? syncStatus,
  }) {
    return LocalPhotosCompanion(
      id: id ?? this.id,
      reportIdempotencyKey: reportIdempotencyKey ?? this.reportIdempotencyKey,
      filePath: filePath ?? this.filePath,
      exifDataJson: exifDataJson ?? this.exifDataJson,
      capturedAt: capturedAt ?? this.capturedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reportIdempotencyKey.present) {
      map['report_idempotency_key'] = Variable<String>(
        reportIdempotencyKey.value,
      );
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (exifDataJson.present) {
      map['exif_data_json'] = Variable<String>(exifDataJson.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(capturedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPhotosCompanion(')
          ..write('id: $id, ')
          ..write('reportIdempotencyKey: $reportIdempotencyKey, ')
          ..write('filePath: $filePath, ')
          ..write('exifDataJson: $exifDataJson, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

class $LocalSurveyorTasksTable extends LocalSurveyorTasks
    with TableInfo<$LocalSurveyorTasksTable, LocalSurveyorTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSurveyorTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checklistTemplateJsonMeta =
      const VerificationMeta('checklistTemplateJson');
  @override
  late final GeneratedColumn<String> checklistTemplateJson =
      GeneratedColumn<String>(
        'checklist_template_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    title,
    description,
    instructions,
    status,
    checklistTemplateJson,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_surveyor_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSurveyorTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('checklist_template_json')) {
      context.handle(
        _checklistTemplateJsonMeta,
        checklistTemplateJson.isAcceptableOrUnknown(
          data['checklist_template_json']!,
          _checklistTemplateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checklistTemplateJsonMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  LocalSurveyorTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSurveyorTask(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      checklistTemplateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checklist_template_json'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $LocalSurveyorTasksTable createAlias(String alias) {
    return $LocalSurveyorTasksTable(attachedDatabase, alias);
  }
}

class LocalSurveyorTask extends DataClass
    implements Insertable<LocalSurveyorTask> {
  final String taskId;
  final String title;
  final String? description;
  final String? instructions;
  final String status;
  final String checklistTemplateJson;
  final DateTime downloadedAt;
  const LocalSurveyorTask({
    required this.taskId,
    required this.title,
    this.description,
    this.instructions,
    required this.status,
    required this.checklistTemplateJson,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    map['status'] = Variable<String>(status);
    map['checklist_template_json'] = Variable<String>(checklistTemplateJson);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  LocalSurveyorTasksCompanion toCompanion(bool nullToAbsent) {
    return LocalSurveyorTasksCompanion(
      taskId: Value(taskId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      status: Value(status),
      checklistTemplateJson: Value(checklistTemplateJson),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory LocalSurveyorTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSurveyorTask(
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      status: serializer.fromJson<String>(json['status']),
      checklistTemplateJson: serializer.fromJson<String>(
        json['checklistTemplateJson'],
      ),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'instructions': serializer.toJson<String?>(instructions),
      'status': serializer.toJson<String>(status),
      'checklistTemplateJson': serializer.toJson<String>(checklistTemplateJson),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  LocalSurveyorTask copyWith({
    String? taskId,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> instructions = const Value.absent(),
    String? status,
    String? checklistTemplateJson,
    DateTime? downloadedAt,
  }) => LocalSurveyorTask(
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    instructions: instructions.present ? instructions.value : this.instructions,
    status: status ?? this.status,
    checklistTemplateJson: checklistTemplateJson ?? this.checklistTemplateJson,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  LocalSurveyorTask copyWithCompanion(LocalSurveyorTasksCompanion data) {
    return LocalSurveyorTask(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      status: data.status.present ? data.status.value : this.status,
      checklistTemplateJson: data.checklistTemplateJson.present
          ? data.checklistTemplateJson.value
          : this.checklistTemplateJson,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSurveyorTask(')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('instructions: $instructions, ')
          ..write('status: $status, ')
          ..write('checklistTemplateJson: $checklistTemplateJson, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    title,
    description,
    instructions,
    status,
    checklistTemplateJson,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSurveyorTask &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.description == this.description &&
          other.instructions == this.instructions &&
          other.status == this.status &&
          other.checklistTemplateJson == this.checklistTemplateJson &&
          other.downloadedAt == this.downloadedAt);
}

class LocalSurveyorTasksCompanion extends UpdateCompanion<LocalSurveyorTask> {
  final Value<String> taskId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> instructions;
  final Value<String> status;
  final Value<String> checklistTemplateJson;
  final Value<DateTime> downloadedAt;
  final Value<int> rowid;
  const LocalSurveyorTasksCompanion({
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.instructions = const Value.absent(),
    this.status = const Value.absent(),
    this.checklistTemplateJson = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSurveyorTasksCompanion.insert({
    required String taskId,
    required String title,
    this.description = const Value.absent(),
    this.instructions = const Value.absent(),
    required String status,
    required String checklistTemplateJson,
    required DateTime downloadedAt,
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       title = Value(title),
       status = Value(status),
       checklistTemplateJson = Value(checklistTemplateJson),
       downloadedAt = Value(downloadedAt);
  static Insertable<LocalSurveyorTask> custom({
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? instructions,
    Expression<String>? status,
    Expression<String>? checklistTemplateJson,
    Expression<DateTime>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (instructions != null) 'instructions': instructions,
      if (status != null) 'status': status,
      if (checklistTemplateJson != null)
        'checklist_template_json': checklistTemplateJson,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSurveyorTasksCompanion copyWith({
    Value<String>? taskId,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? instructions,
    Value<String>? status,
    Value<String>? checklistTemplateJson,
    Value<DateTime>? downloadedAt,
    Value<int>? rowid,
  }) {
    return LocalSurveyorTasksCompanion(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      status: status ?? this.status,
      checklistTemplateJson:
          checklistTemplateJson ?? this.checklistTemplateJson,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checklistTemplateJson.present) {
      map['checklist_template_json'] = Variable<String>(
        checklistTemplateJson.value,
      );
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSurveyorTasksCompanion(')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('instructions: $instructions, ')
          ..write('status: $status, ')
          ..write('checklistTemplateJson: $checklistTemplateJson, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSurveyorVisitsTable extends LocalSurveyorVisits
    with TableInfo<$LocalSurveyorVisitsTable, LocalSurveyorVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSurveyorVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitDataJsonMeta = const VerificationMeta(
    'visitDataJson',
  );
  @override
  late final GeneratedColumn<String> visitDataJson = GeneratedColumn<String>(
    'visit_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idempotencyKey,
    taskId,
    visitDataJson,
    syncStatus,
    serverId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_surveyor_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSurveyorVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('visit_data_json')) {
      context.handle(
        _visitDataJsonMeta,
        visitDataJson.isAcceptableOrUnknown(
          data['visit_data_json']!,
          _visitDataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_visitDataJsonMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idempotencyKey};
  @override
  LocalSurveyorVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSurveyorVisit(
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      visitDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_data_json'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_status'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalSurveyorVisitsTable createAlias(String alias) {
    return $LocalSurveyorVisitsTable(attachedDatabase, alias);
  }
}

class LocalSurveyorVisit extends DataClass
    implements Insertable<LocalSurveyorVisit> {
  final String idempotencyKey;
  final String taskId;
  final String visitDataJson;
  final int syncStatus;
  final String? serverId;
  final DateTime createdAt;
  const LocalSurveyorVisit({
    required this.idempotencyKey,
    required this.taskId,
    required this.visitDataJson,
    required this.syncStatus,
    this.serverId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['task_id'] = Variable<String>(taskId);
    map['visit_data_json'] = Variable<String>(visitDataJson);
    map['sync_status'] = Variable<int>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalSurveyorVisitsCompanion toCompanion(bool nullToAbsent) {
    return LocalSurveyorVisitsCompanion(
      idempotencyKey: Value(idempotencyKey),
      taskId: Value(taskId),
      visitDataJson: Value(visitDataJson),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalSurveyorVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSurveyorVisit(
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      taskId: serializer.fromJson<String>(json['taskId']),
      visitDataJson: serializer.fromJson<String>(json['visitDataJson']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'taskId': serializer.toJson<String>(taskId),
      'visitDataJson': serializer.toJson<String>(visitDataJson),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalSurveyorVisit copyWith({
    String? idempotencyKey,
    String? taskId,
    String? visitDataJson,
    int? syncStatus,
    Value<String?> serverId = const Value.absent(),
    DateTime? createdAt,
  }) => LocalSurveyorVisit(
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    taskId: taskId ?? this.taskId,
    visitDataJson: visitDataJson ?? this.visitDataJson,
    syncStatus: syncStatus ?? this.syncStatus,
    serverId: serverId.present ? serverId.value : this.serverId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalSurveyorVisit copyWithCompanion(LocalSurveyorVisitsCompanion data) {
    return LocalSurveyorVisit(
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      visitDataJson: data.visitDataJson.present
          ? data.visitDataJson.value
          : this.visitDataJson,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSurveyorVisit(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('taskId: $taskId, ')
          ..write('visitDataJson: $visitDataJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idempotencyKey,
    taskId,
    visitDataJson,
    syncStatus,
    serverId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSurveyorVisit &&
          other.idempotencyKey == this.idempotencyKey &&
          other.taskId == this.taskId &&
          other.visitDataJson == this.visitDataJson &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.createdAt == this.createdAt);
}

class LocalSurveyorVisitsCompanion extends UpdateCompanion<LocalSurveyorVisit> {
  final Value<String> idempotencyKey;
  final Value<String> taskId;
  final Value<String> visitDataJson;
  final Value<int> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalSurveyorVisitsCompanion({
    this.idempotencyKey = const Value.absent(),
    this.taskId = const Value.absent(),
    this.visitDataJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSurveyorVisitsCompanion.insert({
    required String idempotencyKey,
    required String taskId,
    required String visitDataJson,
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : idempotencyKey = Value(idempotencyKey),
       taskId = Value(taskId),
       visitDataJson = Value(visitDataJson),
       createdAt = Value(createdAt);
  static Insertable<LocalSurveyorVisit> custom({
    Expression<String>? idempotencyKey,
    Expression<String>? taskId,
    Expression<String>? visitDataJson,
    Expression<int>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (taskId != null) 'task_id': taskId,
      if (visitDataJson != null) 'visit_data_json': visitDataJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSurveyorVisitsCompanion copyWith({
    Value<String>? idempotencyKey,
    Value<String>? taskId,
    Value<String>? visitDataJson,
    Value<int>? syncStatus,
    Value<String?>? serverId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalSurveyorVisitsCompanion(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      taskId: taskId ?? this.taskId,
      visitDataJson: visitDataJson ?? this.visitDataJson,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (visitDataJson.present) {
      map['visit_data_json'] = Variable<String>(visitDataJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSurveyorVisitsCompanion(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('taskId: $taskId, ')
          ..write('visitDataJson: $visitDataJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalReportsTable localReports = $LocalReportsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalPhotosTable localPhotos = $LocalPhotosTable(this);
  late final $LocalSurveyorTasksTable localSurveyorTasks =
      $LocalSurveyorTasksTable(this);
  late final $LocalSurveyorVisitsTable localSurveyorVisits =
      $LocalSurveyorVisitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localReports,
    syncQueue,
    localCategories,
    localPhotos,
    localSurveyorTasks,
    localSurveyorVisits,
  ];
}

typedef $$LocalReportsTableCreateCompanionBuilder =
    LocalReportsCompanion Function({
      required String idempotencyKey,
      required String categoryId,
      required String description,
      required double lat,
      required double lng,
      Value<String?> photoPath,
      Value<String?> exifDataJson,
      Value<String?> deviceId,
      Value<String> status,
      Value<int> syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> serverId,
      Value<int> rowid,
    });
typedef $$LocalReportsTableUpdateCompanionBuilder =
    LocalReportsCompanion Function({
      Value<String> idempotencyKey,
      Value<String> categoryId,
      Value<String> description,
      Value<double> lat,
      Value<double> lng,
      Value<String?> photoPath,
      Value<String?> exifDataJson,
      Value<String?> deviceId,
      Value<String> status,
      Value<int> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> serverId,
      Value<int> rowid,
    });

final class $$LocalReportsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalReportsTable, LocalReport> {
  $$LocalReportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalPhotosTable, List<LocalPhoto>>
  _localPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localPhotos,
    aliasName: $_aliasNameGenerator(
      db.localReports.idempotencyKey,
      db.localPhotos.reportIdempotencyKey,
    ),
  );

  $$LocalPhotosTableProcessedTableManager get localPhotosRefs {
    final manager = $$LocalPhotosTableTableManager($_db, $_db.localPhotos)
        .filter(
          (f) => f.reportIdempotencyKey.idempotencyKey.sqlEquals(
            $_itemColumn<String>('idempotency_key')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_localPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalReportsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalReportsTable> {
  $$LocalReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exifDataJson => $composableBuilder(
    column: $table.exifDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localPhotosRefs(
    Expression<bool> Function($$LocalPhotosTableFilterComposer f) f,
  ) {
    final $$LocalPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idempotencyKey,
      referencedTable: $db.localPhotos,
      getReferencedColumn: (t) => t.reportIdempotencyKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalPhotosTableFilterComposer(
            $db: $db,
            $table: $db.localPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalReportsTable> {
  $$LocalReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exifDataJson => $composableBuilder(
    column: $table.exifDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalReportsTable> {
  $$LocalReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get exifDataJson => $composableBuilder(
    column: $table.exifDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  Expression<T> localPhotosRefs<T extends Object>(
    Expression<T> Function($$LocalPhotosTableAnnotationComposer a) f,
  ) {
    final $$LocalPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.idempotencyKey,
      referencedTable: $db.localPhotos,
      getReferencedColumn: (t) => t.reportIdempotencyKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.localPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalReportsTable,
          LocalReport,
          $$LocalReportsTableFilterComposer,
          $$LocalReportsTableOrderingComposer,
          $$LocalReportsTableAnnotationComposer,
          $$LocalReportsTableCreateCompanionBuilder,
          $$LocalReportsTableUpdateCompanionBuilder,
          (LocalReport, $$LocalReportsTableReferences),
          LocalReport,
          PrefetchHooks Function({bool localPhotosRefs})
        > {
  $$LocalReportsTableTableManager(_$AppDatabase db, $LocalReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> exifDataJson = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalReportsCompanion(
                idempotencyKey: idempotencyKey,
                categoryId: categoryId,
                description: description,
                lat: lat,
                lng: lng,
                photoPath: photoPath,
                exifDataJson: exifDataJson,
                deviceId: deviceId,
                status: status,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idempotencyKey,
                required String categoryId,
                required String description,
                required double lat,
                required double lng,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> exifDataJson = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> serverId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalReportsCompanion.insert(
                idempotencyKey: idempotencyKey,
                categoryId: categoryId,
                description: description,
                lat: lat,
                lng: lng,
                photoPath: photoPath,
                exifDataJson: exifDataJson,
                deviceId: deviceId,
                status: status,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalReportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localPhotosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (localPhotosRefs) db.localPhotos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localPhotosRefs)
                    await $_getPrefetchedData<
                      LocalReport,
                      $LocalReportsTable,
                      LocalPhoto
                    >(
                      currentTable: table,
                      referencedTable: $$LocalReportsTableReferences
                          ._localPhotosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocalReportsTableReferences(
                            db,
                            table,
                            p0,
                          ).localPhotosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) =>
                                e.reportIdempotencyKey == item.idempotencyKey,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocalReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalReportsTable,
      LocalReport,
      $$LocalReportsTableFilterComposer,
      $$LocalReportsTableOrderingComposer,
      $$LocalReportsTableAnnotationComposer,
      $$LocalReportsTableCreateCompanionBuilder,
      $$LocalReportsTableUpdateCompanionBuilder,
      (LocalReport, $$LocalReportsTableReferences),
      LocalReport,
      PrefetchHooks Function({bool localPhotosRefs})
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String idempotencyKey,
      Value<int> retryCount,
      required DateTime nextRetryAt,
      Value<String?> lastError,
      Value<int> syncStatus,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> idempotencyKey,
      Value<int> retryCount,
      Value<DateTime> nextRetryAt,
      Value<String?> lastError,
      Value<int> syncStatus,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                idempotencyKey: idempotencyKey,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idempotencyKey,
                Value<int> retryCount = const Value.absent(),
                required DateTime nextRetryAt,
                Value<String?> lastError = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                idempotencyKey: idempotencyKey,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                syncStatus: syncStatus,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> iconName,
      required int sortOrder,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> iconName,
      Value<int> sortOrder,
    });

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategory,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (
            LocalCategory,
            BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
          ),
          LocalCategory,
          PrefetchHooks Function()
        > {
  $$LocalCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => LocalCategoriesCompanion(
                id: id,
                name: name,
                iconName: iconName,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> iconName = const Value.absent(),
                required int sortOrder,
              }) => LocalCategoriesCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCategoriesTable,
      LocalCategory,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (
        LocalCategory,
        BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
      ),
      LocalCategory,
      PrefetchHooks Function()
    >;
typedef $$LocalPhotosTableCreateCompanionBuilder =
    LocalPhotosCompanion Function({
      Value<int> id,
      required String reportIdempotencyKey,
      required String filePath,
      Value<String?> exifDataJson,
      required int capturedAt,
      Value<int> syncStatus,
    });
typedef $$LocalPhotosTableUpdateCompanionBuilder =
    LocalPhotosCompanion Function({
      Value<int> id,
      Value<String> reportIdempotencyKey,
      Value<String> filePath,
      Value<String?> exifDataJson,
      Value<int> capturedAt,
      Value<int> syncStatus,
    });

final class $$LocalPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $LocalPhotosTable, LocalPhoto> {
  $$LocalPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalReportsTable _reportIdempotencyKeyTable(_$AppDatabase db) =>
      db.localReports.createAlias(
        $_aliasNameGenerator(
          db.localPhotos.reportIdempotencyKey,
          db.localReports.idempotencyKey,
        ),
      );

  $$LocalReportsTableProcessedTableManager get reportIdempotencyKey {
    final $_column = $_itemColumn<String>('report_idempotency_key')!;

    final manager = $$LocalReportsTableTableManager(
      $_db,
      $_db.localReports,
    ).filter((f) => f.idempotencyKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _reportIdempotencyKeyTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPhotosTable> {
  $$LocalPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exifDataJson => $composableBuilder(
    column: $table.exifDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalReportsTableFilterComposer get reportIdempotencyKey {
    final $$LocalReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportIdempotencyKey,
      referencedTable: $db.localReports,
      getReferencedColumn: (t) => t.idempotencyKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalReportsTableFilterComposer(
            $db: $db,
            $table: $db.localReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPhotosTable> {
  $$LocalPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exifDataJson => $composableBuilder(
    column: $table.exifDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalReportsTableOrderingComposer get reportIdempotencyKey {
    final $$LocalReportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportIdempotencyKey,
      referencedTable: $db.localReports,
      getReferencedColumn: (t) => t.idempotencyKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalReportsTableOrderingComposer(
            $db: $db,
            $table: $db.localReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPhotosTable> {
  $$LocalPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get exifDataJson => $composableBuilder(
    column: $table.exifDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  $$LocalReportsTableAnnotationComposer get reportIdempotencyKey {
    final $$LocalReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportIdempotencyKey,
      referencedTable: $db.localReports,
      getReferencedColumn: (t) => t.idempotencyKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.localReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPhotosTable,
          LocalPhoto,
          $$LocalPhotosTableFilterComposer,
          $$LocalPhotosTableOrderingComposer,
          $$LocalPhotosTableAnnotationComposer,
          $$LocalPhotosTableCreateCompanionBuilder,
          $$LocalPhotosTableUpdateCompanionBuilder,
          (LocalPhoto, $$LocalPhotosTableReferences),
          LocalPhoto,
          PrefetchHooks Function({bool reportIdempotencyKey})
        > {
  $$LocalPhotosTableTableManager(_$AppDatabase db, $LocalPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> reportIdempotencyKey = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> exifDataJson = const Value.absent(),
                Value<int> capturedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
              }) => LocalPhotosCompanion(
                id: id,
                reportIdempotencyKey: reportIdempotencyKey,
                filePath: filePath,
                exifDataJson: exifDataJson,
                capturedAt: capturedAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String reportIdempotencyKey,
                required String filePath,
                Value<String?> exifDataJson = const Value.absent(),
                required int capturedAt,
                Value<int> syncStatus = const Value.absent(),
              }) => LocalPhotosCompanion.insert(
                id: id,
                reportIdempotencyKey: reportIdempotencyKey,
                filePath: filePath,
                exifDataJson: exifDataJson,
                capturedAt: capturedAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reportIdempotencyKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reportIdempotencyKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reportIdempotencyKey,
                                referencedTable: $$LocalPhotosTableReferences
                                    ._reportIdempotencyKeyTable(db),
                                referencedColumn: $$LocalPhotosTableReferences
                                    ._reportIdempotencyKeyTable(db)
                                    .idempotencyKey,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPhotosTable,
      LocalPhoto,
      $$LocalPhotosTableFilterComposer,
      $$LocalPhotosTableOrderingComposer,
      $$LocalPhotosTableAnnotationComposer,
      $$LocalPhotosTableCreateCompanionBuilder,
      $$LocalPhotosTableUpdateCompanionBuilder,
      (LocalPhoto, $$LocalPhotosTableReferences),
      LocalPhoto,
      PrefetchHooks Function({bool reportIdempotencyKey})
    >;
typedef $$LocalSurveyorTasksTableCreateCompanionBuilder =
    LocalSurveyorTasksCompanion Function({
      required String taskId,
      required String title,
      Value<String?> description,
      Value<String?> instructions,
      required String status,
      required String checklistTemplateJson,
      required DateTime downloadedAt,
      Value<int> rowid,
    });
typedef $$LocalSurveyorTasksTableUpdateCompanionBuilder =
    LocalSurveyorTasksCompanion Function({
      Value<String> taskId,
      Value<String> title,
      Value<String?> description,
      Value<String?> instructions,
      Value<String> status,
      Value<String> checklistTemplateJson,
      Value<DateTime> downloadedAt,
      Value<int> rowid,
    });

class $$LocalSurveyorTasksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSurveyorTasksTable> {
  $$LocalSurveyorTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checklistTemplateJson => $composableBuilder(
    column: $table.checklistTemplateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSurveyorTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSurveyorTasksTable> {
  $$LocalSurveyorTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checklistTemplateJson => $composableBuilder(
    column: $table.checklistTemplateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSurveyorTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSurveyorTasksTable> {
  $$LocalSurveyorTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get checklistTemplateJson => $composableBuilder(
    column: $table.checklistTemplateJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $$LocalSurveyorTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSurveyorTasksTable,
          LocalSurveyorTask,
          $$LocalSurveyorTasksTableFilterComposer,
          $$LocalSurveyorTasksTableOrderingComposer,
          $$LocalSurveyorTasksTableAnnotationComposer,
          $$LocalSurveyorTasksTableCreateCompanionBuilder,
          $$LocalSurveyorTasksTableUpdateCompanionBuilder,
          (
            LocalSurveyorTask,
            BaseReferences<
              _$AppDatabase,
              $LocalSurveyorTasksTable,
              LocalSurveyorTask
            >,
          ),
          LocalSurveyorTask,
          PrefetchHooks Function()
        > {
  $$LocalSurveyorTasksTableTableManager(
    _$AppDatabase db,
    $LocalSurveyorTasksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSurveyorTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSurveyorTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSurveyorTasksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> checklistTemplateJson = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSurveyorTasksCompanion(
                taskId: taskId,
                title: title,
                description: description,
                instructions: instructions,
                status: status,
                checklistTemplateJson: checklistTemplateJson,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                required String status,
                required String checklistTemplateJson,
                required DateTime downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSurveyorTasksCompanion.insert(
                taskId: taskId,
                title: title,
                description: description,
                instructions: instructions,
                status: status,
                checklistTemplateJson: checklistTemplateJson,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSurveyorTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSurveyorTasksTable,
      LocalSurveyorTask,
      $$LocalSurveyorTasksTableFilterComposer,
      $$LocalSurveyorTasksTableOrderingComposer,
      $$LocalSurveyorTasksTableAnnotationComposer,
      $$LocalSurveyorTasksTableCreateCompanionBuilder,
      $$LocalSurveyorTasksTableUpdateCompanionBuilder,
      (
        LocalSurveyorTask,
        BaseReferences<
          _$AppDatabase,
          $LocalSurveyorTasksTable,
          LocalSurveyorTask
        >,
      ),
      LocalSurveyorTask,
      PrefetchHooks Function()
    >;
typedef $$LocalSurveyorVisitsTableCreateCompanionBuilder =
    LocalSurveyorVisitsCompanion Function({
      required String idempotencyKey,
      required String taskId,
      required String visitDataJson,
      Value<int> syncStatus,
      Value<String?> serverId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalSurveyorVisitsTableUpdateCompanionBuilder =
    LocalSurveyorVisitsCompanion Function({
      Value<String> idempotencyKey,
      Value<String> taskId,
      Value<String> visitDataJson,
      Value<int> syncStatus,
      Value<String?> serverId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalSurveyorVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSurveyorVisitsTable> {
  $$LocalSurveyorVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visitDataJson => $composableBuilder(
    column: $table.visitDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSurveyorVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSurveyorVisitsTable> {
  $$LocalSurveyorVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visitDataJson => $composableBuilder(
    column: $table.visitDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSurveyorVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSurveyorVisitsTable> {
  $$LocalSurveyorVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get visitDataJson => $composableBuilder(
    column: $table.visitDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalSurveyorVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSurveyorVisitsTable,
          LocalSurveyorVisit,
          $$LocalSurveyorVisitsTableFilterComposer,
          $$LocalSurveyorVisitsTableOrderingComposer,
          $$LocalSurveyorVisitsTableAnnotationComposer,
          $$LocalSurveyorVisitsTableCreateCompanionBuilder,
          $$LocalSurveyorVisitsTableUpdateCompanionBuilder,
          (
            LocalSurveyorVisit,
            BaseReferences<
              _$AppDatabase,
              $LocalSurveyorVisitsTable,
              LocalSurveyorVisit
            >,
          ),
          LocalSurveyorVisit,
          PrefetchHooks Function()
        > {
  $$LocalSurveyorVisitsTableTableManager(
    _$AppDatabase db,
    $LocalSurveyorVisitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSurveyorVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSurveyorVisitsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalSurveyorVisitsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> visitDataJson = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSurveyorVisitsCompanion(
                idempotencyKey: idempotencyKey,
                taskId: taskId,
                visitDataJson: visitDataJson,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idempotencyKey,
                required String taskId,
                required String visitDataJson,
                Value<int> syncStatus = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalSurveyorVisitsCompanion.insert(
                idempotencyKey: idempotencyKey,
                taskId: taskId,
                visitDataJson: visitDataJson,
                syncStatus: syncStatus,
                serverId: serverId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSurveyorVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSurveyorVisitsTable,
      LocalSurveyorVisit,
      $$LocalSurveyorVisitsTableFilterComposer,
      $$LocalSurveyorVisitsTableOrderingComposer,
      $$LocalSurveyorVisitsTableAnnotationComposer,
      $$LocalSurveyorVisitsTableCreateCompanionBuilder,
      $$LocalSurveyorVisitsTableUpdateCompanionBuilder,
      (
        LocalSurveyorVisit,
        BaseReferences<
          _$AppDatabase,
          $LocalSurveyorVisitsTable,
          LocalSurveyorVisit
        >,
      ),
      LocalSurveyorVisit,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalReportsTableTableManager get localReports =>
      $$LocalReportsTableTableManager(_db, _db.localReports);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalPhotosTableTableManager get localPhotos =>
      $$LocalPhotosTableTableManager(_db, _db.localPhotos);
  $$LocalSurveyorTasksTableTableManager get localSurveyorTasks =>
      $$LocalSurveyorTasksTableTableManager(_db, _db.localSurveyorTasks);
  $$LocalSurveyorVisitsTableTableManager get localSurveyorVisits =>
      $$LocalSurveyorVisitsTableTableManager(_db, _db.localSurveyorVisits);
}
