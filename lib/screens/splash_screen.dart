import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'idle_screen.dart';
import 'device_input_screen.dart';

class SplashScreen extends StatefulWidget {
  final String deviceId; // ✅ Dapat dari DeviceInputScreen

  const SplashScreen({super.key, required this.deviceId});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String? hotelName;
  String? logoUrl;
  bool hasError = false;
  bool _isDisposed = false;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    _loadHotelData(widget.deviceId);
  }

  Future<void> _loadHotelData(String deviceId) async {
    try {
      print("📱 Device ID aktif: $deviceId");

      // 1️⃣ Register device
      await api.registerDevice(deviceId);
      if (_isDisposed) return;

      // 2️⃣ Ambil konfigurasi device
      final configResponse = await api.getDeviceConfigAuto(deviceId);
      if (_isDisposed) return;
      final configData = configResponse['data'] ?? configResponse;
      print("⚙️ Config: $configData");

      // 3️⃣ Ambil data hotel & room
      final launcherData = await api.getLauncherData(deviceId);
      if (_isDisposed) return;
      print("🏨 Launcher data: $launcherData");

      // 4️⃣ Tangani status response dari API
      if (launcherData['status'] == false) {
        print("❌ Device tidak terdaftar: ${launcherData['message']}");
        if (!_isDisposed && mounted) {
          setState(() => hasError = true);
        }
        return;
      }

      // 🧩 Ambil data hotel dan room
      final hotel = launcherData['hotel'];
      final room = launcherData['room'];

      // Jika hotel belum ada (default mode)
      if (hotel == null || hotel['id'] == null) {
        print("ℹ️ Default mode aktif (hotel/room kosong)");
        if (!_isDisposed && mounted) {
          setState(() {
            hotelName = "Welcome Guest";
            logoUrl = null;
            hasError = false;
          });
        }

        _scheduleNextScreen(deviceId);
        return;
      }

      // ✅ Update UI (mode normal)
      if (!_isDisposed && mounted) {
        setState(() {
          hotelName =
              hotel['name'] ?? configData['hotel_name'] ?? "Unknown Hotel";
          logoUrl = hotel['logo_url'];
          hasError = false;
        });
      }

      print("✅ Hotel Name: $hotelName");
      print("✅ Logo URL: $logoUrl");

      // 5️⃣ Navigasi ke IdleScreen setelah delay
      _scheduleNextScreen(deviceId);
    } catch (e) {
      print("❌ Gagal load hotel data: $e");
      if (!_isDisposed && mounted) {
        setState(() => hasError = true);
      }
    }
  }

  void _scheduleNextScreen(String deviceId) {
    _navTimer?.cancel();
    _navTimer = Timer(const Duration(seconds: 4), () {
      if (_isDisposed || !mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => IdleScreen(deviceId: deviceId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final base = (screen.width + screen.height) / 200;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🌌 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0A0A), Color(0xFF141414)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasError) ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade400,
                    size: base * 8,
                  ),
                  SizedBox(height: base * 2),
                  Text(
                    "Gagal memuat data hotel",
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: base * 2.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: base * 3),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      padding: EdgeInsets.symmetric(
                        horizontal: base * 5,
                        vertical: base * 1.5,
                      ),
                    ),
                    onPressed: () {
                      if (_isDisposed) return;
                      setState(() => hasError = false);
                      _loadHotelData(widget.deviceId);
                    },
                    child: Text(
                      "Coba Lagi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: base * 2.0,
                      ),
                    ),
                  ),
                ] else ...[
                  // 🏨 Logo
                  if (logoUrl != null && logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(base),
                      child: Image.network(
                        logoUrl!,
                        width: base * 28,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) {
                          print("⚠️ Error loading logo: $error");
                          return Icon(
                            Icons.image_not_supported,
                            color: Colors.white30,
                            size: base * 10,
                          );
                        },
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.all(base * 2),
                      child: const CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 3,
                      ),
                    ),
                  SizedBox(height: base * 3),

                  // 🪶 Nama Hotel
                  Text(
                    hotelName != null
                        ? "Welcome to $hotelName"
                        : "Memuat data hotel...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: base * 2.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 🔘 Tombol ganti device (opsional)
          Positioned(
            bottom: base * 4,
            right: base * 4,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
                padding: EdgeInsets.symmetric(
                  horizontal: base * 4,
                  vertical: base * 1.5,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceInputScreen()),
                );
              },
              child: const Text(
                "Ganti Device ID",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
