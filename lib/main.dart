// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'screens/splash_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   //  Paksa orientasi landscape untuk seluruh aplikasi
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);

//   // Hilangkan status bar dan navigation bar (STB/TV mode)
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Hotel Launcher',
//       theme: ThemeData.dark(),
//       home: const SplashScreen(), // mulai dari splash screen
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/device_input_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Paksa orientasi landscape (cocok untuk TV/STB)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ✅ Hilangkan status bar & navigation bar (full screen TV mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel IPTV Launcher',
      theme: ThemeData.dark(),
      home: const DeviceInputScreen(), // 🟡 langsung ke input screen
    );
  }
}
