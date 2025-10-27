import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'splash_screen.dart';

class DeviceInputScreen extends StatefulWidget {
  const DeviceInputScreen({super.key});

  @override
  State<DeviceInputScreen> createState() => _DeviceInputScreenState();
}

class _DeviceInputScreenState extends State<DeviceInputScreen> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ApiService api = ApiService();
  bool isLoading = false;
  bool isTVInput = false;

  @override
  void initState() {
    super.initState();
    // fokus otomatis
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  /// 🔍 Cek ke DB apakah device valid
  Future<void> _checkDevice() async {
    final deviceId = _controller.text.trim();
    if (deviceId.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await api.checkDevice(deviceId);

      if (response['status'] == true) {
        final data = response['data'];
        final hotelId = data['hotel_id'];
        final roomId = data['room_id'];

        print("✅ Device ditemukan di DB: $data");

        // 🔹 Kirim langsung ke SplashScreen dengan membawa device_id
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SplashScreen(deviceId: deviceId)),
        );
      } else {
        print("❌ Device tidak ditemukan: ${response['message']}");
        _showError(response['message']);
      }
    } catch (e) {
      print("❌ Gagal verifikasi device: $e");
      _showError("Gagal menghubungi server");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 🎮 Remote control handler
  void _handleRemoteKey(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.space ||
          key.keyLabel.toLowerCase().contains("dpad center")) {
        await _checkDevice();
      }

      if (key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowRight) {
        _focusNode.requestFocus();
      }

      if (key == LogicalKeyboardKey.goBack ||
          key == LogicalKeyboardKey.escape ||
          key == LogicalKeyboardKey.backspace) {
        print("🔙 Exit pressed on TV remote");
        SystemNavigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final base = (screen.width + screen.height) / 200;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleRemoteKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(base * 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Masukkan Device ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: base * 3.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: base * 2),
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => isTVInput = hasFocus);
                  },
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: base * 2.5,
                      letterSpacing: 2.0,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contoh: STB-12345',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: isTVInput ? Colors.white24 : Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(base),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: base * 3),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade700,
                    padding: EdgeInsets.symmetric(
                      horizontal: base * 8,
                      vertical: base * 1.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(base),
                    ),
                  ),
                  onPressed: isLoading ? null : _checkDevice,
                  child: isLoading
                      ? SizedBox(
                          height: base * 2.5,
                          width: base * 2.5,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          "LANJUT",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: base * 2.2,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
                SizedBox(height: base * 4),
                Text(
                  'Gunakan remote (OK) atau keyboard (Enter) untuk melanjutkan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: base * 1.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
