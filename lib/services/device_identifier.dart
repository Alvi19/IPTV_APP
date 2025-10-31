import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentifier {
  static const _deviceIdKey = 'device_id';

  /// 🔹 Simpan device_id ke penyimpanan lokal
  static Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  /// 🔹 Ambil device_id dari penyimpanan lokal
  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  /// 🔹 Hapus device_id (misalnya saat pindah kamar / reset)
  static Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}
