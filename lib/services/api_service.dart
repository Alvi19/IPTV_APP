import 'package:dio/dio.dart';
import 'device_identifier.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.61.255.10:8000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'X-Launcher-Key': 'MySecretKey123',
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

  /// ⚙️ Get device configuration (dipanggil saat boot STB)
  Future<Map<String, dynamic>> getDeviceConfigAuto() async {
    final deviceId = await DeviceIdentifier.getDeviceId();
    print('🆔 Device ID detected: $deviceId');

    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.get(
        '/api/launcher/launcher/config',
        queryParameters: {'device_id': deviceId},
      );
      stopwatch.stop();
      print('⏱️ Config fetched in ${stopwatch.elapsed.inSeconds}s');
      return response.data;
    } on DioException catch (e) {
      print('❌ Config error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      rethrow;
    }
  }

  /// 🏨 Ambil semua data awal hotel (video, logo, background, room)
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
      print('❌ API error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      rethrow;
    }
  }

  /// 📜 Ambil konten dinamis hotel (facilities, promo, policy, dll)
  Future<Map<String, dynamic>> getContent(String deviceId) async {
    try {
      print('📰 Fetching content data for: $deviceId');
      final response = await _dio.get(
        '/api/launcher/data', // ✅ ini satu-satunya yang TIDAK double launcher
        queryParameters: {'device_id': deviceId},
      );
      print('✅ Content data response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Content API error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) print('Response data: ${e.response?.data}');
      rethrow;
    }
  }

  /// 🎨 Update background (manual trigger dari dashboard admin)
  Future<bool> updateBackground({
    required int hotelId,
    required String backgroundPath,
    int? roomId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/launcher/launcher/update-background',
        data: {
          'hotel_id': hotelId,
          'room_id': roomId,
          'background_image_url': backgroundPath,
        },
      );
      print('🖼️ Background update success: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Background update error: $e');
      return false;
    }
  }
}
