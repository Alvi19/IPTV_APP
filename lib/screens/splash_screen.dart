import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'idle_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 Logo fade-in animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // ⏳ Delay sebelum ke IdleScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const IdleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final base = (screen.width + screen.height) / 200; // skala dinamis

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 🌌 Background gradient halus
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF050505), Color(0xFF101010)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ✨ Logo + teks fade-in (responsive size)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🏨 Logo hotel
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(base),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: base * 1.2,
                        offset: Offset(0, base * 0.4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(base),
                    child: Image.asset(
                      'assets/images/hotel_logo.jpg', // gunakan PNG transparan
                      width: base * 25, // otomatis menyesuaikan layar
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: base * 4),

                // 🧾 Teks "Welcome"
                Text(
                  "Welcome to Desa Alamanis Resort Villa",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: base * 2.4, // skala otomatis
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: base,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: base * 2.5),

                // 🔘 Loading dots / indicator (opsional tapi keren di TV)
                SizedBox(
                  width: base * 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) => FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: base * 0.9,
                          height: base * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
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
