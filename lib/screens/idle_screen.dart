import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _controller;
  String customerName = "John Doe";

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/hotel_intro.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        if (mounted) setState(() {});
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
    final isVideoReady = _controller.value.isInitialized;
    final base = (screen.width + screen.height) / 200;

    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(now);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🎥 Background video
          if (isVideoReady)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 🔝 Bar atas: Logo + jam sejajar di satu garis
          Positioned(
            top: base * 2.0,
            left: base * 2.0,
            right: base * 2.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // sejajar bagian atas
              children: [
                // 🏨 Logo kiri atas
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(base),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: base * 1.2,
                        offset: Offset(0, base * 0.3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(base),
                    child: Image.asset(
                      'assets/images/hotel_logo.jpg',
                      width: base * 12,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 🕒 Jam & tanggal (naik sedikit secara visual)
                Transform.translate(
                  offset: Offset(
                    0,
                    -base * 6.5,
                  ), // ✅ geser naik supaya sejajar logo
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ClockWidget(),
                      SizedBox(height: base * 0.4),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: base * 2.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: base * 0.5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🙋 Nama Customer
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: base * 3),
              child: Text(
                customerName,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: base * 3.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: base * 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔘 Tombol "CLICK OK TO CONTINUE"
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: base * 1.0, left: base * 1.5),
              child: OutlinedButton(
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
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LauncherScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 600),
                    ),
                  );
                },
                child: Text(
                  "CLICK OK TO CONTINUE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: base * 2.2,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: base,
                      ),
                    ],
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
