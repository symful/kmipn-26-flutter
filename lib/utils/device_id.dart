import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceId {
  static String? _cached;
  static const _key = 'device_id';

  static Future<String> current() async {
    if (_cached != null) return _cached!;

    final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    var deviceId = await storage.read(key: _key);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await storage.write(key: _key, value: deviceId);
    }
    _cached = deviceId;
    return deviceId;
  }
}
