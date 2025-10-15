import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iptv_app/features/hotel/presentation/widgets/side_menu_item.dart';
import '../../../../core/constants/app_colors.dart';

class HotelInfoPage extends StatefulWidget {
  const HotelInfoPage({super.key});

  @override
  State<HotelInfoPage> createState() => _HotelInfoPageState();
}

class _HotelInfoPageState extends State<HotelInfoPage> {
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradasi hitam ke abu
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundDark, AppColors.backgroundGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          //  Sidebar kiri (widget terpisah)
          const SidebarMenu(),

          // 🏨 Welcome text di luar sidebar — sejajar dengan jam kiri atas
          Positioned(
            top: 20,
            left: 255,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Welcome,",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Room",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Jam kanan atas
          Positioned(
            top: 25,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  "12.12",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Wed, 15 Oct 2025",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
