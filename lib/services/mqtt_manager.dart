// import 'mqtt_connection.dart';

// class MqttManager {
//   static final MqttManager instance = MqttManager._internal();
//   factory MqttManager() => instance;
//   MqttManager._internal();

//   final MqttConnection _mqtt = MqttConnection();

//   Future<void> connect({
//     required String deviceId,
//     required int hotelId,
//     required int roomId,
//     required Function(Map<String, dynamic>) onMessage,
//   }) async {
//     print("🚀 MQTT init for Device: $deviceId → Hotel $hotelId, Room $roomId");

//     await _mqtt.connect(
//       clientId: 'stb_$deviceId',
//       broker: '460574145edb4ca887c6a3911268f3c4.s1.eu.hivemq.cloud',
//       port: 8883,
//       username: 'username',
//       password: 'Password123',
//       // ⚡ Gunakan lebih banyak topik agar tidak ketinggalan update global
//       topics: [
//         'hotel/$hotelId/room/$roomId', // khusus room ini
//         'hotel/$hotelId/global', // broadcast semua kamar
//         'hotel/$hotelId/launcher', // khusus launcher update
//         'hotel/$hotelId/video', // update video
//         'hotel/$hotelId/launcher/update-background',
//       ],
//       onMessage: (data) {
//         print("📨 MQTT Message Received: $data"); // log semua
//         try {
//           onMessage(data);
//         } catch (e) {
//           print("⚠️ Error in onMessage handler: $e");
//         }
//       },
//     );
//   }

//   void disconnect() {
//     print("🔌 Disconnecting MQTT...");
//     _mqtt.disconnect();
//   }
// }

import 'mqtt_connection.dart';

class MqttManager {
  static final MqttManager instance = MqttManager._internal();
  factory MqttManager() => instance;
  MqttManager._internal();

  final MqttConnection _mqtt = MqttConnection();

  /// 🌆 Simpan background & logo global agar bisa diakses dari mana saja
  String? currentBackgroundUrl;
  String? currentLogoUrl;

  Future<void> connect({
    required String deviceId,
    required int hotelId,
    required int roomId,
    required Function(Map<String, dynamic>) onMessage,
  }) async {
    print("🚀 MQTT init for Device: $deviceId → Hotel $hotelId, Room $roomId");

    await _mqtt.connect(
      clientId: 'stb_$deviceId',
      broker: '460574145edb4ca887c6a3911268f3c4.s1.eu.hivemq.cloud',
      port: 8883,
      username: 'username',
      password: 'Password123',
      topics: [
        'hotel/$hotelId/room/$roomId', // khusus room ini
        'hotel/$hotelId/global', // broadcast semua kamar
        'hotel/$hotelId/launcher', // update global launcher
        'hotel/$hotelId/video', // update video
        'hotel/$hotelId/launcher/update-background',
      ],
      onMessage: (data) {
        print("📨 MQTT Message Received: $data");

        try {
          if (data.containsKey('event')) {
            final event = data['event'];

            switch (event) {
              case 'launcher_update':
                if (data['background_image_url'] != null &&
                    data['background_image_url'].toString().isNotEmpty) {
                  currentBackgroundUrl = data['background_image_url'];
                  print("🌆 Updated Global Background → $currentBackgroundUrl");
                }

                if (data['logo_url'] != null &&
                    data['logo_url'].toString().isNotEmpty) {
                  currentLogoUrl = data['logo_url'];
                  print("🏨 Updated Global Logo → $currentLogoUrl");
                }
                break;

              case 'content_update':
                print("📰 Received content update from MQTT:");
                print(data);
                // ✅ Kirim data ke callback handler biar Flutter UI update
                onMessage(data);
                break;

              default:
                print("ℹ️ Unknown MQTT event: $event");
                onMessage(data);
            }
          }

          // Teruskan pesan ke handler aslinya
          onMessage(data);
        } catch (e) {
          print("⚠️ Error in onMessage handler: $e");
        }
      },
    );
  }

  void disconnect() {
    print("🔌 Disconnecting MQTT...");
    _mqtt.disconnect();
  }
}
