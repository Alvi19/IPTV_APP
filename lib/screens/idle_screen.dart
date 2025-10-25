import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../services/mqtt_manager.dart';
import 'launcher_screen.dart';
import '../widgets/clock_widget.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class IdleScreen extends StatefulWidget {
  const IdleScreen({super.key});

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> {
  final ApiService api = ApiService();
  VideoPlayerController? _controller;
  bool _isMqttConnected = false;
  bool _videoReady = false;

  String? customerName;
  String? roomNumber;
  String? deviceId;
  String? videoUrl;
  String? logoUrl;
  String? background_image_url;
  String? hotelName;
  int? hotelId;
  int? roomId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// ✅ Ambil data awal dan setup MQTT
  Future<void> _initializeData() async {
    try {
      print("🔍 Fetching device config...");
      final config = await api.getDeviceConfigAuto();
      deviceId = config['device_id'];
      print("✅ Device ID: $deviceId");

      final launcherData = await api.getLauncherData(deviceId!);
      final hotel = launcherData['hotel'] ?? {};
      final room = launcherData['room'] ?? {};

      hotelId = hotel['id'];
      hotelName = hotel['name'];
      videoUrl = hotel['video_url'];
      logoUrl = hotel['logo_url'];
      background_image_url = hotel['background_image_url'];
      roomId = room['id'];
      customerName = room['guest_name'];
      roomNumber = room['number']?.toString();

      print("🏨 Hotel: $hotelName");
      print("🎞️ Video URL: $videoUrl");

      if (videoUrl != null && videoUrl!.isNotEmpty) {
        await _initializeVideo(videoUrl!);
      } else {
        print("⚠️ No video URL found from API");
      }

      await _initializeMqtt();
    } catch (e) {
      print("❌ Error initializing IdleScreen: $e");
    }
  }

  /// ✅ Inisialisasi VideoPlayerController dengan URL dari API
  Future<void> _initializeVideo(String url) async {
    print("🎬 Initializing video player...");

    try {
      // ✅ Tunggu 300ms setelah masuk ke halaman untuk memastikan context stabil
      await Future.delayed(const Duration(milliseconds: 300));

      // Hentikan dan dispose video lama kalau ada
      if (_controller != null) {
        try {
          await _controller!.pause();
          await _controller!.dispose();
        } catch (e) {
          print("⚠️ Error disposing previous video: $e");
        }
        _controller = null;
        await Future.delayed(const Duration(milliseconds: 200));
      }

      if (!mounted) return;

      // ✅ Tambahkan timestamp agar video tidak di-cache
      final uri = Uri.parse("$url?ts=${DateTime.now().millisecondsSinceEpoch}");
      print("🎞️ Loading video from $uri");

      final newController = VideoPlayerController.networkUrl(uri);

      await newController.initialize();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      await newController.setLooping(true);
      await newController.setVolume(1.0);
      await newController.play();

      setState(() {
        _controller = newController;
        _videoReady = true;
      });

      print("✅ Video ready (source: ${newController.dataSource})");
    } catch (e) {
      print("❌ Failed to initialize video: $e");
      setState(() => _videoReady = false);
    }
  }

  /// ✅ Setup koneksi MQTT
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
      onMessage: (data) async {
        final event = data['event'];
        print("⚡ MQTT Event (IdleScreen): $event | Payload: $data");

        if (!mounted) return;

        if (event == 'video_update' && data['video_url'] != null) {
          await _initializeVideo(data['video_url']);
        } else if (event == 'checkin' ||
            event == 'launcher_update' ||
            event == 'checkout') {
          setState(() {
            if (event == 'checkout') {
              // Hanya kosongkan saat checkout
              customerName = null;
            } else if (event == 'checkin') {
              // Update dari MQTT checkin
              customerName = data['guest_name'] ?? customerName;
              roomNumber = data['room_number']?.toString() ?? roomNumber;
            } else if (event == 'launcher_update') {
              // Jika ada guest baru
              if (data['guest_name'] != null &&
                  data['guest_name'].toString().isNotEmpty) {
                customerName = data['guest_name'];
              }

              // ✅ Update background image (bukan logo)
              if (data['background_image_url'] != null &&
                  data['background_image_url'].toString().isNotEmpty) {
                background_image_url = data['background_image_url'];
                print(
                  "🖼️ Updated background from MQTT → $background_image_url",
                );
              }

              // ✅ Kalau ada logo hotel baru (optional)
              if (data['logo_url'] != null &&
                  data['logo_url'].toString().isNotEmpty) {
                logoUrl = data['logo_url'];
                print("🏨 Updated logo from MQTT → $logoUrl");
              }

              // Tetap update nomor kamar
              roomNumber = data['room_number']?.toString() ?? roomNumber;
            }
          });
        }
      },
    );
  }

  /// ✅ Bersihkan video + MQTT saat keluar
  Future<void> _disposeVideo() async {
    try {
      if (_controller != null) {
        print("🧹 Stopping video before navigation...");
        await _controller!.pause();
        await Future.delayed(const Duration(milliseconds: 150));
        await _controller!.dispose();
        _controller = null;
        print("✅ Video stopped cleanly");
      }
    } catch (e) {
      print("⚠️ Error disposing video: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    MqttManager.instance.disconnect();

    Future.microtask(() async {
      try {
        if (_controller != null) {
          await _controller!.pause();
          await Future.delayed(const Duration(milliseconds: 100));
          await _controller!.dispose();
          print("🧹 Video controller disposed cleanly on IdleScreen exit");
        }
        _controller = null;
      } catch (e) {
        print("⚠️ Error disposing controller in IdleScreen: $e");
      }
    });
  }

  /// ✅ Navigasi aman ke Launcher (tanpa suara sisa)
  Future<void> _goToLauncher(BuildContext context) async {
    await _disposeVideo();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LauncherScreen(
          hotelId: hotelId,
          roomId: roomId,
          guestName: customerName,
          roomNumber: roomNumber,
          backgroundUrl:
              background_image_url, // ✅ gunakan background, bukan logo
          deviceId: deviceId,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final base = (screen.width + screen.height) / 200;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(now);

    // Jika controller belum siap → tampilkan loading
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Loading video...",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final isGuestCheckedIn = customerName != null && customerName!.isNotEmpty;
    final welcomeText = isGuestCheckedIn
        ? "Welcome ${customerName!}"
        : "Welcome to $hotelName";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🎥 Background video — hanya tampil jika controller siap
          if (_controller != null && _controller!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),

          /// 🔝 Logo & Clock
          Positioned(
            top: base * 2.0,
            left: base * 2.0,
            right: base * 2.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (logoUrl != null && logoUrl!.isNotEmpty)
                  Image.network(
                    logoUrl!,
                    width: base * 20,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ClockWidget(),
                    SizedBox(height: base * 0.4),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: base * 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🧍 Guest Info
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: base * 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    welcomeText,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: base * 3.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: base * 0.6),
                  Text(
                    "Room ${roomNumber ?? '-'}",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: base * 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔘 Continue Button
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: base, left: base * 1.5),
              child: OutlinedButton(
                onPressed: () async => _goToLauncher(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white, width: base * 0.2),
                  padding: EdgeInsets.symmetric(
                    horizontal: base * 5,
                    vertical: base * 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(base * 2),
                  ),
                ),
                child: Text(
                  "CLICK OK TO CONTINUE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: base * 2.2,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
