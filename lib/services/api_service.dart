import 'package:dio/dio.dart';
import 'device_identifier.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.87.232.10:8000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'X-Launcher-Key': 'MySecretKey123', // Laravel middleware key
        },
      ),
    );

    // 🔁 Retry otomatis jika timeout
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionTimeout) {
            print("⚠️ Timeout detected — retrying...");
            await Future.delayed(const Duration(seconds: 2));
            try {
              final opts = e.requestOptions;
              final cloneReq = await _dio.request(
                opts.path,
                options: Options(method: opts.method, headers: opts.headers),
                data: opts.data,
                queryParameters: opts.queryParameters,
              );
              return handler.resolve(cloneReq);
            } catch (retryError) {
              print("❌ Retry failed: $retryError");
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🆕 1️⃣ REGISTER OR GET DEVICE
  // Laravel: GET /api/launcher/launcher/register?device_id=STB-12345
  // ---------------------------------------------------------------------------
  Future<String?> registerDevice(String deviceId) async {
    try {
      print("🆕 Registering or fetching device: $deviceId");
      final response = await _dio.get(
        '/api/launcher/launcher/register',
        queryParameters: {'device_id': deviceId},
      );

      print("✅ Register response: ${response.data}");

      final data = response.data;
      if (data['status'] == true && data['device'] != null) {
        return data['device']['device_id'];
      }
      return deviceId;
    } on DioException catch (e) {
      print('❌ Register error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // ⚙️ 2️⃣ GET DEVICE CONFIG (tanpa SharedPreferences)
  // Laravel: GET /api/launcher/launcher/config?device_id=STB-12345
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getDeviceConfigAuto(String deviceId) async {
    try {
      if (deviceId.isEmpty) {
        throw Exception("⚠️ device_id tidak boleh kosong");
      }

      print("⚙️ Fetching config for device: $deviceId");

      final response = await _dio.get(
        '/api/launcher/launcher/config',
        queryParameters: {'device_id': deviceId},
      );

      print('📦 Config response: ${response.data}');

      // Laravel mengembalikan struktur { status: true, data: {...} }
      // Jadi kita ambil `data` kalau ada, atau seluruh response
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return data['data'];
      } else {
        return data;
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.message ?? 'Unknown error';
      print('❌ Config error: $status → $message');

      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }

      // Return kosong agar app tetap bisa jalan di mode default
      return {'status': false, 'message': 'Failed to fetch config'};
    } catch (e) {
      print('❌ Unexpected error in getDeviceConfigAuto: $e');
      return {'status': false, 'message': e.toString()};
    }
  }

  // ---------------------------------------------------------------------------
  // 🏨 3️⃣ GET ALL LAUNCHER DATA (hotel + room)
  // Laravel: GET /api/launcher/launcher/all?device_id=STB-12345
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getLauncherData(String deviceId) async {
    try {
      print('📡 Fetching launcher data for: $deviceId');
      final response = await _dio.get(
        '/api/launcher/launcher/all',
        queryParameters: {'device_id': deviceId},
      );

      print('✅ Launcher data response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Launcher API error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 📰 4️⃣ GET CONTENT (banner, promo, facilities, dll)
  // Laravel: GET /api/launcher/data?device_id=STB-12345
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getContent(String deviceId) async {
    try {
      print('📰 Fetching content for: $deviceId');
      final response = await _dio.get(
        '/api/launcher/data',
        queryParameters: {'device_id': deviceId},
      );

      print('✅ Content data response: ${response.statusCode}');
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      print('❌ Content API error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 🖼️ 5️⃣ UPDATE BACKGROUND
  // Laravel: POST /api/launcher/launcher/update-background
  // ---------------------------------------------------------------------------
  Future<bool> updateBackground({
    required int hotelId,
    required String backgroundPath,
    int? roomId,
  }) async {
    try {
      print("🎨 Updating background for hotel_id=$hotelId");
      final response = await _dio.post(
        '/api/launcher/launcher/update-background',
        data: {
          'hotel_id': hotelId,
          'room_id': roomId,
          'background_image_url': backgroundPath,
        },
      );

      print('✅ Background update success: ${response.statusCode}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Background update error: ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔄 6️⃣ CREATE DEVICE ID FROM SERVER
  // ---------------------------------------------------------------------------
  Future<String?> getOrCreateDeviceIdFromServer() async {
    try {
      print("📡 Requesting new or existing device ID from server...");
      final response = await _dio.get('/api/launcher/launcher/register');
      print("✅ Device ID response: ${response.data}");

      final device = response.data['device'] ?? {};
      return device['device_id'] ?? 'UNKNOWN_DEVICE';
    } on DioException catch (e) {
      print('❌ Device ID fetch error: ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      return null;
    }
  }

  Future<Map<String, dynamic>> checkDevice(String deviceId) async {
    try {
      print('🔍 Checking device: $deviceId');
      final response = await _dio.get(
        '/api/launcher/launcher/check',
        queryParameters: {'device_id': deviceId},
      );
      print('✅ Device check response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Device check error: ${e.response?.data}');
      return {
        'status': false,
        'message': e.response?.data['message'] ?? 'Server error',
      };
    }
  }
}
