// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import '../services/api_service.dart';
// import 'dart:async' show Future, unawaited;
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

//   bool _isMqttConnected = false;
//   bool _isLoadingContent = false;
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
//     {'key': 'around_us', 'name': 'AROUND US', 'icon': Icons.place_rounded},
//     {
//       'key': 'restaurant',
//       'name': 'RESTAURANT',
//       'icon': Icons.restaurant_rounded,
//     },
//     {'key': 'promo', 'name': 'PROMO', 'icon': Icons.local_offer_rounded},
//     {'key': 'event', 'name': 'EVENT', 'icon': Icons.event_rounded},
//     {'key': 'policy', 'name': 'POLICY', 'icon': Icons.policy_rounded},
//   ];

//   double scale(BuildContext context, double value) {
//     final w = MediaQuery.of(context).size.width;
//     return value * (w / 1920);
//   }

//   @override
//   void initState() {
//     super.initState();

//     deviceId = widget.deviceId;
//     hotelId = widget.hotelId;
//     roomId = widget.roomId;
//     hotelName = widget.hotelName;
//     guestName = widget.guestName;
//     roomNumber = widget.roomNumber;
//     backgroundUrl = widget.backgroundUrl;

//     print("⚡ Fast load start for hotel: $hotelName | device=$deviceId");
//     _loadContentFast();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_focusNode.hasFocus) _focusNode.requestFocus();
//     });
//   }

//   /// ✅ Versi cepat: hanya ambil data konten, tampilkan UI segera
//   Future<void> _loadContentFast() async {
//     if (_isLoadingContent) return;
//     _isLoadingContent = true;
//     try {
//       if (deviceId == null || deviceId!.isEmpty) {
//         errorMessage = "⚠️ Device ID tidak ditemukan.";
//         return;
//       }

//       final data = await api
//           .getContent(deviceId!)
//           .timeout(const Duration(seconds: 6));
//       final hotel = data['hotel'] ?? {};
//       final contentData = Map<String, List<Map<String, dynamic>>>.from(
//         (data['contents'] ?? {}).map(
//           (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
//         ),
//       );

//       if (!mounted) return;
//       setState(() {
//         logoUrl = hotel['logo_url'];
//         backgroundUrl = hotel['background_image_url'] ?? backgroundUrl;
//         contents = contentData;
//         banners = List<Map<String, dynamic>>.from(data['banners'] ?? []);
//       });

//       if (backgroundUrl != null && backgroundUrl!.isNotEmpty) {
//         unawaited(precacheImage(NetworkImage(backgroundUrl!), context));
//       }
//       unawaited(_initMqttRealtime());
//     } catch (e) {
//       print("❌ Load content failed: $e");
//       if (!mounted) return;
//       setState(() => errorMessage = e.toString());
//     } finally {
//       _isLoadingContent = false;
//     }
//   }

//   Future<void> _initMqttRealtime() async {
//     if (_isMqttConnected ||
//         deviceId == null ||
//         hotelId == null ||
//         roomId == null)
//       return;
//     _isMqttConnected = true;
//     print("📡 MQTT connecting...");
//     await MqttManager.instance.connect(
//       deviceId: deviceId!,
//       hotelId: hotelId!,
//       roomId: roomId!,
//       onMessage: (payload) {
//         final event = payload['event'];
//         if (event == 'content_update') {
//           final updated = Map<String, List<Map<String, dynamic>>>.from(
//             (payload['contents'] ?? {}).map(
//               (key, value) =>
//                   MapEntry(key, List<Map<String, dynamic>>.from(value)),
//             ),
//           );
//           if (mounted) {
//             setState(() {
//               contents = updated;
//               banners = List<Map<String, dynamic>>.from(
//                 payload['banners'] ?? [],
//               );
//             });
//           }
//         }
//       },
//     );
//   }

//   String focusSection = 'sidebar';
//   int selectedContentIndex = 0;

//   void _handleKeyEvent(RawKeyEvent event) {
//     if (event is! RawKeyDownEvent) return;
//     final key = event.logicalKey;
//     final selectedKey = sidebarMenus[selectedMenuIndex]['key'];
//     final currentContent = contents[selectedKey] ?? [];

