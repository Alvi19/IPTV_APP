import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
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
    {'icon': Icons.play_circle_fill, 'label': 'Youtube'},
    {'icon': Icons.child_care, 'label': 'Youtube Kids'},
    {'icon': Icons.movie, 'label': 'Netflix'},
    {'icon': Icons.video_library, 'label': 'Vidio'},
    {'icon': Icons.movie_creation, 'label': 'Disney+'},
    {'icon': Icons.live_tv, 'label': 'Prime Video'},
    {'icon': Icons.music_note, 'label': 'Spotify'},
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    FocusManager.instance.primaryFocus?.unfocus();
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

      // 🔧 Jika deviceId kosong → hentikan atau tampilkan log
      if (deviceId == null || deviceId!.isEmpty) {
        print("⚠️ Device ID belum diisi. Tidak bisa ambil config.");
        return;
      }

      // 🔹 Ambil konfigurasi berdasarkan deviceId
      final config = await api.getDeviceConfigAuto(deviceId!);
      print("⚙️ Config fetched: $config");

      final launcherData = await api.getLauncherData(deviceId!);
      if (!mounted) return;
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

  /// 🔹 MQTT listener (revisi: ignore video_update, only apply background from content_update)
  Future<void> _initializeMqtt() async {
    if (_isMqttConnected ||
        deviceId == null ||
        hotelId == null ||
        roomId == null ||
        !mounted)
      return;

    _isMqttConnected = true;

    print("🚀 MQTT Connecting → hotel/$hotelId/room/$roomId");

    await MqttManager.instance.connect(
      deviceId: deviceId!,
      hotelId: hotelId!,
      roomId: roomId!,
      onMessage: (data) async {
        if (!mounted) return;
        final event = data['event'];
        print("⚡ MQTT Event (Launcher): $event | Data: $data");

        if (!mounted) return;

        // --- IGNORE video_update explicitly (log only) ---
        if (event == 'video_update') {
          print(
            "ℹ️ Ignoring MQTT event video_update on Launcher (not used for background).",
          );
          return;
        }

        // --- HANDLE content_update (only this event updates background from banners) ---
        if (event == 'content_update') {
          print("🧩 Content update received!");

          String? newBg;

          // Ambil banner pertama (jika ada)
          if (data['banners'] != null &&
              data['banners'] is List &&
              (data['banners'] as List).isNotEmpty) {
            final banners = data['banners'] as List;
            final first = banners.first;
            // safety: check keys and types
            if (first != null &&
                first is Map &&
                first['image_url'] != null &&
                first['image_url'].toString().isNotEmpty) {
              newBg = first['image_url'].toString();
              print("🖼️ Banner image URL → $newBg");
            }
          }

          // Update running text immediately if present (safe to setState)
          if (data['text_running'] != null &&
              data['text_running'].toString().isNotEmpty) {
            if (!mounted) return;
            setState(() {
              textRunning = data['text_running'].toString();
              print("💬 Running text updated → $textRunning");
            });
          }

          // Jika ada newBg yang valid -> precache & apply (di luar setState)
          if (newBg != null && newBg.isNotEmpty) {
            // _updateBackgroundSafely akan mem-precache dan memanggil setState sendiri
            _updateBackgroundSafely(newBg);
          } else {
            print(
              "⚠️ No valid banner image in content_update; keeping existing background.",
            );
          }

          return;
        }

        // --- OTHER EVENTS: checkin, launcher_update, checkout (tidak mengubah background) ---
        if (event == 'checkin' || event == 'launcher_update') {
          if (!mounted) return;
          setState(() {
            if (data['guest_name'] != null &&
                data['guest_name'].toString().isNotEmpty) {
              guestName = data['guest_name'].toString();
            }
            if (data['room_number'] != null &&
                data['room_number'].toString().isNotEmpty) {
              roomNumber = data['room_number'].toString();
            }
          });
          return;
        }

        if (event == 'checkout') {
          if (!mounted) return;
          setState(() {
            guestName = null;
          });
          return;
        }

        // Jika event lain yang tidak terduga muncul
        print("ℹ️ Unknown MQTT event: $event");
      },
    );
  }

  /// Precache image first, then update backgroundUrl (prevents flicker)
  Future<void> _updateBackgroundSafely(String newUrl) async {
    try {
      if (newUrl.isEmpty) return;

      // kalau sama dengan yang sedang terpasang, skip
      if (backgroundUrl != null && backgroundUrl == newUrl) return;

      print("🧩 Pre-caching background: $newUrl");

      final image = NetworkImage(newUrl);
      // timeout agar tidak menggantung terlalu lama
      final precacheFuture = precacheImage(image, context);
      await precacheFuture.timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          print("⚠️ Precache timed out for $newUrl");
          throw TimeoutException("Precache timeout");
        },
      );

      if (!mounted) return;

      setState(() {
        backgroundUrl = newUrl;
        print("✅ Background applied: $backgroundUrl");
      });
    } catch (e) {
      print("❌ Failed to precache/apply background: $e");
      // jangan hapus background lama kalau gagal
    }
  }

  Future<void> _openTransVisionApp() async {
    try {
      const packageName = 'com.livetv.trvddm';
      const activityName = '.Login';

      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: packageName,
        componentName: '$packageName$activityName',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      await intent.launch();
      // print('✅ Berhasil membuka TransVision');
    } catch (e) {
      // print('❌ Gagal membuka TransVision: $e');
    }
  }

  Future<void> _openAppByComponent({
    required String package,
    required String activity,
  }) async {
    try {
      // ✅ Jika activity sudah diawali titik, tambahkan package
      final String finalActivity = activity.startsWith('.')
          ? '$package$activity'
          : activity; // kalau sudah full path biarkan

      print('🎯 Mencoba buka: $package → $finalActivity');

      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        package: package,
        componentName:
            finalActivity, // ⬅️ Hanya kirim nama activity, bukan package + activity
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED,
        ],
      );

      await intent.launch();
      print('✅ Membuka aplikasi: $finalActivity');
    } catch (e) {
      print('❌ Gagal membuka aplikasi: $e');
    }
  }

  void _handleMenuTap(Map<String, dynamic> item) async {
    switch (item['label']) {
      case 'Hotel Info':
        Navigator.push(
          context,
          PageRouteBuilder(
            // transitionDuration: const Duration(),
            pageBuilder: (_, __, ___) => HotelInfoScreen(
              hotelId: hotelId,
              roomId: roomId,
              deviceId: deviceId,
              hotelName: hotelName,
              guestName: guestName,
              roomNumber: roomNumber,
              backgroundUrl: backgroundUrl,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
        break;

      case 'TV':
        await _openAppByComponent(
          package: 'com.livetv.trvddm',
          activity: 'com.livetv.trvddm.ui.main.LoginActivity',
        );
        break;

      case 'Youtube':
        await _openAppByComponent(
          package: 'com.google.android.youtube.tv',
          activity: 'com.google.android.apps.youtube.tv.activity.ShellActivity',
        );
        break;

      case 'Youtube Kids':
        await _openAppByComponent(
          package: 'com.google.android.youtube.tv',
          activity: 'com.google.android.apps.youtube.tv.activity.ShellActivity',
        );
        break;

      case 'Netflix':
        await _openAppByComponent(
          package: 'com.netflix.ninja',
          activity: '.MainActivity',
        );
        break;

      case 'Vidio':
        await _openAppByComponent(
          package: 'com.vidio.android.tv',
          activity: 'com.vidio.android.tv.splashscreen.SplashScreenActivity',
        );
        break;

      case 'Disney+':
        await _openAppByComponent(
          package: 'com.disney.disneyplus',
          activity: 'com.bamtechmedia.dominguez.main.MainActivity',
        );
        break;

      case 'Prime Video':
        await _openAppByComponent(
          package: 'com.amazon.amazonvideo.livingroom',
          activity: 'com.amazon.ignition.IgnitionActivity',
        );
        break;

      case 'Spotify':
        await _openAppByComponent(
          package: 'com.spotify.tv.android',
          activity: 'com.spotify.tv.android.SpotifyTVActivity',
        );
        break;

      default:
        print('⚠️ Tidak ada aksi untuk ${item['label']}');
    }
  }

  @override
  void dispose() {
    _isMqttConnected = false;
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

          final iconSize = base * 4.5;
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
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                        // gunakan Stack supaya tidak ada animasi ukuran/lay out
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        // hanya fade, no scale/size
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: (backgroundUrl != null && backgroundUrl!.isNotEmpty)
                      ? Image.network(
                          backgroundUrl!,
                          key: ValueKey(backgroundUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            // selama loading, tampilkan placeholder hitam (menghindari blank putih)
                            return Container(color: Colors.black);
                          },
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
                      // 📦 Modern Elegant Bottom Bar (tanpa blur)
                      Container(
                        height: barHeight * 1.2,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: base * 0.8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.blueGrey.withOpacity(0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(base * 3),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: base * 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                            children: List.generate(menuItems.length, (index) {
                              final item = menuItems[index];
                              final isSelected = selectedIndex == index;

                              final glowColor =
                                  {
                                    'Youtube': Colors.redAccent,
                                    'Netflix': Colors.red,
                                    'Disney+': Colors.lightBlueAccent,
                                    'Spotify': Colors.greenAccent,
                                    'Vidio': Colors.purpleAccent,
                                    'Prime Video': Colors.indigoAccent,
                                  }[item['label']] ??
                                  Colors.cyanAccent;

                              return Focus(
                                autofocus: index == 0,
                                onKeyEvent: (node, event) {
                                  if (event is KeyDownEvent) {
                                    if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowRight) {
                                      setState(() {
                                        selectedIndex =
                                            (selectedIndex + 1) %
                                            menuItems.length;
                                      });
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                        LogicalKeyboardKey.arrowLeft) {
                                      setState(() {
                                        selectedIndex =
                                            (selectedIndex -
                                                1 +
                                                menuItems.length) %
                                            menuItems.length;
                                      });
                                      return KeyEventResult.handled;
                                    } else if (event.logicalKey ==
                                            LogicalKeyboardKey.enter ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.select) {
                                      _handleMenuTap(menuItems[selectedIndex]);
                                      return KeyEventResult.handled;
                                    }
                                  }
                                  return KeyEventResult.ignored;
                                },
                                child: GestureDetector(
                                  onTap: () => _handleMenuTap(item),
                                  onTapDown: (_) =>
                                      setState(() => selectedIndex = index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    padding: EdgeInsets.all(base * 0.8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.transparent,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: glowColor.withOpacity(
                                                  0.7,
                                                ),
                                                blurRadius: 20,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedScale(
                                          scale: isSelected ? 1.25 : 1.0,
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: Icon(
                                            item['icon'],
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.7),
                                            size: iconSize * 0.9,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        AnimatedOpacity(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          opacity: isSelected ? 1.0 : 0.0,
                                          child: Text(
                                            item['label'],
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: fontSize * 1.1,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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

/// 🎬 Widget untuk text berjalan otomatis (running text modern)
class _RunningTextBar extends StatefulWidget {
  final String text;
  final double fontSize;

  const _RunningTextBar({required this.text, this.fontSize = 16});

  @override
  State<_RunningTextBar> createState() => _RunningTextBarState();
}

class _RunningTextBarState extends State<_RunningTextBar>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final double _scrollSpeed; // pixel per second

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollSpeed = 40; // 🌟 Kecepatan gerak (semakin kecil = lebih lambat)

    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    final textWidth = _scrollController.position.maxScrollExtent;
    final duration = Duration(
      milliseconds: ((textWidth / _scrollSpeed) * 1000).toInt(),
    );

    _animationController = AnimationController(vsync: this, duration: duration)
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_animationController.value * textWidth);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scrollController.jumpTo(0);
          _animationController.forward(from: 0);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.fontSize * 3.2,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.blueGrey.withOpacity(0.3),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              const SizedBox(width: 40),
              _buildText(widget.text),
              const SizedBox(width: 80),
              _buildText(widget.text),
              const SizedBox(width: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF00C2FF), // 💎 Biru terang elegan (Hotel Accent)
          Color(0xFFFFFFFF), // 🤍 Putih lembut di ujung
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: const Color(0xFF00C2FF).withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
