import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/clock_widget.dart';

class HotelInfoScreen extends StatefulWidget {
  const HotelInfoScreen({super.key});

  @override
  State<HotelInfoScreen> createState() => _HotelInfoScreenState();
}

class _HotelInfoScreenState extends State<HotelInfoScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  String? errorMessage;
  int selectedMenuIndex = 0;

  final ApiService api = ApiService();
  final String deviceId = 'STB-A-1';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final result = await api.getLauncherData(deviceId);
      if (mounted) {
        setState(() {
          data = result;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final baseUnit = (screen.width + screen.height) / 100;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, d MMM yyyy').format(now);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Error: $errorMessage",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    final hotel = data?['hotel'] ?? {};
    final room = data?['room'] ?? {};
    final menus = data?['menus'] ?? [];
    final contents = data?['contents'] ?? {};

    final bgUrl = hotel['background_url'];
    final hasBgImage = bgUrl != null && bgUrl.toString().isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // 🌆 Background dari API atau fallback default
          Container(
            decoration: BoxDecoration(
              image: hasBgImage
                  ? DecorationImage(
                      image: NetworkImage(bgUrl),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/default_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // 🌫️ Overlay elegan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF111111),
                  Color(0xFF1A1A1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🕒 Clock tetap fixed kanan atas
          // const ClockWidget(),
          // 🕒 Clock + Date (pojok kanan atas)
          // 🔝 Bar atas: (konsep seperti di IdleScreen)
          Positioned(
            top: baseUnit * 2.0,
            left: baseUnit * 2.0,
            right: baseUnit * 2.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // sejajar bagian atas
              children: [
                // 🏨 (opsional) logo atau placeholder kosong kiri
                Container(
                  width: baseUnit * 10,
                  height: baseUnit * 5,
                  // Jika mau tambahkan logo, aktifkan kode ini:
                  // child: Image.asset('assets/images/hotel_logo.jpg', fit: BoxFit.contain),
                ),

                // 🕒 Jam & tanggal (naik sedikit secara visual)
                Transform.translate(
                  offset: Offset(
                    0,
                    -baseUnit * 3.9,
                  ), // ✅ geser naik seperti di IdleScreen
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ClockWidget(),
                      SizedBox(height: baseUnit * 0.4),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: baseUnit * 1.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: baseUnit * 0.5,
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

          Row(
            children: [
              // 📋 Sidebar kiri
              Container(
                width: screen.width * 0.25,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  border: const Border(
                    right: BorderSide(color: Colors.white10, width: 1),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: baseUnit * 1.8,
                  horizontal: baseUnit,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MENU",
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFD4AF37),
                        fontSize: baseUnit * 0.9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: baseUnit * 0.8),
                    Divider(
                      color: Colors.white.withOpacity(0.2),
                      thickness: 0.5,
                    ),
                    SizedBox(height: baseUnit * 1),

                    Expanded(
                      child: ListView.builder(
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final menu = menus[index];
                          final isSelected = selectedMenuIndex == index;

                          return InkWell(
                            onTap: () =>
                                setState(() => selectedMenuIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.symmetric(
                                vertical: baseUnit * 0.6,
                                horizontal: baseUnit * 0.8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFD4AF37).withOpacity(0.6)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                menu['name'] ?? '-',
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: baseUnit * 0.75,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 🏨 Konten kanan
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: baseUnit * 2.5,
                    vertical: baseUnit * 1.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 💎 Guest Info Card (tidak full width)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: screen.width * 0.45, // 👉 hanya setengah layar
                          padding: EdgeInsets.symmetric(
                            horizontal: baseUnit * 1.6,
                            vertical: baseUnit * 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(2, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 👤 Guest Info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome, ${room['guest_name'] ?? 'Guest'}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: baseUnit * 0.95,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: baseUnit * 0.3),
                                  Text(
                                    "Room ${room['number'] ?? '-'} • ${room['type'] ?? ''}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: baseUnit * 0.7,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 25),

                              // 🏨 Hotel Name di tengah kiri
                              Expanded(
                                child: Text(
                                  hotel['name'] ?? 'Hotel Name',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.cinzel(
                                    color: const Color(0xFFD4AF37),
                                    fontSize: baseUnit * 0.9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: baseUnit * 2),

                      // 📄 Konten tiap menu
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: _buildMenuContent(
                            menus[selectedMenuIndex],
                            contents[menus[selectedMenuIndex]['slug']],
                            baseUnit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent(
    Map<String, dynamic> menu,
    dynamic content,
    double baseUnit,
  ) {
    final menuName = menu['name'] ?? 'Menu';
    final description =
        content?['description'] ?? 'No content available for this section.';

    return Container(
      key: ValueKey(menuName),
      padding: EdgeInsets.all(baseUnit * 1.2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              menuName.toUpperCase(),
              style: GoogleFonts.cinzel(
                color: const Color(0xFFD4AF37),
                fontSize: baseUnit * 1.1,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2.5,
              width: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: baseUnit * 0.75,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
