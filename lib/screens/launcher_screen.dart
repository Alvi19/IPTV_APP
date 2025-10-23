import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/clock_widget.dart';
import 'hotel_info_screen.dart';

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  int selectedIndex = -1;
  String? backgroundUrl;
  String roomNumber = "Room 102"; // nanti bisa diganti dari API

  final List<Map<String, dynamic>> menuItems = const [
    {'icon': Icons.apartment, 'label': 'Hotel Info', 'page': HotelInfoScreen()},
    {'icon': Icons.tv, 'label': 'TV'},
    {'icon': Icons.music_note, 'label': 'Cubmu'},
    {'icon': Icons.restaurant, 'label': 'Restaurant'},
    {'icon': Icons.wifi, 'label': 'Wifi'},
    {'icon': Icons.play_circle_fill, 'label': 'Youtube'},
    {'icon': Icons.child_care, 'label': 'Youtube Kids'},
    {'icon': Icons.movie, 'label': 'Netflix'},
    {'icon': Icons.video_collection, 'label': 'Vidio.com'},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    fetchBackground();
  }

  Future<void> fetchBackground() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final imageUrl =
          "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1920&q=80";
      setState(() => backgroundUrl = imageUrl);
    } catch (e) {
      setState(() => backgroundUrl = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final base = (width + height) / 200;

        final iconSize = base * 3.2;
        final fontSize = base * 1.0;
        final barHeight = base * 8.5;
        final padding = base * 2.0;

        final now = DateTime.now();
        final formattedDate = DateFormat(
          'EEEE, d MMMM yyyy',
          'en_US',
        ).format(now);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 🖼️ Background
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: backgroundUrl != null
                      ? DecorationImage(
                          image: NetworkImage(backgroundUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),

              // 🌫️ Overlay kontras
              Container(color: Colors.black.withOpacity(0.3)),

              // 🕒 Header atas: jam & room sejajar
              Positioned(
                top: base * 1.0,
                left: base * 3.5,
                right: base * 3.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Baris atas: jam dan room sejajar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🕒 Jam (ClockWidget)
                        const ClockWidget(),

                        // 🏠 Nomor Room — sama ukuran & warna seperti jam
                        Text(
                          "Room 102",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize:
                                base *
                                2.8, // disamakan dengan jam (ClockWidget default)
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 🔹 Baris bawah: tanggal
                    SizedBox(height: base * 0.6),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: base * 2.2,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 💬 Welcome Text tengah kiri
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: padding * 2),
                  padding: EdgeInsets.symmetric(
                    vertical: base * 1.5,
                    horizontal: base * 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Welcome to Desa Alamanis Resort Villa",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: base * 2.2,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 📱 Bottom menu bar
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: barHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    border: const Border(
                      top: BorderSide(color: Colors.white12, width: 0.6),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: base * 2.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(menuItems.length, (index) {
                        final item = menuItems[index];
                        final isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            if (item['page'] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => item['page']),
                              );
                            }
                          },
                          child: MouseRegion(
                            onEnter: (_) =>
                                setState(() => selectedIndex = index),
                            onExit: (_) => setState(() => selectedIndex = -1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: isSelected ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Icon(
                                    item['icon'],
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    size: iconSize,
                                  ),
                                ),
                                SizedBox(height: base * 0.6),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  child: Text(item['label']),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // ⏳ Loading
              if (backgroundUrl == null)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        );
      },
    );
  }
}
