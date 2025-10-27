// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../services/api_service.dart';
// import '../services/mqtt_manager.dart';

// class HotelInfoScreen extends StatefulWidget {
//   final int? hotelId;
//   final int? roomId;
//   final String? deviceId;
//   final String? hotelName;
//   final String? guestName;
//   final String? roomNumber;
//   final String? backgroundUrl;

//   const HotelInfoScreen({
//     super.key,
//     this.hotelId,
//     this.roomId,
//     this.deviceId,
//     this.hotelName,
//     this.guestName,
//     this.roomNumber,
//     this.backgroundUrl,
//   });

//   @override
//   State<HotelInfoScreen> createState() => _HotelInfoScreenState();
// }

// class _HotelInfoScreenState extends State<HotelInfoScreen> {
//   final ApiService api = ApiService();
//   final ScrollController _sidebarController = ScrollController();
//   final FocusNode _focusNode = FocusNode();

//   bool isLoading = true;
//   bool _isMqttConnected = false;
//   String? errorMessage;

//   String? deviceId;
//   int? hotelId;
//   int? roomId;
//   String? logoUrl;
//   String? backgroundUrl;
//   String? hotelName;
//   String? guestName;
//   String? roomNumber;

//   Map<String, List<Map<String, dynamic>>> contents = {};
//   List<Map<String, dynamic>> banners = [];

//   int selectedMenuIndex = 0;
//   int _expandedIndex = -1;

//   final List<Map<String, dynamic>> sidebarMenus = const [
//     {
//       'key': 'about',
//       'name': 'HOTEL PROFILE',
//       'icon': Icons.account_balance_rounded,
//     },
//     {'key': 'room_type', 'name': 'ROOM TYPE', 'icon': Icons.king_bed_rounded},
//     {'key': 'facility', 'name': 'FACILITIES', 'icon': Icons.spa_rounded},
//     {
//       'key': 'restaurant',
//       'name': 'RESTAURANT',
//       'icon': Icons.restaurant_rounded,
//     },
//     {'key': 'promo', 'name': 'PROMO', 'icon': Icons.local_offer_rounded},
//     {'key': 'event', 'name': 'EVENT', 'icon': Icons.event_available_rounded},
//     {'key': 'policy', 'name': 'POLICY', 'icon': Icons.policy_rounded},
//   ];

//   double scale(BuildContext context, double value) {
//     final w = MediaQuery.of(context).size.width;
//     return value * (w / 1920);
//   }

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Ambil data dari halaman sebelumnya (LauncherScreen)
//     deviceId = widget.deviceId;
//     hotelId = widget.hotelId;
//     roomId = widget.roomId;
//     hotelName = widget.hotelName;
//     guestName = widget.guestName;
//     roomNumber = widget.roomNumber;
//     backgroundUrl = widget.backgroundUrl;

//     // 🧩 Tambahkan log di sini ⬇️
//     print("📦 HotelInfoScreen Loaded:");
//     print("→ Guest: $guestName | Room: $roomNumber | BG: $backgroundUrl");

//     _initialize();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_focusNode.hasFocus) _focusNode.requestFocus();
//     });
//   }

//   // Future<void> _initialize() async {
//   //   try {
//   //     // Jika data belum lengkap → fallback ke API
//   //     if (deviceId == null) {
//   //       final config = await api.getDeviceConfigAuto();
//   //       deviceId = config['device_id'];
//   //       hotelId = config['hotel_id'];
//   //       roomId = config['room_id'];
//   //       hotelName ??= config['hotel_name'];
//   //     }

//   //     await _fetchInitialContent();
//   //     await _initializeMqtt();
//   //   } catch (e) {
//   //     setState(() {
//   //       errorMessage = e.toString();
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   // Future<void> _fetchInitialContent() async {
//   //   try {
//   //     final data = await api.getContent(deviceId!);
//   //     final hotel = data['hotel'] ?? {};
//   //     final contentData = Map<String, List<Map<String, dynamic>>>.from(
//   //       (data['contents'] ?? {}).map(
//   //         (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
//   //       ),
//   //     );

//   //     setState(() {
//   //       logoUrl ??= hotel['logo_url'];
//   //       // Jangan override background jika sudah dikirim dari launcher
//   //       if ((backgroundUrl == null || backgroundUrl!.isEmpty) &&
//   //           (hotel['background_image_url'] != null &&
//   //               hotel['background_image_url'].toString().isNotEmpty)) {
//   //         backgroundUrl = hotel['background_image_url'];
//   //       }

//   //       contents = contentData;
//   //       banners = List<Map<String, dynamic>>.from(data['banners'] ?? []);
//   //       isLoading = false;
//   //     });

//   //     print("✅ Loaded initial content: ${contents.keys}");
//   //   } catch (e) {
//   //     setState(() => isLoading = false);
//   //     print("❌ Error fetching content: $e");
//   //   }
//   // }

//   Future<void> _initialize() async {
//     try {
//       if (deviceId == null) {
//         final config = await api.getDeviceConfigAuto();
//         if (!mounted) return; // ✅ FIX
//         deviceId = config['device_id'];
//         hotelId = config['hotel_id'];
//         roomId = config['room_id'];
//         hotelName ??= config['hotel_name'];
//       }

