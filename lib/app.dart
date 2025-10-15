import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/presentation/pages/room_number_page.dart';
import 'features/hotel/presentation/pages/cancel_page.dart';
import 'features/hotel/presentation/pages/welcome_page.dart';
import 'features/hotel/presentation/pages/hotel_info_page.dart';
import 'features/main/presentation/pages/main_page.dart';

class IPTVApp extends StatelessWidget {
  const IPTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Access System',
      initialRoute: AppRoutes.roomNumber,
      routes: {
        AppRoutes.roomNumber: (context) => const RoomNumberPage(),
        AppRoutes.cancel: (context) => const CancelPage(),
        AppRoutes.welcome: (context) => const WelcomePage(),
        AppRoutes.hotelInfo: (context) => const HotelInfoPage(),
        AppRoutes.main: (context) => const MainPage(),
      },
    );
  }
}