//     if (focusSection == 'sidebar') {
//       if (key == LogicalKeyboardKey.arrowDown) {
//         setState(
//           () =>
//               selectedMenuIndex = (selectedMenuIndex + 1) % sidebarMenus.length,
//         );
//       } else if (key == LogicalKeyboardKey.arrowUp) {
//         setState(
//           () => selectedMenuIndex =
//               (selectedMenuIndex - 1 + sidebarMenus.length) %
//               sidebarMenus.length,
//         );
//       } else if (key == LogicalKeyboardKey.arrowRight &&
//           currentContent.isNotEmpty) {
//         setState(() {
//           focusSection = 'content';
//           selectedContentIndex = 0;
//         });
//       }
//     } else if (focusSection == 'content') {
//       if (key == LogicalKeyboardKey.arrowDown) {
//         setState(
//           () => selectedContentIndex =
//               (selectedContentIndex + 1) % currentContent.length,
//         );
//       } else if (key == LogicalKeyboardKey.arrowUp) {
//         setState(
//           () => selectedContentIndex =
//               (selectedContentIndex - 1 + currentContent.length) %
//               currentContent.length,
//         );
//       } else if (key == LogicalKeyboardKey.arrowLeft) {
//         setState(() => focusSection = 'sidebar');
//       } else if (key == LogicalKeyboardKey.enter) {
//         setState(() => _expandedIndex = selectedContentIndex);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;
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
//             if (backgroundUrl != null && backgroundUrl!.isNotEmpty)
//               Positioned.fill(
//                 child: Image.network(
//                   backgroundUrl!,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => Container(color: Colors.black),
//                 ),
//               ),
//             Container(color: Colors.black.withOpacity(0.35)),

