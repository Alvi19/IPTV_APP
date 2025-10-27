import 'api_service.dart';

/// Helper untuk mengambil atau mendaftarkan device_id dari API Laravel.
/// Tidak menggunakan local storage sama sekali.
/// Setiap kali dipanggil, langsung memverifikasi / mendaftarkan ke server.
class DeviceIdentifier {
  /// Ambil `device_id` langsung dari server Laravel.
  /// - Jika device sudah ada → server mengembalikan data existing.
  /// - Jika belum ada → server otomatis mendaftarkannya.
  static Future<String> getDeviceId(String inputDeviceId) async {
    try {
      final api = ApiService();

      if (inputDeviceId.isEmpty) {
        print("⚠️ Device ID kosong, tidak bisa dilanjutkan.");
        return 'UNKNOWN_DEVICE';
      }

      print("📡 Verifying device_id to API: $inputDeviceId");

      // Cek apakah device ada di database
      final checkResponse = await api.checkDevice(inputDeviceId);

      if (checkResponse['status'] == true) {
        print("✅ Device ditemukan di database: $inputDeviceId");
        return inputDeviceId;
      }

      // Jika device belum terdaftar → daftarkan baru ke Laravel
      print("🆕 Device belum ada, mendaftarkan...");
      final newId = await api.registerDevice(inputDeviceId);

      if (newId != null && newId.isNotEmpty) {
        print("✅ Device berhasil didaftarkan: $newId");
        return newId;
      }

      print("⚠️ Gagal mendaftarkan device ke server.");
      return 'UNKNOWN_DEVICE';
    } catch (e) {
      print("❌ Gagal mendapatkan device_id dari server: $e");
      return 'UNKNOWN_DEVICE';
    }
  }

  /// Fungsi ini tidak perlu lagi karena tidak ada penyimpanan lokal.
  static Future<void> clearDeviceId() async {
    print(
      "🧹 clearDeviceId() dipanggil — tapi SharedPreferences sudah dihapus, tidak ada yang perlu dibersihkan.",
    );
  }
}
