// import 'package:dio/dio.dart';

// class ApiService {
//   final Dio dio = Dio(
//     BaseOptions(baseUrl: 'http://10.18.57.10:8000/api/launcher'),
//   );

//   Future<Map<String, dynamic>> getConfig(String deviceId) async {
//     final res = await dio.get(
//       '/config',
//       queryParameters: {'device_id': deviceId},
//       options: Options(headers: {'X-Launcher-Key': 'MySecretKey123'}),
//     );
//     return res.data;
//   }

//   Future<Map<String, dynamic>> getLauncherData(String deviceId) async {
//     final res = await dio.get(
//       '/all',
//       queryParameters: {'device_id': deviceId},
//       options: Options(headers: {'X-Launcher-Key': 'MySecretKey123'}),
//     );
//     return res.data;
//   }
// }

import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.18.57.10:8000', // 🟢 IP laptop kamu
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'X-Launcher-Key': 'MySecretKey123', // 🧩 sama seperti simulator Node.js
      },
    ),
  );

  /// 🧩 Ambil konfigurasi STB berdasarkan device_id
  Future<Map<String, dynamic>> getDeviceConfig(String deviceId) async {
    try {
      print('📡 Fetching config for device: $deviceId');
      final response = await _dio.get(
        '/api/launcher/config', // ✅ sama seperti di Laravel
        queryParameters: {'device_id': deviceId},
      );

      print('✅ Config response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Config error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// 🏨 Ambil semua data launcher (hotel, room, banner, menu, dst)
  Future<Map<String, dynamic>> getLauncherData(String deviceId) async {
    try {
      print('📡 Fetching launcher data for: $deviceId');
      final response = await _dio.get(
        '/api/launcher/all', // ✅ sesuai dengan simulator Node.js
        queryParameters: {'device_id': deviceId},
      );

      print('✅ Launcher data response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ API error: ${e.response?.statusCode} → ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
