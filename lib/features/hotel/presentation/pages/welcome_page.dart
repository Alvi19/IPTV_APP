import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background gradient (hitam ke abu)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundDark, AppColors.backgroundGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🏨 Welcome Text
          Positioned(
            left: 60,
            top: 120,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "Welcome to our hotel",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),

          // 🕒 Waktu di kanan atas
          Positioned(
            top: 40,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  "12.12",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Wed, 15 Oct 2025",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // 🧭 Menu bawah (scroll horizontal)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _MenuItem(
                      icon: Icons.apartment,
                      label: "Hotel Info",
                      onTap: () {
                        // ✅ menggunakan named route sesuai AppRoutes
                        Navigator.pushNamed(context, AppRoutes.hotelInfo);
                      },
                    ),
                    const _MenuItem(icon: Icons.tv, label: "TV"),
                    const _MenuItem(icon: Icons.music_note, label: "Cubmu"),
                    const _MenuItem(
                      icon: Icons.restaurant,
                      label: "Restaurant",
                    ),
                    const _MenuItem(icon: Icons.wifi, label: "Wifi"),
                    const _MenuItem(
                      icon: Icons.play_circle_outline,
                      label: "Youtube",
                    ),
                    const _MenuItem(
                      icon: Icons.child_care,
                      label: "Youtube Kids",
                    ),
                    const _MenuItem(icon: Icons.movie, label: "Netflix"),
                    const _MenuItem(icon: Icons.play_arrow, label: "Vidio.com"),
                    const _MenuItem(icon: Icons.newspaper, label: "News"),
                    const _MenuItem(icon: Icons.games, label: "Games"),
                    const _MenuItem(icon: Icons.camera_alt, label: "Gallery"),
                    const _MenuItem(icon: Icons.settings, label: "Settings"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
