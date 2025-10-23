import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String deviceId;
  final String username;
  final String password;
  final String broker;
  final int port;
  final Function(Map<String, dynamic>) onMessage;

  late MqttServerClient client;

  MqttService({
    required this.deviceId,
    required this.username,
    required this.password,
    required this.broker,
    required this.port,
    required this.onMessage,
  });

  Future<void> connect(int hotelId, int roomId) async {
    client = MqttServerClient(broker, 'stb_$deviceId');
    client.port = port;
    client.secure = true;
    client.logging(on: false);

    client.connectionMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .keepAliveFor(60)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    try {
      await client.connect();
      print('✅ Connected to MQTT');
      final topic = 'hotel/$hotelId/room/$roomId';
      client.subscribe(topic, MqttQos.atMostOnce);
      print('📡 Subscribed to $topic');

      client.updates!.listen((messages) {
        final MqttPublishMessage recMsg =
            messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMsg.payload.message,
        );
        final data = jsonDecode(payload);
        onMessage(data);
      });
    } catch (e) {
      print('❌ MQTT Error: $e');
    }
  }
}
