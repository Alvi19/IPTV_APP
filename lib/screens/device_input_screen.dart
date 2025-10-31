import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iptv_app/services/device_identifier.dart';
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
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _checkDevice() async {
    final deviceId = _controller.text.trim();
    if (deviceId.isEmpty) {
      _showError("Device ID tidak boleh kosong");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await api.getDeviceConfigAuto(deviceId);

      if (response['status'] == true) {
        final data = response['data'];
        print("✅ Device ditemukan di DB: $data");

        // Simpan ke lokal agar tidak input lagi
        await DeviceIdentifier.saveDeviceId(deviceId);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SplashScreen(deviceId: deviceId)),
        );
      } else {
        _showError(response['message'] ?? "Device tidak ditemukan di database");
      }
    } catch (e) {
      print("❌ Gagal cek device: $e");
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

  void _handleRemoteKey(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.select ||
          key == LogicalKeyboardKey.space ||
          key.keyLabel.toLowerCase().contains("dpad center")) {
        await _checkDevice();
      }

      if ([
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
      ].contains(key)) {
        _focusNode.requestFocus();
      }

      if ([
        LogicalKeyboardKey.goBack,
        LogicalKeyboardKey.escape,
        LogicalKeyboardKey.backspace,
      ].contains(key)) {
        SystemNavigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final base = (screen.width + screen.height) / 200;

    return GestureDetector(
      onTap: () {
        // Fokuskan ke TextField kalau layar disentuh
        _focusNode.requestFocus();
      },
      onDoubleTap: () async {
        // Kalau user double-tap layar → sama seperti menekan tombol "Lanjut"
        await _checkDevice();
      },
      child: RawKeyboardListener(
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
                        hintText: 'Contoh: STB-A-1',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: isTVInput ? Colors.white24 : Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(base),
                        ),
                      ),
                      onSubmitted: (_) async =>
                          await _checkDevice(), // enter di keyboard sentuh
                    ),
                  ),
                  SizedBox(height: base * 3),
                  GestureDetector(
                    onTap: () async {
                      if (!isLoading) await _checkDevice();
                    },
                    child: ElevatedButton(
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
                  ),
                  SizedBox(height: base * 4),
                  Text(
                    'Gunakan remote (OK) atau sentuh layar untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: base * 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
