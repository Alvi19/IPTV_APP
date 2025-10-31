// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'screens/device_input_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // ✅ Paksa orientasi landscape (cocok untuk TV/STB)
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);

//   // ✅ Hilangkan status bar & navigation bar (full screen TV mode)
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Hotel IPTV Launcher',
//       theme: ThemeData.dark(),
//       home: const DeviceInputScreen(), // 🟡 langsung ke input screen
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iptv_app/services/device_identifier.dart';
import 'screens/device_input_screen.dart';
import 'screens/splash_screen.dart';
// import '../services/device_storage.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final api = ApiService();
  final savedDeviceId = await DeviceIdentifier.getDeviceId();

  Widget initialScreen;

  if (savedDeviceId != null && savedDeviceId.isNotEmpty) {
    print("📱 Device ID tersimpan di lokal: $savedDeviceId");
    final response = await api.getDeviceConfigAuto(savedDeviceId);

    if (response['status'] == true) {
      print("✅ Device valid di database!");
      initialScreen = SplashScreen(deviceId: savedDeviceId);
    } else {
      print("⚠️ Device ID tidak ditemukan di database, reset lokal");
      await DeviceIdentifier.clearDeviceId();
      initialScreen = const DeviceInputScreen();
    }
  } else {
    print("ℹ️ Tidak ada Device ID lokal, tampilkan input manual.");
    initialScreen = const DeviceInputScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel IPTV Launcher',
      theme: ThemeData.dark(),
      home: initialScreen,
    );
  }
}