//       await _fetchInitialContent();
//       if (!mounted) return; // ✅ FIX
//       await _initializeMqtt();
//     } catch (e) {
//       if (!mounted) return; // ✅ FIX
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchInitialContent() async {
//     try {
//       final data = await api.getContent(deviceId!);
//       if (!mounted) return; // ✅ FIX

//       final hotel = data['hotel'] ?? {};
//       final contentData = Map<String, List<Map<String, dynamic>>>.from(
//         (data['contents'] ?? {}).map(
//           (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
//         ),
//       );

//       if (!mounted) return; // ✅ FIX
//       setState(() {
//         logoUrl ??= hotel['logo_url'];
//         if ((backgroundUrl == null || backgroundUrl!.isEmpty) &&
//             (hotel['background_image_url'] != null &&
//                 hotel['background_image_url'].toString().isNotEmpty)) {
//           backgroundUrl = hotel['background_image_url'];
//         }

//         contents = contentData;
//         banners = List<Map<String, dynamic>>.from(data['banners'] ?? []);
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return; // ✅ FIX
//       setState(() => isLoading = false);
//       print("❌ Error fetching content: $e");
//     }
//   }

//   // Future<void> _initializeMqtt() async {
//   //   if (_isMqttConnected ||
//   //       hotelId == null ||
//   //       roomId == null ||
//   //       deviceId == null)
//   //     return;
//   //   _isMqttConnected = true;

//   //   await MqttManager.instance.connect(
//   //     deviceId: deviceId!,
//   //     hotelId: hotelId!,
//   //     roomId: roomId!,
//   //     onMessage: (payload) async {
//   //       if (!mounted) return;

//   //       final event = payload['event'];
//   //       if (event == 'launcher_update') {
//   //         setState(() {
//   //           backgroundUrl = payload['background_image_url'] ?? backgroundUrl;
//   //           guestName = payload['guest_name'] ?? guestName;
//   //           roomNumber = payload['room_number'] ?? roomNumber;
//   //         });
//   //       } else if (event == 'content_update') {
//   //         final updatedContents = Map<String, List<Map<String, dynamic>>>.from(
//   //           (payload['contents'] ?? {}).map(
//   //             (key, value) =>
//   //                 MapEntry(key, List<Map<String, dynamic>>.from(value)),
//   //           ),
//   //         );
//   //         setState(() {
//   //           contents = updatedContents;
//   //           banners = List<Map<String, dynamic>>.from(payload['banners'] ?? []);
//   //         });
//   //       }
//   //     },
//   //   );
//   // }
//   Future<void> _initializeMqtt() async {
//     if (_isMqttConnected ||
//         hotelId == null ||
//         roomId == null ||
//         deviceId == null)
//       return;
//     _isMqttConnected = true;

//     await MqttManager.instance.connect(
//       deviceId: deviceId!,
//       hotelId: hotelId!,
//       roomId: roomId!,
//       onMessage: (payload) async {
//         if (!mounted) return; // ✅ FIX
//         final event = payload['event'];

//         if (!mounted) return; // ✅ FIX

//         if (event == 'launcher_update') {
//           if (!mounted) return; // ✅ FIX
//           setState(() {
//             backgroundUrl = payload['background_image_url'] ?? backgroundUrl;
//             guestName = payload['guest_name'] ?? guestName;
//             roomNumber = payload['room_number'] ?? roomNumber;
//           });
//         } else if (event == 'content_update') {
//           if (!mounted) return; // ✅ FIX
//           final updatedContents = Map<String, List<Map<String, dynamic>>>.from(
//             (payload['contents'] ?? {}).map(
//               (key, value) =>
//                   MapEntry(key, List<Map<String, dynamic>>.from(value)),
//             ),
//           );

//           setState(() {
//             contents = updatedContents;
//             banners = List<Map<String, dynamic>>.from(payload['banners'] ?? []);
//           });
//         }
//       },
//     );
//   }

//   void _handleKeyEvent(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent) return;
//     final key = event.logicalKey.debugName?.toLowerCase() ?? '';
//     if (key.contains('arrow down')) {
//       setState(
//         () => selectedMenuIndex = (selectedMenuIndex + 1) % sidebarMenus.length,
//       );
//     } else if (key.contains('arrow up')) {
//       setState(
//         () => selectedMenuIndex =
//             (selectedMenuIndex - 1 + sidebarMenus.length) % sidebarMenus.length,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;

//     if (isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
//         ),
//       );
//     }

//     final selectedKey = sidebarMenus[selectedMenuIndex]['key'];
//     final currentContent = contents[selectedKey] ?? [];

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: RawKeyboardListener(
//         focusNode: _focusNode,
//         autofocus: true,
//         onKey: _handleKeyEvent,
//         child: Stack(
//           children: [
//             // 🖼 Background
//             if (backgroundUrl != null && backgroundUrl!.isNotEmpty)
//               Positioned.fill(
//                 child: Image.network(
//                   backgroundUrl!,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(color: Colors.black),
//                 ),
//               )
//             else
//               Container(color: Colors.black),

//             Container(color: Colors.black.withOpacity(0.35)),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // 🧭 Sidebar
//                 Container(
//                   width: w * 0.25,
//                   color: Colors.transparent,
//                   padding: EdgeInsets.symmetric(vertical: scale(context, 10)),
//                   child: Column(
//                     children: [
//                       // ⏰ Jam & tanggal tetap di atas
//                       Text(
//                         DateFormat('h:mm a').format(DateTime.now()),
//                         style: GoogleFonts.playfairDisplay(
//                           color: Colors.white,
//                           fontSize: scale(context, 50),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
//                         style: GoogleFonts.poppins(
//                           color: Colors.white70,
//                           fontSize: scale(context, 20),
//                         ),
//                       ),

//                       // 🔹 Spacer biar jarak jam ke menu pas
//                       SizedBox(height: scale(context, 40)),

//                       // 🔹 Sidebar menu dan card harus sejajar tinggi
//                       Expanded(
//                         child: LayoutBuilder(
//                           builder: (context, constraints) {
//                             return SizedBox(
//                               height: constraints
//                                   .maxHeight, // penuh sejajar tinggi card
//                               child: Align(
//                                 alignment: Alignment.topCenter,
//                                 child: Container(
//                                   height: h * 0.8, // tinggi card putih
//                                   child: ListView.builder(
//                                     controller: _sidebarController,
//                                     itemCount: sidebarMenus.length,
//                                     itemBuilder: (context, index) {
//                                       final isSelected =
//                                           selectedMenuIndex == index;
//                                       return GestureDetector(
//                                         onTap: () => setState(
//                                           () => selectedMenuIndex = index,
//                                         ),
//                                         child: AnimatedContainer(
//                                           duration: const Duration(
//                                             milliseconds: 200,
//                                           ),
//                                           margin: EdgeInsets.symmetric(
//                                             vertical: scale(context, 10),
//                                             horizontal: scale(context, 30),
//                                           ),
//                                           padding: EdgeInsets.symmetric(
//                                             vertical: scale(context, 18),
//                                             horizontal: scale(context, 24),
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: isSelected
//                                                 ? const Color(0xFFC9A96E)
//                                                 : Colors.transparent,
//                                             borderRadius: BorderRadius.circular(
//                                               scale(context, 25),
//                                             ),
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 sidebarMenus[index]['icon'],
//                                                 color: isSelected
//                                                     ? Colors.black
//                                                     : Colors.white70,
//                                                 size: scale(context, 28),
//                                               ),
//                                               SizedBox(
//                                                 width: scale(context, 10),
//                                               ),
//                                               Flexible(
//                                                 child: Text(
//                                                   sidebarMenus[index]['name'],
//                                                   style: GoogleFonts.poppins(
//                                                     color: isSelected
//                                                         ? Colors.black
//                                                         : Colors.white70,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontSize: scale(
//                                                       context,
//                                                       20,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // 🌆 Main Content
//                 Expanded(
//                   child: Center(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         // 🔹 Baris atas: logo + guest info di kanan
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: scale(context, 60),
//                             vertical: scale(context, 20),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               // 🏨 Logo hotel di kiri
//                               if (logoUrl != null)
//                                 Image.network(
//                                   logoUrl!,
//                                   height: scale(
//                                     context,
//                                     120,
//                                   ), // ubah tinggi sesuai kebutuhan
//                                   fit: BoxFit.contain,
//                                   errorBuilder: (_, __, ___) =>
//                                       const SizedBox(),
//                                 )
//                               else
//                                 const SizedBox(),

//                               // 🧍 Guest info di kanan
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   if (guestName != null &&
//                                       guestName!.isNotEmpty)
//                                     Text(
//                                       "Welcome, $guestName",
//                                       textAlign: TextAlign.right,
//                                       style: GoogleFonts.poppins(
//                                         color: Colors.white,
//                                         fontSize: scale(context, 26),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   if (roomNumber != null &&
//                                       roomNumber!.isNotEmpty)
//                                     Text(
//                                       "Room $roomNumber",
//                                       textAlign: TextAlign.right,
//                                       style: GoogleFonts.poppins(
//                                         color: Colors.white70,
//                                         fontSize: scale(context, 26),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),

//                         // ✅ Card utama untuk konten dinamis
//                         Container(
//                           width: w * 0.7,
//                           height: h * 0.8,
//                           padding: EdgeInsets.all(scale(context, 35)),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(
//                               scale(context, 20),
//                             ),
//                           ),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 if (selectedKey == 'room_type') ...[
//                                   // ✅ tampilkan room type sekali saja
//                                   SizedBox(
//                                     height: scale(context, 300),
//                                     child: ListView.builder(
//                                       key: const PageStorageKey(
//                                         'room_type_list',
//                                       ),
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: currentContent.length,
//                                       itemBuilder: (context, index) {
//                                         final item = currentContent[index];
//                                         final imageUrl =
//                                             item['image_url'] ?? '';
//                                         final title = item['title'] ?? '';
//                                         final isSelected =
//                                             _expandedIndex == index;

//                                         return GestureDetector(
//                                           onTap: () {
//                                             setState(() {
//                                               _expandedIndex = isSelected
//                                                   ? -1
//                                                   : index;
//                                             });
//                                           },
//                                           child: AnimatedContainer(
//                                             duration: const Duration(
//                                               milliseconds: 250,
//                                             ),
//                                             margin: EdgeInsets.symmetric(
//                                               horizontal: scale(context, 15),
//                                               vertical: scale(context, 10),
//                                             ),
//                                             width: scale(context, 280),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                     scale(context, 18),
//                                                   ),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.black
//                                                       .withOpacity(0.15),
//                                                   blurRadius: 8,
//                                                   offset: const Offset(0, 4),
//                                                 ),
//                                               ],
//                                               border: Border.all(
//                                                 color: isSelected
//                                                     ? const Color(0xFFC9A96E)
//                                                     : Colors.transparent,
//                                                 width: 2,
//                                               ),
//                                             ),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                         topLeft:
//                                                             Radius.circular(
//                                                               scale(
//                                                                 context,
//                                                                 18,
//                                                               ),
//                                                             ),
//                                                         topRight:
//                                                             Radius.circular(
//                                                               scale(
//                                                                 context,
//                                                                 18,
//                                                               ),
//                                                             ),
//                                                       ),
//                                                   child: Image.network(
//                                                     imageUrl,
//                                                     width: double.infinity,
//                                                     height: scale(context, 180),
//                                                     fit: BoxFit.cover,
//                                                     errorBuilder:
//                                                         (
//                                                           _,
//                                                           __,
//                                                           ___,
//                                                         ) => Container(
//                                                           height: scale(
//                                                             context,
//                                                             180,
//                                                           ),
//                                                           color: Colors
//                                                               .grey
//                                                               .shade300,
//                                                           child: const Icon(
//                                                             Icons
//                                                                 .image_not_supported,
//                                                             color: Colors.grey,
//                                                           ),
//                                                         ),
//                                                   ),
//                                                 ),
//                                                 Padding(
//                                                   padding: EdgeInsets.all(
//                                                     scale(context, 12),
//                                                   ),
//                                                   child: Text(
//                                                     title,
//                                                     maxLines: 2,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: GoogleFonts.poppins(
//                                                       color: Colors.black87,
//                                                       fontSize: scale(
//                                                         context,
//                                                         18,
//                                                       ),
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),

//                                   // 🔹 Detail Room Type (muncul di bawah)
//                                   if (_expandedIndex != -1 &&
//                                       _expandedIndex < currentContent.length)
//                                     AnimatedSwitcher(
//                                       duration: const Duration(
//                                         milliseconds: 400,
//                                       ),
//                                       transitionBuilder: (child, anim) =>
//                                           FadeTransition(
//                                             opacity: anim,
//                                             child: child,
//                                           ),
//                                       child: Container(
//                                         key: ValueKey(_expandedIndex),
//                                         margin: EdgeInsets.only(
//                                           top: scale(context, 30),
//                                         ),
//                                         padding: EdgeInsets.all(
//                                           scale(context, 25),
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(
//                                             scale(context, 25),
//                                           ),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.black.withOpacity(
//                                                 0.1,
//                                               ),
//                                               blurRadius: 8,
//                                               offset: const Offset(0, 4),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Builder(
//                                           builder: (context) {
//                                             final selected =
//                                                 currentContent[_expandedIndex];
//                                             final imageUrl =
//                                                 selected['image_url'] ?? '';
//                                             final title =
//                                                 selected['title'] ?? '';
//                                             final body = selected['body'] ?? '';

//                                             return Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 if (imageUrl.isNotEmpty)
//                                                   ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           scale(context, 12),
//                                                         ),
//                                                     child: Image.network(
//                                                       imageUrl,
//                                                       width: double.infinity,
//                                                       height: scale(
//                                                         context,
//                                                         350,
//                                                       ),
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                 SizedBox(
//                                                   height: scale(context, 20),
//                                                 ),
//                                                 Text(
//                                                   title,
//                                                   style:
//                                                       GoogleFonts.playfairDisplay(
//                                                         color: const Color(
//                                                           0xFFC9A96E,
//                                                         ),
//                                                         fontSize: scale(
//                                                           context,
//                                                           32,
//                                                         ),
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                 ),
//                                                 SizedBox(
//                                                   height: scale(context, 10),
//                                                 ),
//                                                 Text(
//                                                   body,
//                                                   textAlign: TextAlign.justify,
//                                                   style: GoogleFonts.poppins(
//                                                     color: Colors.black87,
//                                                     fontSize: scale(
//                                                       context,
//                                                       18,
//                                                     ),
//                                                     height: 1.6,
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                 ] else ...[
//                                   // 🔹 Menu lain (about, facility, promo, dll)
//                                   ...currentContent.map((item) {
//                                     // isi switch-case lain kamu tetap sama persis
//                                     // tidak perlu diubah
//                                     final key = selectedKey;
//                                     final imageUrl = item['image_url'] ?? '';
//                                     final title = item['title'] ?? '';
//                                     final body = item['body'] ?? '';
//                                     final extra = item['extra_data'] ?? {};
//                                     Widget contentWidget;

//                                     switch (key) {
//                                       case 'about':
//                                         contentWidget = Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             if (imageUrl.isNotEmpty)
//                                               Expanded(
//                                                 flex: 1,
//                                                 child: ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                         scale(context, 12),
//                                                       ),
//                                                   child: Image.network(
//                                                     imageUrl,
//                                                     fit: BoxFit.cover,
//                                                     height: scale(context, 250),
//                                                   ),
//                                                 ),
//                                               ),
//                                             SizedBox(width: scale(context, 30)),
//                                             Expanded(
//                                               flex: 2,
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     title,
//                                                     style:
//                                                         GoogleFonts.playfairDisplay(
//                                                           color: const Color(
//                                                             0xFFC9A96E,
//                                                           ),
//                                                           fontSize: scale(
//                                                             context,
//                                                             32,
//                                                           ),
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: scale(context, 10),
//                                                   ),
//                                                   Text(
//                                                     body,
//                                                     textAlign:
//                                                         TextAlign.justify,
//                                                     style: GoogleFonts.poppins(
//                                                       color: Colors.white,
//                                                       fontSize: scale(
//                                                         context,
//                                                         20,
//                                                       ),
//                                                       height: 1.6,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                         break;
//                                       case 'facility':
//                                         // 🏋️ Facility — gambar kiri, teks kanan
//                                         contentWidget = Container(
//                                           margin: EdgeInsets.only(
//                                             bottom: scale(context, 25),
//                                           ),
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               if (imageUrl.isNotEmpty)
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                         scale(context, 12),
//                                                       ),
//                                                   child: Image.network(
//                                                     imageUrl,
//                                                     width: scale(context, 250),
//                                                     height: scale(context, 180),
//                                                     fit: BoxFit.cover,
//                                                     errorBuilder:
//                                                         (
//                                                           _,
//                                                           __,
//                                                           ___,
//                                                         ) => Container(
//                                                           width: scale(
//                                                             context,
//                                                             250,
//                                                           ),
//                                                           height: scale(
//                                                             context,
//                                                             180,
//                                                           ),
//                                                           color: Colors
//                                                               .grey
//                                                               .shade300,
//                                                           child: const Icon(
//                                                             Icons
//                                                                 .image_not_supported,
//                                                             color: Colors.grey,
//                                                           ),
//                                                         ),
//                                                   ),
//                                                 ),
//                                               SizedBox(
//                                                 width: scale(context, 25),
//                                               ),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       title,
//                                                       style:
//                                                           GoogleFonts.playfairDisplay(
//                                                             color: const Color(
//                                                               0xFFC9A96E,
//                                                             ),
//                                                             fontSize: scale(
//                                                               context,
//                                                               28,
//                                                             ),
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                           ),
//                                                     ),
//                                                     SizedBox(
//                                                       height: scale(context, 8),
//                                                     ),
//                                                     Text(
//                                                       body,
//                                                       textAlign:
//                                                           TextAlign.justify,
//                                                       style:
//                                                           GoogleFonts.poppins(
//                                                             color: Colors.white,
//                                                             fontSize: scale(
//                                                               context,
//                                                               18,
//                                                             ),
//                                                             height: 1.5,
//                                                           ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                         break;

//                                       case 'restaurant':
//                                         // 🍽 Restaurant — tampilkan gambar + nama menu + harga
//                                         contentWidget = Container(
//                                           margin: EdgeInsets.only(
//                                             bottom: scale(context, 25),
//                                           ),
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               if (imageUrl.isNotEmpty)
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                         scale(context, 12),
//                                                       ),
//                                                   child: Image.network(
//                                                     imageUrl,
//                                                     width: scale(context, 160),
//                                                     height: scale(context, 160),
//                                                     fit: BoxFit.cover,
//                                                     errorBuilder:
//                                                         (
//                                                           _,
//                                                           __,
//                                                           ___,
//                                                         ) => Container(
//                                                           width: scale(
//                                                             context,
//                                                             160,
//                                                           ),
//                                                           height: scale(
//                                                             context,
//                                                             160,
//                                                           ),
//                                                           color: Colors
//                                                               .grey
//                                                               .shade300,
//                                                           child: const Icon(
//                                                             Icons
//                                                                 .image_not_supported,
//                                                             color: Colors.grey,
//                                                           ),
//                                                         ),
//                                                   ),
//                                                 ),
//                                               SizedBox(
//                                                 width: scale(context, 25),
//                                               ),
//                                               Expanded(
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       extra['menu_name'] ??
//                                                           title,
//                                                       style:
//                                                           GoogleFonts.poppins(
//                                                             color: Colors.white,
//                                                             fontSize: scale(
//                                                               context,
//                                                               22,
//                                                             ),
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                           ),
//                                                     ),
//                                                     SizedBox(
//                                                       height: scale(context, 6),
//                                                     ),
//                                                     Text(
//                                                       body,
//                                                       style:
//                                                           GoogleFonts.poppins(
//                                                             color:
//                                                                 Colors.white70,
//                                                             fontSize: scale(
//                                                               context,
//                                                               18,
//                                                             ),
//                                                           ),
//                                                     ),
//                                                     SizedBox(
//                                                       height: scale(context, 6),
//                                                     ),
//                                                     if (extra['menu_price'] !=
//                                                         null)
//                                                       Text(
//                                                         "Rp ${extra['menu_price']}",
//                                                         style:
//                                                             GoogleFonts.poppins(
//                                                               color:
//                                                                   const Color(
//                                                                     0xFFC9A96E,
//                                                                   ),
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               fontSize: scale(
//                                                                 context,
//                                                                 22,
//                                                               ),
//                                                             ),
//                                                       ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                         break;

//                                       case 'promo':
//                                         // 🎉 Promo — gambar di atas, deskripsi di bawah
//                                         contentWidget = Container(
//                                           margin: EdgeInsets.only(
//                                             bottom: scale(context, 25),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               if (imageUrl.isNotEmpty)
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                         scale(context, 12),
//                                                       ),
//                                                   child: Image.network(
//                                                     imageUrl,
//                                                     width: double.infinity,
//                                                     height: scale(context, 280),
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                               SizedBox(
//                                                 height: scale(context, 15),
//                                               ),
//                                               Text(
//                                                 title,
//                                                 style:
//                                                     GoogleFonts.playfairDisplay(
//                                                       color: const Color(
//                                                         0xFFC9A96E,
//                                                       ),
//                                                       fontSize: scale(
//                                                         context,
//                                                         28,
//                                                       ),
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                               ),
//                                               SizedBox(
//                                                 height: scale(context, 10),
//                                               ),
//                                               Text(
//                                                 body,
//                                                 textAlign: TextAlign.justify,
//                                                 style: GoogleFonts.poppins(
//                                                   color: Colors.white,
//                                                   fontSize: scale(context, 18),
//                                                   height: 1.5,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                         break;

//                                       case 'event':
//                                         // 🎭 Event — mirip promo tapi beda margin
//                                         contentWidget = Container(
//                                           margin: EdgeInsets.only(
//                                             bottom: scale(context, 25),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               if (imageUrl.isNotEmpty)
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                         scale(context, 12),
//                                                       ),
//                                                   child: Image.network(
//                                                     imageUrl,
//                                                     // width: double.infinity,
//                                                     // height: scale(context, 280),
//                                                     width:
//                                                         w *
//                                                         0.8, // bisa kamu sesuaikan
//                                                     height: scale(context, 400),
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                               SizedBox(
//                                                 height: scale(context, 15),
//                                               ),
//                                               Text(
//                                                 title,
//                                                 style:
//                                                     GoogleFonts.playfairDisplay(
//                                                       color: const Color(
//                                                         0xFFC9A96E,
//                                                       ),
//                                                       fontSize: scale(
//                                                         context,
//                                                         28,
//                                                       ),
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                               ),
//                                               SizedBox(
//                                                 height: scale(context, 10),
//                                               ),
//                                               Text(
//                                                 body,
//                                                 textAlign: TextAlign.justify,
//                                                 style: GoogleFonts.poppins(
//                                                   color: Colors.white,
//                                                   fontSize: scale(context, 18),
//                                                   height: 1.5,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                         break;

//                                       // case 'event':
//                                       //   // 🎭 Event — tampil grid card dengan klik untuk detail
//                                       //   contentWidget = Column(
//                                       //     crossAxisAlignment:
//                                       //         CrossAxisAlignment.start,
//                                       //     children: [
//                                       //       // 🔹 Scroll horizontal card list
//                                       //       SizedBox(
//                                       //         height: scale(context, 300),
//                                       //         child: ListView.builder(
//                                       //           scrollDirection:
//                                       //               Axis.horizontal,
//                                       //           itemCount:
//                                       //               currentContent.length,
//                                       //           itemBuilder: (context, index) {
//                                       //             final item =
//                                       //                 currentContent[index];
//                                       //             final imageUrl =
//                                       //                 item['image_url'] ?? '';
//                                       //             final title =
//                                       //                 item['title'] ?? '';
//                                       //             final isSelected =
//                                       //                 _expandedIndex == index;

//                                       //             return GestureDetector(
//                                       //               onTap: () {
//                                       //                 setState(() {
//                                       //                   _expandedIndex =
//                                       //                       isSelected
//                                       //                       ? -1
//                                       //                       : index;
//                                       //                 });
//                                       //               },
//                                       //               child: AnimatedContainer(
//                                       //                 duration: const Duration(
//                                       //                   milliseconds: 250,
//                                       //                 ),
//                                       //                 curve: Curves.easeOut,
//                                       //                 margin:
//                                       //                     EdgeInsets.symmetric(
//                                       //                       horizontal: scale(
//                                       //                         context,
//                                       //                         15,
//                                       //                       ),
//                                       //                       vertical: scale(
//                                       //                         context,
//                                       //                         10,
//                                       //                       ),
//                                       //                     ),
//                                       //                 width: scale(
//                                       //                   context,
//                                       //                   280,
//                                       //                 ),
//                                       //                 decoration: BoxDecoration(
//                                       //                   color: Colors.white,
//                                       //                   borderRadius:
//                                       //                       BorderRadius.circular(
//                                       //                         scale(
//                                       //                           context,
//                                       //                           18,
//                                       //                         ),
//                                       //                       ),
//                                       //                   boxShadow: [
//                                       //                     BoxShadow(
//                                       //                       color: Colors.black
//                                       //                           .withOpacity(
//                                       //                             0.15,
//                                       //                           ),
//                                       //                       blurRadius: 8,
//                                       //                       offset:
//                                       //                           const Offset(
//                                       //                             0,
//                                       //                             4,
//                                       //                           ),
//                                       //                     ),
//                                       //                   ],
//                                       //                   border: Border.all(
//                                       //                     color: isSelected
//                                       //                         ? const Color(
//                                       //                             0xFFC9A96E,
//                                       //                           )
//                                       //                         : Colors
//                                       //                               .transparent,
//                                       //                     width: 2,
//                                       //                   ),
//                                       //                 ),
//                                       //                 child: Column(
//                                       //                   crossAxisAlignment:
//                                       //                       CrossAxisAlignment
//                                       //                           .start,
//                                       //                   children: [
//                                       //                     ClipRRect(
//                                       //                       borderRadius: BorderRadius.only(
//                                       //                         topLeft:
//                                       //                             Radius.circular(
//                                       //                               scale(
//                                       //                                 context,
//                                       //                                 18,
//                                       //                               ),
//                                       //                             ),
//                                       //                         topRight:
//                                       //                             Radius.circular(
//                                       //                               scale(
//                                       //                                 context,
//                                       //                                 18,
//                                       //                               ),
//                                       //                             ),
//                                       //                       ),
//                                       //                       child: Image.network(
//                                       //                         imageUrl,
//                                       //                         width: double
//                                       //                             .infinity,
//                                       //                         height: scale(
//                                       //                           context,
//                                       //                           180,
//                                       //                         ),
//                                       //                         fit: BoxFit.cover,
//                                       //                         errorBuilder:
//                                       //                             (
//                                       //                               _,
//                                       //                               __,
//                                       //                               ___,
//                                       //                             ) => Container(
//                                       //                               height: scale(
//                                       //                                 context,
//                                       //                                 180,
//                                       //                               ),
//                                       //                               color: Colors
//                                       //                                   .grey
//                                       //                                   .shade300,
//                                       //                               child: const Icon(
//                                       //                                 Icons
//                                       //                                     .image_not_supported,
//                                       //                                 color: Colors
//                                       //                                     .grey,
//                                       //                               ),
//                                       //                             ),
//                                       //                       ),
//                                       //                     ),
//                                       //                     Padding(
//                                       //                       padding:
//                                       //                           EdgeInsets.all(
//                                       //                             scale(
//                                       //                               context,
//                                       //                               12,
//                                       //                             ),
//                                       //                           ),
//                                       //                       child: Text(
//                                       //                         title,
//                                       //                         maxLines: 2,
//                                       //                         overflow:
//                                       //                             TextOverflow
//                                       //                                 .ellipsis,
//                                       //                         style: GoogleFonts.poppins(
//                                       //                           color: Colors
//                                       //                               .black87,
//                                       //                           fontSize: scale(
//                                       //                             context,
//                                       //                             18,
//                                       //                           ),
//                                       //                           fontWeight:
//                                       //                               FontWeight
//                                       //                                   .w600,
//                                       //                         ),
//                                       //                       ),
//                                       //                     ),
//                                       //                   ],
//                                       //                 ),
//                                       //               ),
//                                       //             );
//                                       //           },
//                                       //         ),
//                                       //       ),

//                                       //       // 🔹 Detail Event muncul di bawah (ketika card diklik)
//                                       //       if (_expandedIndex != -1 &&
//                                       //           _expandedIndex <
//                                       //               currentContent.length)
//                                       //         AnimatedSwitcher(
//                                       //           duration: const Duration(
//                                       //             milliseconds: 400,
//                                       //           ),
//                                       //           transitionBuilder:
//                                       //               (child, anim) =>
//                                       //                   FadeTransition(
//                                       //                     opacity: anim,
//                                       //                     child: child,
//                                       //                   ),
//                                       //           child: Container(
//                                       //             key: ValueKey(_expandedIndex),
//                                       //             margin: EdgeInsets.only(
//                                       //               top: scale(context, 30),
//                                       //             ),
//                                       //             padding: EdgeInsets.all(
//                                       //               scale(context, 25),
//                                       //             ),
//                                       //             decoration: BoxDecoration(
//                                       //               color: Colors.white,
//                                       //               borderRadius:
//                                       //                   BorderRadius.circular(
//                                       //                     scale(context, 25),
//                                       //                   ),
//                                       //               boxShadow: [
//                                       //                 BoxShadow(
//                                       //                   color: Colors.black
//                                       //                       .withOpacity(0.1),
//                                       //                   blurRadius: 8,
//                                       //                   offset: const Offset(
//                                       //                     0,
//                                       //                     4,
//                                       //                   ),
//                                       //                 ),
//                                       //               ],
//                                       //             ),
//                                       //             child: Builder(
//                                       //               builder: (context) {
//                                       //                 final selected =
//                                       //                     currentContent[_expandedIndex];
//                                       //                 final imageUrl =
//                                       //                     selected['image_url'] ??
//                                       //                     '';
//                                       //                 final title =
//                                       //                     selected['title'] ??
//                                       //                     '';
//                                       //                 final body =
//                                       //                     selected['body'] ??
//                                       //                     '';

//                                       //                 return Column(
//                                       //                   crossAxisAlignment:
//                                       //                       CrossAxisAlignment
//                                       //                           .start,
//                                       //                   children: [
//                                       //                     if (imageUrl
//                                       //                         .isNotEmpty)
//                                       //                       ClipRRect(
//                                       //                         borderRadius:
//                                       //                             BorderRadius.circular(
//                                       //                               scale(
//                                       //                                 context,
//                                       //                                 12,
//                                       //                               ),
//                                       //                             ),
//                                       //                         child: Image.network(
//                                       //                           imageUrl,
//                                       //                           width: double
//                                       //                               .infinity,
//                                       //                           height: scale(
//                                       //                             context,
//                                       //                             350,
//                                       //                           ),
//                                       //                           fit: BoxFit
//                                       //                               .cover,
//                                       //                         ),
//                                       //                       ),
//                                       //                     SizedBox(
//                                       //                       height: scale(
//                                       //                         context,
//                                       //                         20,
//                                       //                       ),
//                                       //                     ),
//                                       //                     Text(
//                                       //                       title,
//                                       //                       style: GoogleFonts.playfairDisplay(
//                                       //                         color:
//                                       //                             const Color(
//                                       //                               0xFFC9A96E,
//                                       //                             ),
//                                       //                         fontSize: scale(
//                                       //                           context,
//                                       //                           32,
//                                       //                         ),
//                                       //                         fontWeight:
//                                       //                             FontWeight
//                                       //                                 .bold,
//                                       //                       ),
//                                       //                     ),
//                                       //                     SizedBox(
//                                       //                       height: scale(
//                                       //                         context,
//                                       //                         10,
//                                       //                       ),
//                                       //                     ),
//                                       //                     Text(
//                                       //                       body,
//                                       //                       textAlign: TextAlign
//                                       //                           .justify,
//                                       //                       style:
//                                       //                           GoogleFonts.poppins(
//                                       //                             color: Colors
//                                       //                                 .black87,
//                                       //                             fontSize:
//                                       //                                 scale(
//                                       //                                   context,
//                                       //                                   18,
//                                       //                                 ),
//                                       //                             height: 1.6,
//                                       //                           ),
//                                       //                     ),
//                                       //                   ],
//                                       //                 );
//                                       //               },
//                                       //             ),
//                                       //           ),
//                                       //         ),
//                                       //     ],
//                                       //   );
//                                       //   break;

//                                       case 'policy':
//                                         // 🧾 Policy — tampilkan gambar + deskripsi + jam check-in/out
//                                         contentWidget = Container(
//                                           margin: EdgeInsets.only(
//                                             bottom: scale(context, 25),
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               if (imageUrl.isNotEmpty)
//                                                 ClipRRect(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                         scale(context, 12),
//                                                       ),
//                                                   child: Image.network(
//                                                     imageUrl,
//                                                     width: double.infinity,
//                                                     height: scale(context, 280),
//                                                     fit: BoxFit.cover,
//                                                   ),
//                                                 ),
//                                               SizedBox(
//                                                 height: scale(context, 15),
//                                               ),
//                                               Text(
//                                                 title,
//                                                 style:
//                                                     GoogleFonts.playfairDisplay(
//                                                       color: const Color(
//                                                         0xFFC9A96E,
//                                                       ),
//                                                       fontSize: scale(
//                                                         context,
//                                                         28,
//                                                       ),
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                               ),
//                                               SizedBox(
//                                                 height: scale(context, 10),
//                                               ),
//                                               Text(
//                                                 body,
//                                                 textAlign: TextAlign.justify,
//                                                 style: GoogleFonts.poppins(
//                                                   color: Colors.white,
//                                                   fontSize: scale(context, 18),
//                                                   height: 1.5,
//                                                 ),
//                                               ),
//                                               if (extra['checkin_time'] != null)
//                                                 Padding(
//                                                   padding: EdgeInsets.only(
//                                                     top: scale(context, 8),
//                                                   ),
//                                                   child: Text(
//                                                     "Check-in: ${extra['checkin_time']} | Check-out: ${extra['checkout_time']}",
//                                                     style: GoogleFonts.poppins(
//                                                       color: Colors.white70,
//                                                       fontSize: scale(
//                                                         context,
//                                                         16,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         );
//                                         break;

//                                       default:
//                                         contentWidget = Text(body);
//                                     }
//                                     return Padding(
//                                       padding: EdgeInsets.only(
//                                         bottom: scale(context, 30),
//                                       ),
//                                       child: contentWidget,
//                                     );
//                                   }),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _sidebarController.dispose();
//     MqttManager.instance.disconnect();
//     super.dispose();
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/mqtt_manager.dart';

class HotelInfoScreen extends StatefulWidget {
  final int? hotelId;
  final int? roomId;
  final String? deviceId;
  final String? hotelName;
  final String? guestName;
  final String? roomNumber;
  final String? backgroundUrl;

  const HotelInfoScreen({
    super.key,
    this.hotelId,
    this.roomId,
    this.deviceId,
    this.hotelName,
    this.guestName,
    this.roomNumber,
    this.backgroundUrl,
  });

  @override
  State<HotelInfoScreen> createState() => _HotelInfoScreenState();
}

class _HotelInfoScreenState extends State<HotelInfoScreen> {
  final ApiService api = ApiService();
  final ScrollController _sidebarController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool isLoading = true;
  bool _isMqttConnected = false;
  String? errorMessage;

  String? deviceId;
  int? hotelId;
  int? roomId;
  String? logoUrl;
  String? backgroundUrl;
  String? hotelName;
  String? guestName;
  String? roomNumber;

  Map<String, List<Map<String, dynamic>>> contents = {};
  List<Map<String, dynamic>> banners = [];

  int selectedMenuIndex = 0; // default 0 agar ada fokus awal
  int _expandedIndex = -1;

  final List<Map<String, dynamic>> sidebarMenus = const [
    {
      'key': 'about',
      'name': 'HOTEL PROFILE',
      'icon': Icons.account_balance_rounded,
    },
    {'key': 'room_type', 'name': 'ROOM TYPE', 'icon': Icons.king_bed_rounded},
    {'key': 'facility', 'name': 'FACILITIES', 'icon': Icons.spa_rounded},
    {
      'key': 'restaurant',
      'name': 'RESTAURANT',
      'icon': Icons.restaurant_rounded,
    },
    {'key': 'promo', 'name': 'PROMO', 'icon': Icons.local_offer_rounded},
    {'key': 'event', 'name': 'EVENT', 'icon': Icons.event_available_rounded},
    {'key': 'policy', 'name': 'POLICY', 'icon': Icons.policy_rounded},
  ];

  double scale(BuildContext context, double value) {
    final w = MediaQuery.of(context).size.width;
    return value * (w / 1920);
  }

  @override
  void initState() {
    super.initState();

    // Ambil data dari halaman sebelumnya (LauncherScreen)
    deviceId = widget.deviceId;
    hotelId = widget.hotelId;
    roomId = widget.roomId;
    hotelName = widget.hotelName;
    guestName = widget.guestName;
    roomNumber = widget.roomNumber;
    backgroundUrl = widget.backgroundUrl;

    print("📦 HotelInfoScreen Loaded:");
    print("→ Guest: $guestName | Room: $roomNumber | BG: $backgroundUrl");

    _initialize();

    // Pastikan fokus diterima sehingga RawKeyboardListener menangkap input remote
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_focusNode.hasFocus) _focusNode.requestFocus();
    });
  }

  Future<void> _initialize() async {
    try {
      // ✅ Gunakan deviceId dari widget, bukan dari lokal
      deviceId = widget.deviceId;

      // Kalau deviceId masih kosong, tampilkan peringatan dan hentikan proses
      if (deviceId == null || deviceId!.isEmpty) {
        print(
          "⚠️ Device ID belum tersedia — tidak bisa ambil config dari server.",
        );
        setState(() {
          errorMessage = "Device ID tidak ditemukan.";
          isLoading = false;
        });
        return;
      }

      print("⚙️ Memuat konfigurasi untuk device: $deviceId");

      // ✅ Ambil konfigurasi langsung dari API (tidak menggunakan cache lokal)
      final config = await api.getDeviceConfigAuto(deviceId!);
      print("📦 Device Config Response: $config");

      // Ambil data config dan isi variabel lokal
      hotelId = config['hotel_id'];
      roomId = config['room_id'];
      hotelName ??= config['hotel_name'];

      // Setelah dapat konfigurasi, ambil konten awal
      await _fetchInitialContent();
      if (!mounted) return;

      // Lanjut koneksi ke MQTT
      await _initializeMqtt();
    } catch (e) {
      if (!mounted) return;
      print("❌ Error saat inisialisasi HotelInfoScreen: $e");
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchInitialContent() async {
    try {
      final data = await api.getContent(deviceId!);
      if (!mounted) return;

      final hotel = data['hotel'] ?? {};
      final contentData = Map<String, List<Map<String, dynamic>>>.from(
        (data['contents'] ?? {}).map(
          (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
        ),
      );

      if (!mounted) return;
      setState(() {
        logoUrl ??= hotel['logo_url'];
        if ((backgroundUrl == null || backgroundUrl!.isEmpty) &&
            (hotel['background_image_url'] != null &&
                hotel['background_image_url'].toString().isNotEmpty)) {
          backgroundUrl = hotel['background_image_url'];
        }

        contents = contentData;
        banners = List<Map<String, dynamic>>.from(data['banners'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      print("❌ Error fetching content: $e");
    }
  }

  Future<void> _initializeMqtt() async {
    if (_isMqttConnected ||
        hotelId == null ||
        roomId == null ||
        deviceId == null)
      return;
    _isMqttConnected = true;

    await MqttManager.instance.connect(
      deviceId: deviceId!,
      hotelId: hotelId!,
      roomId: roomId!,
      onMessage: (payload) async {
        if (!mounted) return;
        final event = payload['event'];

        if (!mounted) return;

        if (event == 'launcher_update') {
          if (!mounted) return;
          setState(() {
            backgroundUrl = payload['background_image_url'] ?? backgroundUrl;
            guestName = payload['guest_name'] ?? guestName;
            roomNumber = payload['room_number'] ?? roomNumber;
          });
        } else if (event == 'content_update') {
          if (!mounted) return;
          final updatedContents = Map<String, List<Map<String, dynamic>>>.from(
            (payload['contents'] ?? {}).map(
              (key, value) =>
                  MapEntry(key, List<Map<String, dynamic>>.from(value)),
            ),
          );

          setState(() {
            contents = updatedContents;
            banners = List<Map<String, dynamic>>.from(payload['banners'] ?? []);
          });
        }
      },
    );
  }

  // -------------------------
  // Remote / keyboard handling
  // -------------------------
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final key = event.logicalKey;

    // Navigasi vertical: panah bawah / atas
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() {
        selectedMenuIndex = (selectedMenuIndex + 1) % sidebarMenus.length;
      });
      _scrollToSelected();
      return;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      setState(() {
        selectedMenuIndex =
            (selectedMenuIndex - 1 + sidebarMenus.length) % sidebarMenus.length;
      });
      _scrollToSelected();
      return;
    }

    // OK / Enter / Select -> nothing fancy, sidebar selection sudah men-trigger content update
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      // Optional: if you want to expand the first content item on Enter for some menus:
      // if (selectedKey == 'room_type' && currentContent.isNotEmpty) { setState(() => _expandedIndex = 0); }
      // For now, we keep Enter as no-op for sidebar (or could focus content)
      // But we keep this handler so device 'OK' doesn't get ignored.
      return;
    }

    // Support some STB key variants by checking debugName
    final debug = key.debugName?.toLowerCase() ?? '';
    if (debug.contains('dpad down')) {
      setState(() {
        selectedMenuIndex = (selectedMenuIndex + 1) % sidebarMenus.length;
      });
      _scrollToSelected();
    } else if (debug.contains('dpad up')) {
      setState(() {
        selectedMenuIndex =
            (selectedMenuIndex - 1 + sidebarMenus.length) % sidebarMenus.length;
      });
      _scrollToSelected();
    }
  }

  // Scroll sidebar so selected item visible
  void _scrollToSelected() {
    // Best-effort estimate of item height (sesuaikan jika perlu)
    final itemExtent = scale(
      context,
      86,
    ); // estimate height per item (margin+padding)
    final target = (selectedMenuIndex) * itemExtent;

    if (!_sidebarController.hasClients) return;

    final max = _sidebarController.position.maxScrollExtent;
    final clamped = target.clamp(0.0, max);

    _sidebarController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A96E)),
        ),
      );
    }

    final selectedKey = sidebarMenus[selectedMenuIndex]['key'];
    final currentContent = contents[selectedKey] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            // 🖼 Background
            if (backgroundUrl != null && backgroundUrl!.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  backgroundUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black),
                ),
              )
            else
              Container(color: Colors.black),

            Container(color: Colors.black.withOpacity(0.35)),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🧭 Sidebar
                Container(
                  width: w * 0.25,
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: scale(context, 10)),
                  child: Column(
                    children: [
                      // ⏰ Jam & tanggal tetap di atas
                      Text(
                        DateFormat('h:mm a').format(DateTime.now()),
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: scale(context, 50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: scale(context, 20),
                        ),
                      ),

                      SizedBox(height: scale(context, 40)),

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              height: constraints.maxHeight,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: h * 0.8,
                                  child: ListView.builder(
                                    controller: _sidebarController,
                                    itemCount: sidebarMenus.length,
                                    itemBuilder: (context, index) {
                                      final isSelected =
                                          selectedMenuIndex == index;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedMenuIndex = index;
                                          });
                                          _scrollToSelected();
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          margin: EdgeInsets.symmetric(
                                            vertical: scale(context, 10),
                                            horizontal: scale(context, 30),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: scale(context, 18),
                                            horizontal: scale(context, 24),
                                          ),
                                          decoration: BoxDecoration(
                                            // Jika selected, beri background lembut + border emas
                                            color: isSelected
                                                ? const Color(
                                                    0xFF2B2B2B,
                                                  ) // subtle dark bg for contrast
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              scale(context, 25),
                                            ),
                                            border: isSelected
                                                ? Border.all(
                                                    color: const Color(
                                                      0xFFC9A96E,
                                                    ),
                                                    width: scale(context, 3),
                                                  )
                                                : null,
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFC9A96E,
                                                      ).withOpacity(0.12),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                sidebarMenus[index]['icon'],
                                                color: isSelected
                                                    ? const Color(0xFFC9A96E)
                                                    : Colors.white70,
                                                size: scale(context, 28),
                                              ),
                                              SizedBox(
                                                width: scale(context, 10),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  sidebarMenus[index]['name'],
                                                  style: GoogleFonts.poppins(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.white70,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: scale(
                                                      context,
                                                      20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 🌆 Main Content
                Expanded(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🔹 Baris atas: logo + guest info di kanan
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: scale(context, 60),
                            vertical: scale(context, 20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 🏨 Logo hotel di kiri
                              if (logoUrl != null)
                                Image.network(
                                  logoUrl!,
                                  height: scale(context, 120),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                )
                              else
                                const SizedBox(),

                              // 🧍 Guest info di kanan
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (guestName != null &&
                                      guestName!.isNotEmpty)
                                    Text(
                                      "Welcome, $guestName",
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: scale(context, 26),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (roomNumber != null &&
                                      roomNumber!.isNotEmpty)
                                    Text(
                                      "Room $roomNumber",
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: scale(context, 26),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ✅ Card utama untuk konten dinamis
                        Container(
                          width: w * 0.7,
                          height: h * 0.8,
                          padding: EdgeInsets.all(scale(context, 35)),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(
                              scale(context, 20),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (selectedKey == 'room_type') ...[
                                  // (tetap seperti semula — card horizontal + detail)
                                  SizedBox(
                                    height: scale(context, 300),
                                    child: ListView.builder(
                                      key: const PageStorageKey(
                                        'room_type_list',
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: currentContent.length,
                                      itemBuilder: (context, index) {
                                        final item = currentContent[index];
                                        final imageUrl =
                                            item['image_url'] ?? '';
                                        final title = item['title'] ?? '';
                                        final isSelected =
                                            _expandedIndex == index;

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _expandedIndex = isSelected
                                                  ? -1
                                                  : index;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: scale(context, 15),
                                              vertical: scale(context, 10),
                                            ),
                                            width: scale(context, 280),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    scale(context, 18),
                                                  ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFFC9A96E)
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                              scale(
                                                                context,
                                                                18,
                                                              ),
                                                            ),
                                                        topRight:
                                                            Radius.circular(
                                                              scale(
                                                                context,
                                                                18,
                                                              ),
                                                            ),
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: double.infinity,
                                                    height: scale(context, 180),
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          height: scale(
                                                            context,
                                                            180,
                                                          ),
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(
                                                    scale(context, 12),
                                                  ),
                                                  child: Text(
                                                    title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.black87,
                                                      fontSize: scale(
                                                        context,
                                                        18,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  if (_expandedIndex != -1 &&
                                      _expandedIndex < currentContent.length)
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      transitionBuilder: (child, anim) =>
                                          FadeTransition(
                                            opacity: anim,
                                            child: child,
                                          ),
                                      child: Container(
                                        key: ValueKey(_expandedIndex),
                                        margin: EdgeInsets.only(
                                          top: scale(context, 30),
                                        ),
                                        padding: EdgeInsets.all(
                                          scale(context, 25),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            scale(context, 25),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            final selected =
                                                currentContent[_expandedIndex];
                                            final imageUrl =
                                                selected['image_url'] ?? '';
                                            final title =
                                                selected['title'] ?? '';
                                            final body = selected['body'] ?? '';

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (imageUrl.isNotEmpty)
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          scale(context, 12),
                                                        ),
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: double.infinity,
                                                      height: scale(
                                                        context,
                                                        350,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                SizedBox(
                                                  height: scale(context, 20),
                                                ),
                                                Text(
                                                  title,
                                                  style:
                                                      GoogleFonts.playfairDisplay(
                                                        color: const Color(
                                                          0xFFC9A96E,
                                                        ),
                                                        fontSize: scale(
                                                          context,
                                                          32,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                SizedBox(
                                                  height: scale(context, 10),
                                                ),
                                                Text(
                                                  body,
                                                  textAlign: TextAlign.justify,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black87,
                                                    fontSize: scale(
                                                      context,
                                                      18,
                                                    ),
                                                    height: 1.6,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ] else ...[
                                  // other menus: keep original rendering (unchanged)
                                  ...currentContent.map((item) {
                                    final key = selectedKey;
                                    final imageUrl = item['image_url'] ?? '';
                                    final title = item['title'] ?? '';
                                    final body = item['body'] ?? '';
                                    final extra = item['extra_data'] ?? {};
                                    Widget contentWidget;

                                    switch (key) {
                                      case 'about':
                                        contentWidget = Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (imageUrl.isNotEmpty)
                                              Expanded(
                                                flex: 1,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        scale(context, 12),
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    height: scale(context, 250),
                                                  ),
                                                ),
                                              ),
                                            SizedBox(width: scale(context, 30)),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style:
                                                        GoogleFonts.playfairDisplay(
                                                          color: const Color(
                                                            0xFFC9A96E,
                                                          ),
                                                          fontSize: scale(
                                                            context,
                                                            32,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  SizedBox(
                                                    height: scale(context, 10),
                                                  ),
                                                  Text(
                                                    body,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: scale(
                                                        context,
                                                        20,
                                                      ),
                                                      height: 1.6,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                        break;
                                      case 'facility':
                                        contentWidget = Container(
                                          margin: EdgeInsets.only(
                                            bottom: scale(context, 25),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (imageUrl.isNotEmpty)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        scale(context, 12),
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: scale(context, 250),
                                                    height: scale(context, 180),
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          width: scale(
                                                            context,
                                                            250,
                                                          ),
                                                          height: scale(
                                                            context,
                                                            180,
                                                          ),
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              SizedBox(
                                                width: scale(context, 25),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      title,
                                                      style:
                                                          GoogleFonts.playfairDisplay(
                                                            color: const Color(
                                                              0xFFC9A96E,
                                                            ),
                                                            fontSize: scale(
                                                              context,
                                                              28,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      height: scale(context, 8),
                                                    ),
                                                    Text(
                                                      body,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.white,
                                                            fontSize: scale(
                                                              context,
                                                              18,
                                                            ),
                                                            height: 1.5,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        break;
                                      case 'restaurant':
                                        contentWidget = Container(
                                          margin: EdgeInsets.only(
                                            bottom: scale(context, 25),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (imageUrl.isNotEmpty)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        scale(context, 12),
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: scale(context, 160),
                                                    height: scale(context, 160),
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          _,
                                                          __,
                                                          ___,
                                                        ) => Container(
                                                          width: scale(
                                                            context,
                                                            160,
                                                          ),
                                                          height: scale(
                                                            context,
                                                            160,
                                                          ),
                                                          color: Colors
                                                              .grey
                                                              .shade300,
                                                          child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              SizedBox(
                                                width: scale(context, 25),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      extra['menu_name'] ??
                                                          title,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.white,
                                                            fontSize: scale(
                                                              context,
                                                              22,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      height: scale(context, 6),
                                                    ),
                                                    Text(
                                                      body,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: scale(
                                                              context,
                                                              18,
                                                            ),
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      height: scale(context, 6),
                                                    ),
                                                    if (extra['menu_price'] !=
                                                        null)
                                                      Text(
                                                        "Rp ${extra['menu_price']}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  const Color(
                                                                    0xFFC9A96E,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: scale(
                                                                context,
                                                                22,
                                                              ),
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        break;
                                      case 'promo':
                                        contentWidget = Container(
                                          margin: EdgeInsets.only(
                                            bottom: scale(context, 25),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (imageUrl.isNotEmpty)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        scale(context, 12),
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: double.infinity,
                                                    height: scale(context, 280),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              SizedBox(
                                                height: scale(context, 15),
                                              ),
                                              Text(
                                                title,
                                                style:
                                                    GoogleFonts.playfairDisplay(
                                                      color: const Color(
                                                        0xFFC9A96E,
                                                      ),
                                                      fontSize: scale(
                                                        context,
                                                        28,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              SizedBox(
                                                height: scale(context, 10),
                                              ),
                                              Text(
                                                body,
                                                textAlign: TextAlign.justify,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: scale(context, 18),
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        break;
                                      case 'event':
                                        contentWidget = Container(
                                          margin: EdgeInsets.only(
                                            bottom: scale(context, 25),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (imageUrl.isNotEmpty)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        scale(context, 12),
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: w * 0.8,
                                                    height: scale(context, 400),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              SizedBox(
                                                height: scale(context, 15),
                                              ),
                                              Text(
                                                title,
                                                style:
                                                    GoogleFonts.playfairDisplay(
                                                      color: const Color(
                                                        0xFFC9A96E,
                                                      ),
                                                      fontSize: scale(
                                                        context,
                                                        28,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              SizedBox(
                                                height: scale(context, 10),
                                              ),
                                              Text(
                                                body,
                                                textAlign: TextAlign.justify,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: scale(context, 18),
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        break;
                                      case 'policy':
                                        contentWidget = Container(
                                          margin: EdgeInsets.only(
                                            bottom: scale(context, 25),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (imageUrl.isNotEmpty)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        scale(context, 12),
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: double.infinity,
                                                    height: scale(context, 280),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              SizedBox(
                                                height: scale(context, 15),
                                              ),
                                              Text(
                                                title,
                                                style:
                                                    GoogleFonts.playfairDisplay(
                                                      color: const Color(
                                                        0xFFC9A96E,
                                                      ),
                                                      fontSize: scale(
                                                        context,
                                                        28,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              SizedBox(
                                                height: scale(context, 10),
                                              ),
                                              Text(
                                                body,
                                                textAlign: TextAlign.justify,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: scale(context, 18),
                                                  height: 1.5,
                                                ),
                                              ),
                                              if (extra['checkin_time'] != null)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top: scale(context, 8),
                                                  ),
                                                  child: Text(
                                                    "Check-in: ${extra['checkin_time']} | Check-out: ${extra['checkout_time']}",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white70,
                                                      fontSize: scale(
                                                        context,
                                                        16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                        break;
                                      default:
                                        contentWidget = Text(body);
                                    }
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: scale(context, 30),
                                      ),
                                      child: contentWidget,
                                    );
                                  }),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _sidebarController.dispose();
    MqttManager.instance.disconnect();
    super.dispose();
  }
}
