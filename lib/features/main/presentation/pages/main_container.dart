import 'package:flutter/material.dart';
import '../../../hotel/presentation/pages/welcome_page.dart';
import '../../../hotel/presentation/pages/hotel_info_page.dart';
import '../../../hotel/presentation/pages/cancel_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    WelcomePage(),
    HotelInfoPage(),
    CancelPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Welcome'),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Hotel Info',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: 'Cancel'),
        ],
      ),
    );
  }
}
