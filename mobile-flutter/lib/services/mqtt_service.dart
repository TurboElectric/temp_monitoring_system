import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late MqttServerClient client;
  StreamController<dynamic> _streamController = StreamController.broadcast();

  Stream<dynamic> get stream => _streamController.stream;

  Future<void> connect() async {
    client = MqttServerClient.withPort('your-mqtt-ip', 'flutter_client', 1883);
    client.logging(on: true);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .keepAliveFor(60);

    client.connectionMessage = connMsg;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _onConnected() {
    clientensors/all', MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _streamController.add(jsonDecode(pt));
    });
  }

  void _onSubscribed(String topic) => print('Subscribed to: $topic');

  void _onDisconnected() => print('MQTT disconnected');
}