import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
          // 🌈 Background gradasi hitam ke abu
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundDark, AppColors.backgroundGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🏨 Judul tengah
          const Center(
            child: Text(
              "Welcome to the Main Hotel Screen",
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 🕒 Waktu kanan atas
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

          // 🧭 Tombol hotel info kanan bawah
          Positioned(
            bottom: 40,
            right: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.hotelInfo);
              },
              icon: const Icon(Icons.hotel, color: Colors.white),
              label: const Text(
                "Hotel Info",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
