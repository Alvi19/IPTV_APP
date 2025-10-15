import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      child: Container(
        width: 230,
        color: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.only(top: 100, left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SideMenuItem(label: "About Hotel"),
            SizedBox(height: 14),
            _SideMenuItem(label: "Room Type"),
            SizedBox(height: 14),
            _SideMenuItem(label: "Nearby Place"),
            SizedBox(height: 14),
            _SideMenuItem(label: "Facility"),
            SizedBox(height: 14),
            _SideMenuItem(label: "Event"),
            SizedBox(height: 14),
            _SideMenuItem(label: "Promotion"),
            SizedBox(height: 14),
            _SideMenuItem(label: "Policy"),
          ],
        ),
      ),
    );
  }
}

// 🌟 Komponen Menu Item Sidebar
class _SideMenuItem extends StatelessWidget {
  final String label;
  const _SideMenuItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
