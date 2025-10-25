import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttConnection {
  MqttServerClient? client;
  bool isConnected = false;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  /// 🔌 Connect ke MQTT broker
  Future<void> connect({
    required String clientId,
    required String broker,
    required int port,
    required String username,
    required String password,
    required List<String> topics,
    required Function(Map<String, dynamic>) onMessage,
  }) async {
    if (isConnected && client != null) {
      print("⚠️ Already connected, skipping reconnect");
      return;
    }

    // Disconnect dulu jika ada koneksi lama
    await _disposeClient();

    // 🔧 Setup client
    client = MqttServerClient.withPort(broker, clientId, port)
      ..logging(on: false)
      ..keepAlivePeriod = 60
      ..secure = true;

    client!.onConnected = () {
      print("✅ MQTT connected callback");
    };

    client!.onDisconnected = () {
      print("⚠️ MQTT disconnected — scheduling reconnect...");
      isConnected = false;
      _scheduleReconnect(
        broker,
        port,
        clientId,
        username,
        password,
        topics,
        onMessage,
      );
    };

    client!.securityContext = SecurityContext.defaultContext;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .withProtocolName('MQTT')
        .withProtocolVersion(4) // MQTT 3.1.1
        .keepAliveFor(60)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client!.connectionMessage = connMess;

    try {
      print("📡 Connecting securely to $broker:$port ...");
      await client!.connect();
      await Future.delayed(const Duration(milliseconds: 500));

      final status = client!.connectionStatus;
      if (status?.state != MqttConnectionState.connected) {
        throw Exception("❌ MQTT failed: ${status?.returnCode}");
      }

      isConnected = true;
      print("✅ MQTT connected successfully.");

      // Subscribe ke topik
      for (final topic in topics) {
        client!.subscribe(topic, MqttQos.atMostOnce);
        print("🎯 Subscribed to $topic");
      }

      client!.updates?.listen((
        List<MqttReceivedMessage<MqttMessage>> messages,
      ) {
        final recMess = messages[0].payload as MqttPublishMessage;
        final topic = messages[0].topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        print("📨 [MQTT] TOPIC: $topic");
        print("📨 [MQTT] PAYLOAD: $payload");
      });

      // ✅ Inisialisasi listener sekali saja (dan tetap aktif)
      _subscription?.cancel();
      _subscription = client!.updates?.listen((messages) {
        if (messages.isEmpty) return;
        final recMess = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        final topic = messages[0].topic;
        print("📨 [$topic] → $payload");

        try {
          final data = jsonDecode(payload);
          if (data is Map<String, dynamic>) {
            onMessage(data);
          }
        } catch (e) {
          print("⚠️ MQTT decode error: $e");
        }
      });
    } catch (e) {
      print("❌ MQTT connection error: $e");
      isConnected = false;
      _scheduleReconnect(
        broker,
        port,
        clientId,
        username,
        password,
        topics,
        onMessage,
      );
    }
  }

  /// 🔁 Reconnect otomatis
  void _scheduleReconnect(
    String broker,
    int port,
    String clientId,
    String username,
    String password,
    List<String> topics,
    Function(Map<String, dynamic>) onMessage,
  ) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      print("🔄 Reconnecting MQTT...");
      try {
        await connect(
          clientId: clientId,
          broker: broker,
          port: port,
          username: username,
          password: password,
          topics: topics,
          onMessage: onMessage,
        );
        if (isConnected) {
          print("✅ Reconnected MQTT successfully");
          timer.cancel();
        }
      } catch (e) {
        print("⚠️ Reconnect failed: $e");
      }
    });
  }

  /// 🧹 Hapus client lama
  Future<void> _disposeClient() async {
    try {
      _subscription?.cancel();
      client?.disconnect();
      print("🧹 Old MQTT client disposed.");
    } catch (e) {
      print("⚠️ Error disposing old client: $e");
    } finally {
      _subscription = null;
      client = null;
      isConnected = false;
    }
  }

  /// 📴 Manual disconnect
  void disconnect() {
    print("🔌 Disconnecting MQTT manually...");
    _disposeClient();
  }
}
