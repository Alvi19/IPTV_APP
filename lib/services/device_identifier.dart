import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdentifier {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // gunakan Android ID (aman dan unik)
      return androidInfo.id ?? 'UNKNOWN_DEVICE';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'UNKNOWN_DEVICE';
    } else {
      return 'UNKNOWN_DEVICE';
    }
  }
}