//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Sidebar kiri (TETAP)
//                 Container(
//                   width: w * 0.25,
//                   padding: EdgeInsets.symmetric(vertical: scale(context, 10)),
//                   child: Column(
//                     children: [
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
//                       SizedBox(height: scale(context, 40)),
//                       Expanded(
//                         child: ListView.builder(
//                           controller: _sidebarController,
//                           itemCount: sidebarMenus.length,
//                           itemBuilder: (context, index) {
//                             final isSelected = selectedMenuIndex == index;
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedMenuIndex = index;
//                                   focusSection =
//                                       'content'; // otomatis pindah fokus ke konten
//                                   selectedContentIndex = 0;
//                                 });
//                               },
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 margin: EdgeInsets.symmetric(
//                                   vertical: scale(context, 10),
//                                   horizontal: scale(context, 30),
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: scale(context, 18),
//                                   horizontal: scale(context, 24),
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: isSelected
//                                       ? const Color(0xFF2B2B2B)
//                                       : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(
//                                     scale(context, 25),
//                                   ),
//                                   border: isSelected
//                                       ? Border.all(
//                                           color: const Color(0xFFC9A96E),
//                                           width: scale(context, 3),
//                                         )
//                                       : null,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       sidebarMenus[index]['icon'],
//                                       color: isSelected
//                                           ? const Color(0xFFC9A96E)
//                                           : Colors.white70,
//                                       size: scale(context, 28),
//                                     ),
//                                     SizedBox(width: scale(context, 10)),
//                                     Flexible(
//                                       child: Text(
//                                         sidebarMenus[index]['name'],
//                                         style: GoogleFonts.poppins(
//                                           color: isSelected
//                                               ? Colors.white
//                                               : Colors.white70,
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: scale(context, 20),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Konten kanan (TETAP UI-nya)
//                 Expanded(
//                   child: Center(
//                     child: Column(
//                       children: [
//                         // Header
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: scale(context, 60),
//                             vertical: scale(context, 20),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               if (logoUrl != null)
//                                 Image.network(
//                                   logoUrl!,
//                                   height: scale(context, 120),
//                                   fit: BoxFit.contain,
//                                 ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   if (guestName != null)
//                                     Text(
//                                       "Welcome, $guestName",
//                                       style: GoogleFonts.poppins(
//                                         color: Colors.white,
//                                         fontSize: scale(context, 26),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   if (roomNumber != null)
//                                     Text(
//                                       "Room $roomNumber",
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

//                         // Konten utama
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
//                           child: Row(
//                             children: [
//                               /// 🧭 Kolom kiri: daftar konten
//                               Expanded(
//                                 flex: 2,
//                                 child: currentContent.isEmpty
//                                     ? Center(
//                                         child: Text(
//                                           _isLoadingContent
//                                               ? "Loading content..."
//                                               : "Tidak ada data untuk kategori ini.",
//                                           style: GoogleFonts.poppins(
//                                             color: Colors.white70,
//                                             fontSize: 20,
//                                           ),
//                                         ),
//                                       )
//                                     : ListView.builder(
//                                         itemCount: currentContent.length,
//                                         itemBuilder: (context, index) {
//                                           final item = currentContent[index];
//                                           final image = item['image_url'] ?? '';
//                                           final title = item['title'] ?? '';
//                                           final body = item['body'] ?? '';
//                                           final isSelected =
//                                               _expandedIndex == index;

//                                           return GestureDetector(
//                                             onTap: () {
//                                               setState(() {
//                                                 _expandedIndex = isSelected
//                                                     ? -1
//                                                     : index;
//                                               });
//                                             },
//                                             child: AnimatedContainer(
//                                               duration: const Duration(
//                                                 milliseconds: 300,
//                                               ),
//                                               margin: EdgeInsets.only(
//                                                 bottom: scale(context, 20),
//                                               ),
//                                               padding: EdgeInsets.all(
//                                                 scale(context, 16),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: isSelected
//                                                     ? Colors.black.withOpacity(
//                                                         0.55,
//                                                       )
//                                                     : Colors.black.withOpacity(
//                                                         0.3,
//                                                       ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                       scale(context, 15),
//                                                     ),
//                                                 border: Border.all(
//                                                   color: isSelected
//                                                       ? const Color(0xFFC9A96E)
//                                                       : Colors.transparent,
//                                                   width: 2,
//                                                 ),
//                                               ),
//                                               child: Row(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   if (image.isNotEmpty)
//                                                     ClipRRect(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             scale(context, 5),
//                                                           ),
//                                                       child: Image.network(
//                                                         image,
//                                                         width: scale(
//                                                           context,
//                                                           320,
//                                                         ),
//                                                         height: scale(
//                                                           context,
//                                                           180,
//                                                         ),
//                                                         fit: BoxFit.cover,
//                                                       ),
//                                                     ),
//                                                   SizedBox(
//                                                     width: scale(context, 15),
//                                                   ),
//                                                   Expanded(
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Text(
//                                                           title,
//                                                           style:
//                                                               GoogleFonts.playfairDisplay(
//                                                                 color:
//                                                                     const Color(
//                                                                       0xFFC9A96E,
//                                                                     ),
//                                                                 fontSize: scale(
//                                                                   context,
//                                                                   35,
//                                                                 ),
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                               ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: scale(
//                                                             context,
//                                                             25,
//                                                           ),
//                                                         ),
//                                                         Text(
//                                                           body,
//                                                           maxLines: 2,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           style:
//                                                               GoogleFonts.poppins(
//                                                                 color: Colors
//                                                                     .white70,
//                                                                 fontSize: scale(
//                                                                   context,
//                                                                   16,
//                                                                 ),
//                                                               ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                               ),

//                               SizedBox(width: scale(context, 25)),

//                               /// 📜 Kolom kanan: panel detail
//                               Expanded(
//                                 flex: 3,
//                                 child: AnimatedSwitcher(
//                                   duration: const Duration(milliseconds: 400),
//                                   transitionBuilder: (child, animation) =>
//                                       FadeTransition(
//                                         opacity: animation,
//                                         child: child,
//                                       ),
//                                   child: _expandedIndex == -1
//                                       ? Center(
//                                           key: const ValueKey('placeholder'),
//                                           child: Text(
//                                             "Pilih salah satu item di kiri untuk melihat detail.",
//                                             style: GoogleFonts.poppins(
//                                               color: Colors.white54,
//                                               fontSize: scale(context, 20),
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         )
//                                       : _buildDetailPanel(
//                                           currentContent[_expandedIndex],
//                                         ),
//                                 ),
//                               ),
//                             ],
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

//   Widget _buildDetailPanel(Map<String, dynamic> item) {
//     final image = item['image_url'] ?? '';
//     final title = item['title'] ?? '';
//     final detail = item['detail'] ?? '';
//     final body = item['body'] ?? '';

//     return Container(
//       key: const ValueKey('detail'),
//       padding: EdgeInsets.all(scale(context, 25)),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.4),
//         borderRadius: BorderRadius.circular(scale(context, 15)),
//         border: Border.all(color: const Color(0xFFC9A96E), width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header judul dan gambar
//           if (image.isNotEmpty)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(scale(context, 10)),
//               child: Image.network(
//                 image,
//                 width: double.infinity,
//                 height: scale(context, 200),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           SizedBox(height: scale(context, 20)),
//           Text(
//             title,
//             style: GoogleFonts.playfairDisplay(
//               color: const Color(0xFFC9A96E),
//               fontSize: scale(context, 28),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: scale(context, 10)),
//           Expanded(
//             child: Scrollbar(
//               thumbVisibility: true,
//               radius: const Radius.circular(12),
//               thickness: 6,
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.only(right: scale(context, 15)),
//                 child: Text(
//                   (detail.isNotEmpty ? detail : body).toString(),
//                   style: GoogleFonts.poppins(
//                     color: Colors.white70,
//                     fontSize: scale(context, 18),
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final FocusNode _focusNode = FocusNode();

  bool _isLoadingContent = false;
  String? backgroundUrl, logoUrl, guestName, roomNumber, deviceId;
  int? hotelId, roomId;

  Map<String, List<Map<String, dynamic>>> contents = {};
  int selectedMenuIndex = 0;
  int _expandedIndex = -1;

  final List<Map<String, dynamic>> navMenus = const [
    {'key': 'about', 'name': 'HOTEL PROFILE'},
    {'key': 'room_type', 'name': 'ROOM TYPE'},
    {'key': 'facility', 'name': 'FACILITIES'},
    {'key': 'around_us', 'name': 'AROUND US'},
    {'key': 'restaurant', 'name': 'RESTAURANT'},
    {'key': 'promo', 'name': 'PROMO'},
    {'key': 'event', 'name': 'EVENT'},
    {'key': 'policy', 'name': 'POLICY'},
  ];

  double scale(BuildContext context, double value) {
    final w = MediaQuery.of(context).size.width;
    return value * (w / 1920);
  }

  @override
  void initState() {
    super.initState();
    backgroundUrl = widget.backgroundUrl;
    deviceId = widget.deviceId;
    hotelId = widget.hotelId;
    roomId = widget.roomId;
    guestName = widget.guestName;
    roomNumber = widget.roomNumber;

    _loadContentFast();
  }

  Future<void> _loadContentFast() async {
    if (_isLoadingContent) return;
    _isLoadingContent = true;
    try {
      final data = await api.getContent(deviceId ?? '');
      final hotel = data['hotel'] ?? {};
      final contentData = Map<String, List<Map<String, dynamic>>>.from(
        (data['contents'] ?? {}).map(
          (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
        ),
      );

      if (!mounted) return;
      setState(() {
        logoUrl = hotel['logo_url'];
        backgroundUrl = hotel['background_image_url'] ?? backgroundUrl;
        contents = contentData;
      });
    } catch (e) {
      debugPrint("❌ Load failed: $e");
    } finally {
      _isLoadingContent = false;
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    final key = event.logicalKey;
    final currentMenu = navMenus[selectedMenuIndex]['key'];
    final currentContent = contents[currentMenu] ?? [];

    if (key == LogicalKeyboardKey.arrowRight) {
      setState(() {
        selectedMenuIndex = (selectedMenuIndex + 1) % navMenus.length;
        _expandedIndex = -1;
      });
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      setState(() {
        selectedMenuIndex =
            (selectedMenuIndex - 1 + navMenus.length) % navMenus.length;
        _expandedIndex = -1;
      });
    } else if (key == LogicalKeyboardKey.arrowDown &&
        currentContent.isNotEmpty) {
      setState(() {
        _expandedIndex = (_expandedIndex + 1) % currentContent.length;
      });
    } else if (key == LogicalKeyboardKey.arrowUp && currentContent.isNotEmpty) {
      setState(() {
        _expandedIndex =
            (_expandedIndex - 1 + currentContent.length) %
            currentContent.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final currentKey = navMenus[selectedMenuIndex]['key'];
    final currentContent = contents[currentKey] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: _handleKeyEvent,
        child: Stack(
          children: [
            if (backgroundUrl != null)
              Positioned.fill(
                child: Image.network(backgroundUrl!, fit: BoxFit.cover),
              ),
            Container(color: Colors.black.withOpacity(0.45)),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: scale(context, 50),
                  vertical: scale(context, 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kiri: Jam dan tanggal
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(DateTime.now()),
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: scale(context, 40),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'EEE, d MMM yyyy',
                              ).format(DateTime.now()),
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: scale(context, 18),
                              ),
                            ),
                          ],
                        ),

                        // Tengah: Logo
                        if (logoUrl != null)
                          Image.network(
                            logoUrl!,
                            height: scale(context, 10),
                            fit: BoxFit.contain,
                          ),

                        // Kanan: Nomor Kamar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (guestName != null)
                              Text(
                                "Welcome, $guestName",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: scale(context, 26),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (roomNumber != null)
                              Text(
                                "Room $roomNumber",
                                style: GoogleFonts.poppins(
                                  color: Colors.amber,
                                  fontSize: scale(context, 22),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: scale(context, 30)),

                    /// Navbar scrollable
                    SizedBox(
                      height: scale(context, 60),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: navMenus.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: scale(context, 25)),
                        itemBuilder: (context, i) {
                          final menu = navMenus[i];
                          final isSelected = i == selectedMenuIndex;
                          return GestureDetector(
                            onTap: () => setState(() {
                              selectedMenuIndex = i;
                              _expandedIndex = -1;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.symmetric(
                                horizontal: scale(context, 25),
                                vertical: scale(context, 10),
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFFC9A96E)
                                        : Colors.transparent,
                                    width: scale(context, 4),
                                  ),
                                ),
                              ),
                              child: Text(
                                menu['name'],
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? const Color(0xFFC9A96E)
                                      : Colors.white70,
                                  fontSize: scale(context, 22),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: scale(context, 30)),

                    /// Content Card (2 columns)
                    Expanded(
                      child: Container(
                        width: w * 0.9,
                        padding: EdgeInsets.all(scale(context, 35)),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(
                            scale(context, 20),
                          ),
                          border: Border.all(
                            color: const Color(0xFFC9A96E),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            /// Left Column: List
                            Expanded(
                              flex: 2,
                              child: currentContent.isEmpty
                                  ? Center(
                                      child: Text(
                                        _isLoadingContent
                                            ? "Loading content..."
                                            : "No data available.",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: scale(context, 20),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: currentContent.length,
                                      itemBuilder: (context, index) {
                                        final item = currentContent[index];
                                        final title = item['title'] ?? '';
                                        final image = item['image_url'] ?? '';
                                        final body = item['body'] ?? '';
                                        final isSelected =
                                            _expandedIndex == index;

                                        // Check if the item is a restaurant
                                        final extraData = item['extra_data'];
                                        final menuName =
                                            extraData?['menu_name'];
                                        final menuPrice =
                                            extraData?['menu_price'];

                                        return GestureDetector(
                                          onTap: () {
                                            setState(
                                              () => _expandedIndex = index,
                                            );
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            margin: EdgeInsets.only(
                                              bottom: scale(context, 20),
                                            ),
                                            padding: EdgeInsets.all(
                                              scale(context, 16),
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.black.withOpacity(
                                                      0.6,
                                                    )
                                                  : Colors.black.withOpacity(
                                                      0.3,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    scale(context, 15),
                                                  ),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFFC9A96E)
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),

                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (image.isNotEmpty)
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Image.network(
                                                      image,
                                                      width: scale(
                                                        context,
                                                        180,
                                                      ),
                                                      height: scale(
                                                        context,
                                                        100,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                SizedBox(
                                                  width: scale(context, 15),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        title,
                                                        style:
                                                            GoogleFonts.playfairDisplay(
                                                              color:
                                                                  const Color(
                                                                    0xFFC9A96E,
                                                                  ),
                                                              fontSize: scale(
                                                                context,
                                                                26,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      SizedBox(
                                                        height: scale(
                                                          context,
                                                          8,
                                                        ),
                                                      ),
                                                      Text(
                                                        body,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: scale(
                                                                context,
                                                                16,
                                                              ),
                                                            ),
                                                      ),
                                                      // Display restaurant menu name and price if available
                                                      if (menuName != null &&
                                                          menuPrice != null)
                                                        Text(
                                                          '$menuName - \$${menuPrice}',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color: Colors
                                                                    .amber,
                                                                fontSize: scale(
                                                                  context,
                                                                  18,
                                                                ),
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            SizedBox(width: scale(context, 25)),

                            /// Right Column: Detail
                            Expanded(
                              flex: 3,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: _expandedIndex == -1
                                    ? Center(
                                        key: const ValueKey('empty'),
                                        child: Text(
                                          "Select an item to view details.",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white54,
                                            fontSize: scale(context, 20),
                                          ),
                                        ),
                                      )
                                    : _buildDetailPanel(
                                        currentContent[_expandedIndex],
                                      ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildDetailPanel(Map<String, dynamic> item) {
    final image = item['image_url'] ?? '';
    final title = item['title'] ?? '';
    final detail = item['detail'] ?? '';
    final body = item['body'] ?? '';

    return Container(
      key: const ValueKey('detail'),
      padding: EdgeInsets.all(scale(context, 25)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(scale(context, 15)),
        border: Border.all(color: const Color(0xFFC9A96E), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(scale(context, 10)),
              child: Image.network(
                image,
                width: double.infinity,
                height: scale(context, 200),
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: scale(context, 15)),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFC9A96E),
              fontSize: scale(context, 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: scale(context, 10)),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                (detail.isNotEmpty ? detail : body).toString(),
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: scale(context, 18),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
