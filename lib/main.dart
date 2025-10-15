// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:iptv_app/pages/cancel_page.dart';
// import 'package:iptv_app/pages/welcome_page.dart';
// // import 'cancel_page.dart';
// // import 'welcome_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Hotel Access System',
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const RoomNumberPage(),
//         '/cancel': (context) => const CancelPage(),
//         '/welcome': (context) => const WelcomePage(),
//       },
//     );
//   }
// }

// class RoomNumberPage extends StatefulWidget {
//   const RoomNumberPage({super.key});

//   @override
//   State<RoomNumberPage> createState() => _RoomNumberPageState();
// }

// class _RoomNumberPageState extends State<RoomNumberPage> {
//   final TextEditingController _roomController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFD1C3C3),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.construction, color: Colors.white, size: 60),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: 200,
//               child: TextField(
//                 controller: _roomController,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: const InputDecoration(
//                   hintText: 'Room number',
//                   hintStyle: TextStyle(color: Colors.white70),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.white),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/cancel');
//                   },
//                   child: const Text(
//                     'CANCEL',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(width: 30),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/welcome');
//                   },
//                   child: const Text(
//                     'SUBMIT',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const IPTVApp());
}
