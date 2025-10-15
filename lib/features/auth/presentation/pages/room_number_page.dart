import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/orientation_util.dart';

class RoomNumberPage extends StatefulWidget {
  const RoomNumberPage({super.key});

  @override
  State<RoomNumberPage> createState() => _RoomNumberPageState();
}

class _RoomNumberPageState extends State<RoomNumberPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    OrientationUtil.lockLandscape();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1C3C3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, color: Colors.white, size: 60),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Room number',
                  hintStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.cancel);
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 30),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.welcome);
                  },
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
