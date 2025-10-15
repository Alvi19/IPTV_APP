// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class HotelInfoPage extends StatefulWidget {
//   const HotelInfoPage({super.key});

//   @override
//   State<HotelInfoPage> createState() => _HotelInfoPageState();
// }

// class _HotelInfoPageState extends State<HotelInfoPage> {
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
//       body: Stack(
//         children: [
//           // Background gradasi hitam-abu
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF0D0D0D), Color(0xFF2B2B2B)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),

//           // Sidebar kiri
//           Container(
//             width: 250,
//             color: Colors.black.withOpacity(0.5),
//             padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   "Welcome,\nRoom",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 SizedBox(height: 40),
//                 _SideMenuItem(label: "About Hotel"),
//                 _SideMenuItem(label: "Room Type"),
//                 _SideMenuItem(label: "Nearby Place"),
//                 _SideMenuItem(label: "Facility"),
//                 _SideMenuItem(label: "Event"),
//                 _SideMenuItem(label: "Promotion"),
//                 _SideMenuItem(label: "Policy"),
//               ],
//             ),
//           ),

//           // Jam kanan atas
//           Positioned(
//             top: 40,
//             right: 40,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: const [
//                 Text(
//                   "12.12",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   "Wed, 15 Oct 2025",
//                   style: TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SideMenuItem extends StatelessWidget {
//   final String label;
//   const _SideMenuItem({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     );
//   }
// }
