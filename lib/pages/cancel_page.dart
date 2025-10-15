// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class CancelPage extends StatefulWidget {
//   const CancelPage({super.key});

//   @override
//   State<CancelPage> createState() => _CancelPageState();
// }

// class _CancelPageState extends State<CancelPage> {
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 40,
//             right: 40,
//             child: Text(
//               "12.12",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomLeft,
//             child: Padding(
//               padding: const EdgeInsets.all(40.0),
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Colors.white, width: 1.5),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 40,
//                     vertical: 15,
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.pushReplacementNamed(context, '/welcome');
//                 },
//                 child: const Text(
//                   "CLICK OK TO CONTINUE",
//                   style: TextStyle(
//                     color: Colors.white,
//                     letterSpacing: 1.2,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
