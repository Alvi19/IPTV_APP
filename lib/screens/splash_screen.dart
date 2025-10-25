import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'idle_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // 🔄 Ambil data hotel dari API
    _loadHotelData();

    // 🕒 Tunda sebentar sebelum ke IdleScreen
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const IdleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  Future<void> _loadHotelData() async {
    try {
      final config = await api.getDeviceConfigAuto();
      final deviceId = config['device_id'];
      final launcherData = await api.getLauncherData(deviceId);
      final hotel = launcherData['hotel'] ?? {};

      setState(() {
        hotelName = hotel['name'] ?? "Your Hotel";
        logoUrl = hotel['logo_url'];
      });

      print("🏨 Loaded hotel: $hotelName");
      print("🖼️ Logo URL: $logoUrl");
    } catch (e) {
      print("❌ Failed to load hotel info: $e");
      hotelName = "Hotel Launcher";
      logoUrl = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
                colors: [Color(0xFF050505), Color(0xFF101010)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ Logo dan teks
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🏨 Tampilkan logo dari API saja
                if (logoUrl != null && logoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(base),
                    child: Image.network(
                      logoUrl!,
                      width: base * 25,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print("⚠️ Error loading logo: $error");
                        return const SizedBox.shrink(); // tidak tampilkan apa pun
                      },
                    ),
                  )
                else
                  const SizedBox.shrink(), // kosongkan dulu

                SizedBox(height: base * 4),

                // 🪶 Nama Hotel
                if (hotelName != null)
                  Text(
                    "Welcome to $hotelName",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: base * 2.4,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
