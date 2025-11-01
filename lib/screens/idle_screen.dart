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

        // Menangani pembaruan video
        if (event == 'video_update' && data['video_url'] != null) {
          final newVideoUrl = data['video_url'];
          setState(() {
            videoUrl = newVideoUrl; // Memperbarui URL video
          });
          await _initializeVideo(newVideoUrl); // Menampilkan video baru
        }
        // Menangani pembaruan lainnya (misalnya, checkin/checkout)
        else if (event == 'launcher_update' ||
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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Mengubah alignment ke tengah
                children: [
                  if (logoUrl != null && logoUrl!.isNotEmpty)
                    Image.network(logoUrl!, width: base * 18),
                ],
              ),
            ),

            // Mengubah posisi jam dan tanggal ke kiri
            Positioned(
              top: base * 2,
              left: base * 2, // Menempatkan jam dan tanggal di kiri
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Mengatur agar teks rata kiri
                children: [
                  const ClockWidget(
                    color: Color(
                      0xFFC3A354,
                    ), // Menambahkan warna emas pada ClockWidget
                  ),
                  SizedBox(height: base * 0.4),
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      color: Color(0xFFC3A354).withOpacity(0.9),
                      fontSize: base * 2.0,
                    ),
                  ),
                ],
              ),
            ),

            // 🧍 Guest info — Desain dengan Gradasi dan Efek Premium
            Positioned(
              right: base * 4,
              bottom: base * 4, // Mengurangi jarak sedikit agar lebih rapat
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: base * 0.8, // Mengurangi sedikit padding vertikal
                  horizontal: base * 5, // Mengurangi sedikit padding horizontal
                ),
                decoration: BoxDecoration(
                  // Menghilangkan background transparan dan hanya menggunakan border radius
                  borderRadius: BorderRadius.circular(
                    base * 4,
                  ), // Memperkecil border radius untuk efek yang lebih proporsional
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      0.6,
                    ), // Warna border dengan sedikit transparansi
                    width: 2, // Ketebalan border
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Agar teks rata kiri
                  children: [
                    // Teks statis tanpa animasi
                    Text(
                      "Wilujeng Sumping,",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize:
                            base *
                            2.5, // Mengurangi ukuran font agar lebih proporsional
                        fontStyle: FontStyle.italic,
                        letterSpacing:
                            1.5, // Menambahkan jarak antar huruf untuk kesan lebih modern dan elegan
                      ),
                    ),
                    SizedBox(
                      height: base * 0.3,
                    ), // Menambahkan jarak antara teks
                    Text(
                      guest,
                      style: GoogleFonts.poppins(
                        color: Color(0xFFC3A354).withOpacity(0.9),
                        fontSize:
                            base *
                            3.8, // Mengurangi ukuran nama tamu agar lebih proporsional
                        fontWeight: FontWeight.bold,
                        letterSpacing:
                            1.5, // Memberikan kesan lebih modern dan jelas
                      ),
                    ),
                    SizedBox(
                      height: base * 0.3,
                    ), // Menambahkan jarak antara teks
                    Text(
                      "Room $room",
                      style: GoogleFonts.poppins(
                        color: Colors.amberAccent,
                        fontSize:
                            base *
                            2.4, // Mengurangi ukuran teks room agar lebih proporsional
                        letterSpacing:
                            1.2, // Mempertahankan jarak antar huruf untuk kesan modern
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: base * 8,
              left: base * 6,
              child: GestureDetector(
                onTap: () async => _goToLauncher(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card tetap statis, hanya teks yang memiliki animasi gerak
                    Card(
                      color: Colors.transparent,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(base * 3),
                        side: BorderSide(
                          color: Colors.yellow.withOpacity(0.7),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: base * 5,
                          vertical: base * 2.2,
                        ),
                        child: ScaleTransition(
                          scale: Tween(begin: 0.9, end: 1.1).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: _pulseController,
                            child: Text(
                              "Please To Continue",
                              style: GoogleFonts.lora(
                                color: Color.fromARGB(
                                  255,
                                  254,
                                  183,
                                  1,
                                ).withOpacity(0.9),
                                fontSize: base * 2.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.yellow.withOpacity(0.7),
                                    blurRadius: 20,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
}
