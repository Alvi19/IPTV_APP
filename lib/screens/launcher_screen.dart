import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/clock_widget.dart';
import 'hotel_info_screen.dart';
import '../services/api_service.dart';
import '../services/mqtt_manager.dart';

class LauncherScreen extends StatefulWidget {
  final int? hotelId;
  final int? roomId;
  final String? deviceId;
  final String? hotelName;
  final String? roomNumber;
  final String? guestName;
  final String? backgroundUrl;

  const LauncherScreen({
    super.key,
    this.hotelId,
    this.roomId,
    this.deviceId,
    this.hotelName,
    this.roomNumber,
    this.guestName,
    this.backgroundUrl,
  });

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  final ApiService api = ApiService();

  int selectedIndex = -1;
  String? backgroundUrl;
  String? hotelName;
  String? roomNumber;
  String? guestName;
  String? deviceId;
  int? hotelId;
  int? roomId;
  bool _isMqttConnected = false;

  String? textRunning; // 🆕 Tambahan: text berjalan dari API/MQTT

  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.apartment, 'label': 'Hotel Info'},
    {'icon': Icons.tv, 'label': 'TV'},
    {'icon': Icons.music_note, 'label': 'Cubmu'},
    {'icon': Icons.restaurant, 'label': 'Restaurant'},
    {'icon': Icons.wifi, 'label': 'Wifi'},
    {'icon': Icons.play_circle_fill, 'label': 'Youtube'},
    {'icon': Icons.child_care, 'label': 'Youtube Kids'},
    {'icon': Icons.movie, 'label': 'Netflix'},
    {'icon': Icons.video_collection, 'label': 'Vidio.com'},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeData();
  }

  /// 🔹 Ambil data awal
  Future<void> _initializeData() async {
    try {
      deviceId = widget.deviceId;
      hotelId = widget.hotelId;
      roomId = widget.roomId;
      hotelName = widget.hotelName ?? hotelName;
      roomNumber = widget.roomNumber ?? roomNumber;
      guestName = widget.guestName ?? guestName;
      backgroundUrl = widget.backgroundUrl ?? backgroundUrl;

      if (deviceId == null) {
        final config = await api.getDeviceConfigAuto();
        deviceId = config['device_id'];
      }

      final launcherData = await api.getLauncherData(deviceId!);
      final hotel = launcherData['hotel'] ?? {};
      final room = launcherData['room'] ?? {};

      setState(() {
        hotelName ??= hotel['name'] ?? "Your Hotel";
        roomNumber ??= room['number']?.toString() ?? "-";
        guestName ??= room['guest_name'];
        hotelId ??= hotel['id'];
        roomId ??= room['id'];
        backgroundUrl ??= hotel['background_image_url'] ?? '';
        textRunning = hotel['text_running']; // 🆕 ambil text_running dari API
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) print("🧩 Guest name stabilized: $guestName");
      });

      print("✅ Launcher init: Guest=$guestName Room=$roomNumber");

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _initializeMqtt();
      });
    } catch (e) {
      print("❌ Error init data: $e");
    }
  }

  /// 🔹 MQTT listener
  Future<void> _initializeMqtt() async {
    if (_isMqttConnected ||
        deviceId == null ||
        hotelId == null ||
        roomId == null)
      return;

    _isMqttConnected = true;

    print("🚀 MQTT Connecting → hotel/$hotelId/room/$roomId");

    await MqttManager.instance.connect(
      deviceId: deviceId!,
      hotelId: hotelId!,
      roomId: roomId!,
      onMessage: (data) async {
        final event = data['event'];
        print("⚡ MQTT Event (Launcher): $event | Data: $data");

        if (!mounted) return;

        setState(() {
          if (event == 'checkin' || event == 'launcher_update') {
            if (data['guest_name'] != null &&
                data['guest_name'].toString().isNotEmpty) {
              guestName = data['guest_name'];
            }

            if (data['room_number'] != null &&
                data['room_number'].toString().isNotEmpty) {
              roomNumber = data['room_number'].toString();
            }

            final newBg = data['background_image_url'];
            if (newBg != null && newBg.toString().isNotEmpty) {
              backgroundUrl = newBg;
            }

            // 🆕 Update text running jika ada
            if (data['text_running'] != null &&
                data['text_running'].toString().isNotEmpty) {
              textRunning = data['text_running'];
              print("💬 Running text updated → $textRunning");
            }
          } else if (event == 'checkout') {
            guestName = null;
          }
        });
      },
    );
  }

  @override
  void dispose() {
    MqttManager.instance.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final base = (width + height) / 200;

          final iconSize = base * 3.2;
          final fontSize = base * 1.0;
          final barHeight = base * 8.5;
          final padding = base * 2.0;

          final now = DateTime.now();
          final formattedDate = DateFormat(
            'EEEE, d MMMM yyyy',
            'en_US',
          ).format(now);

          final bool isGuestCheckedIn =
              guestName != null && guestName!.isNotEmpty;
          final String welcomeText = isGuestCheckedIn
              ? "Welcome $guestName"
              : "Welcome to ${hotelName ?? 'Your Hotel'}";

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: (backgroundUrl != null && backgroundUrl!.isNotEmpty)
                      ? Image.network(
                          backgroundUrl!,
                          key: ValueKey(backgroundUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.black),
                        )
                      : Container(color: Colors.black),
                ),

                Container(color: Colors.black.withOpacity(0.35)),

                /// 🕒 Header
                Positioned(
                  top: base,
                  left: base * 3.5,
                  right: base * 3.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const ClockWidget(),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Room ${roomNumber ?? '-'}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: base * 2.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: base * 0.5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: base * 2.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// 💬 Welcome
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: padding * 2),
                    padding: EdgeInsets.symmetric(
                      vertical: base * 1.5,
                      horizontal: base * 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(base),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        welcomeText,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: base * 2.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),

                /// 📱 Bottom menu + 🆕 running text
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 📦 Bar menu
                      Container(
                        height: barHeight,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: base * 2.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(menuItems.length, (index) {
                              final item = menuItems[index];
                              final isSelected = selectedIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  if (item['label'] == 'Hotel Info') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HotelInfoScreen(
                                          hotelId: hotelId,
                                          roomId: roomId,
                                          deviceId: deviceId,
                                          hotelName: hotelName,
                                          guestName: guestName,
                                          roomNumber: roomNumber,
                                          backgroundUrl: backgroundUrl,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => selectedIndex = index),
                                  onExit: (_) =>
                                      setState(() => selectedIndex = -1),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedScale(
                                        scale: isSelected ? 1.15 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        child: Icon(
                                          item['icon'],
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white70,
                                          size: iconSize,
                                        ),
                                      ),
                                      SizedBox(height: base * 0.6),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        style: GoogleFonts.poppins(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: fontSize,
                                        ),
                                        child: Text(item['label']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      // 🆕 Running text berjalan otomatis
                      if (textRunning != null && textRunning!.isNotEmpty)
                        _RunningTextBar(
                          text: textRunning!,
                          fontSize: base * 1.6,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 🎬 Widget untuk text berjalan otomatis (running text)
class _RunningTextBar extends StatefulWidget {
  final String text;
  final double fontSize;

  const _RunningTextBar({required this.text, this.fontSize = 16});

  @override
  State<_RunningTextBar> createState() => _RunningTextBarState();
}

class _RunningTextBarState extends State<_RunningTextBar> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    const double scrollSpeed = 50; // pixel per second
    const Duration frameRate = Duration(milliseconds: 30);

    double position = 0;
    _timer = Timer.periodic(frameRate, (timer) {
      if (!_scrollController.hasClients) return;

      position += scrollSpeed * frameRate.inMilliseconds / 1000;
      if (position >= _scrollController.position.maxScrollExtent + 40) {
        // Reset ke awal untuk efek loop
        position = 0;
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(position);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(vertical: 6),
      height: widget.fontSize * 2.5,
      width: double.infinity,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SizedBox(width: 40),
          Text(
            widget.text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: widget.fontSize,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 80),
          // Tambah teks kedua biar efek looping mulus
          Text(
            widget.text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: widget.fontSize,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
