import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../services/mqtt_manager.dart';
import 'launcher_screen.dart';
import 'device_input_screen.dart';
import '../widgets/clock_widget.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class IdleScreen extends StatefulWidget {
  final String deviceId;

  const IdleScreen({super.key, required this.deviceId});

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen>
    with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();
  VideoPlayerController? _controller;
  bool _isMqttConnected = false;
  bool _videoReady = false;
  bool _isDisposed = false;
  final FocusNode _focusNode = FocusNode();

  String? customerName;
  String? roomNumber;
  String? videoUrl;
  String? logoUrl;
  String? backgroundImageUrl;
  String? hotelName;
  int? hotelId;
  int? roomId;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _initializeData(widget.deviceId);
  }

  Future<void> _initializeData(String deviceId) async {
    try {
      print("📱 Device ID aktif: $deviceId");
      await api.registerDevice(deviceId);

      final config = await api.getDeviceConfigAuto(deviceId);
      print("⚙️ Config: $config");

      final launcherData = await api.getLauncherData(deviceId);
      print("🏨 Launcher data: $launcherData");

      final hotel = launcherData['hotel'] ?? {};
      final room = launcherData['room'] ?? {};

      hotelId = hotel['id'];
      hotelName = hotel['name'] ?? "Welcome Guest";
      videoUrl = hotel['video_url'];
      logoUrl = hotel['logo_url'];
      backgroundImageUrl = hotel['background_image_url'];
      roomId = room['id'];
      customerName = room['guest_name'];
      roomNumber = room['number']?.toString();

      if (videoUrl == null || videoUrl!.isEmpty) {
        videoUrl =
            "http://10.87.232.10:8000/storage/uploads/videos/default_video.mp4";
        print("🎬 Menggunakan video default: $videoUrl");
      }

      await _initializeVideo(videoUrl!);
      await _initializeMqtt();
    } catch (e) {
      print("❌ Error initializing IdleScreen: $e");
    }
  }

  Future<void> _initializeVideo(String url) async {
    try {
      final uri = Uri.parse("$url?ts=${DateTime.now().millisecondsSinceEpoch}");
      print("🎞️ Loading video from $uri");

      final oldController = _controller;
      _controller = null;
      if (oldController != null) {
        try {
          await oldController.pause();
          await oldController.dispose();
        } catch (_) {}
      }

      final newController = VideoPlayerController.networkUrl(uri);
      await newController.initialize();

      if (!mounted || _isDisposed) {
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

      print("✅ Video siap diputar");
    } catch (e) {
      print("❌ Gagal memuat video: $e");
      setState(() => _videoReady = false);
    }
  }

  Future<void> _initializeMqtt() async {
    if (_isMqttConnected || _isDisposed) return;
    _isMqttConnected = true;

    await MqttManager.instance.connect(
      deviceId: widget.deviceId,
      hotelId: hotelId ?? 0,
      roomId: roomId ?? 0,
      onMessage: (data) async {
        if (!mounted || _isDisposed) return;
        final event = data['event'];
        print("⚡ MQTT Event: $event | Payload: $data");

        if (event == 'video_update' && data['video_url'] != null) {
          await _initializeVideo(data['video_url']);
        } else if (event == 'launcher_update' ||
            event == 'checkin' ||
            event == 'checkout') {
          setState(() {
            if (event == 'checkout') {
              customerName = "Guest";
            } else {
              if (data['guest_name'] != null) {
                customerName = data['guest_name'];
              }
              if (data['room_number'] != null) {
                roomNumber = data['room_number'].toString();
              }
            }

            if (data['background_image_url'] != null) {
              backgroundImageUrl = data['background_image_url'];
            }
            if (data['logo_url'] != null) {
              logoUrl = data['logo_url'];
            }
          });
        }
      },
    );
  }

  Future<void> _goToLauncher(BuildContext context) async {
    if (_controller != null) {
      try {
        await _controller!.pause();
        await _controller!.dispose();
      } catch (_) {}
    }
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LauncherScreen(
          hotelId: hotelId,
          roomId: roomId,
          guestName: customerName,
          roomNumber: roomNumber,
          backgroundUrl: backgroundImageUrl,
          deviceId: widget.deviceId,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _handleRemoteKey(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey.keyLabel.toLowerCase().contains("dpad") ||
          event.logicalKey.keyLabel.toLowerCase().contains("center")) {
        await _goToLauncher(context);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pulseController.dispose();
    _focusNode.dispose();
    MqttManager.instance.disconnect();
    try {
      _controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final base = (screen.width + screen.height) / 200;
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(DateTime.now());

    if (!_videoReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final guest = customerName ?? "Guest";
    final room = roomNumber ?? "-";

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleRemoteKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // 🎥 Background video
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),

            // 🔝 Logo & Clock
            Positioned(
              top: base * 2,
              left: base * 2,
              right: base * 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (logoUrl != null && logoUrl!.isNotEmpty)
                    Image.network(logoUrl!, width: base * 18),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🧍 Guest info
            Positioned(
              right: 0,
              bottom: base * 5,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: base * 1.2,
                  horizontal: base * 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(base * 5.5),
                    bottomLeft: Radius.circular(base * 5.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Wilujeng Sumping,",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: base * 2.9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      guest,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: base * 3.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Room $room",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: base * 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔘 Tombol ENTER (PULSE ANIMASI)
            // 🔘 Tombol ENTER (PULSE ANIMASI) — Sekarang di kiri bawah
            Positioned(
              bottom: base * 8,
              left: base * 6,
              child: GestureDetector(
                onTap: () async => _goToLauncher(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 0.9, end: 1.1).animate(
                        CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: base * 6,
                          vertical: base * 1.8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(base * 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          "ENTER",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: base * 3.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: base * 1.2),
                    Text(
                      "Tekan ENTER untuk melanjutkan",
                      style: GoogleFonts.poppins(
                        color: Colors.yellow.shade600,
                        fontSize: base * 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // // ⚙️ Tombol ganti Device ID
            // Positioned(
            //   right: 20,
            //   bottom: 20,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.black.withOpacity(0.6),
            //     ),
            //     onPressed: () {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(
            //           builder: (_) => const DeviceInputScreen(),
            //         ),
            //       );
            //     },
            //     child: const Text("Ganti Device ID"),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
