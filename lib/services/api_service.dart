import 'package:dio/dio.dart';
import 'device_identifier.dart';
import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl:
            'https://platform.akses.net.id/api/launcher.api', // ✅ sesuai Laravel prefix
        // 'http://192.168.18.125:8000/api/launcher.api', // ✅ sesuai Laravel prefix
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'X-Launcher-Key': 'MySecretKey123',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            print('⚠️ Timeout - retrying...');
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

  // 🆕 Register device
  Future<Map<String, dynamic>> registerDevice(String deviceId) async {
    try {
      final response = await _dio.get(
        '/register',
        queryParameters: {'device_id': deviceId},
      );
      print("✅ Register Device Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      print('❌ Register error: ${e.response?.data}');
      return {'status': false, 'message': 'Failed to register device'};
    }
  }

  // ⚙️ Ambil konfigurasi device (hotel & room)
  Future<Map<String, dynamic>> getDeviceConfigAuto(String deviceId) async {
    try {
      final response = await _dio.get(
        '/config',
        queryParameters: {'device_id': deviceId},
      );
      print("✅ Config Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      print('❌ Config error: ${e.response?.data}');
      return {'status': false, 'message': 'Failed to get config'};
    }
  }

  // 🏨 Ambil data awal hotel & room (untuk booting dan IdleScreen)
  Future<Map<String, dynamic>> getLauncherData(String deviceId) async {
    try {
      final response = await _dio.get(
        '/all',
        queryParameters: {'device_id': deviceId},
      );
      print("✅ Launcher Data Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      print('❌ Launcher data error: ${e.response?.data}');
      return {'error': 'Failed to get launcher data'};
    }
  }

  // 📰 Ambil konten info hotel
  Future<Map<String, dynamic>> getContent(String deviceId) async {
    try {
      final response = await _dio.get(
        '/content',
        queryParameters: {'device_id': deviceId},
      );
      print("✅ Content Data Response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      print('❌ Content error: ${e.response?.data}');
      return {'error': 'Failed to get content'};
    }
  }

  // 🖼️ Update background realtime via MQTT
  Future<bool> updateBackground({
    required int hotelId,
    required String backgroundPath,
    int? roomId,
  }) async {
    try {
      final response = await _dio.post(
        '/update-background',
        data: {
          'hotel_id': hotelId,
          'room_id': roomId,
          'background_image_url': backgroundPath,
        },
      );
      print("✅ Background updated: ${response.statusCode}");
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('❌ Background update error: ${e.response?.data}');
      return false;
    }
  }

  // 🔐 Verifikasi PIN Admin
  Future<Map<String, dynamic>> verifyPin(String pin) async {
    try {
      final response = await _dio.post('/verify-pin', data: {'pin': pin});
      print("✅ Verify PIN response: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      print('❌ Verify PIN error: ${e.response?.data}');
      return {'status': false, 'message': 'PIN verification failed'};
    }
  }
}
