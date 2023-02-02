import 'dart:math';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager {
  // Private instance of client
  MQTTAppState _currentState = MQTTAppState();
  MqttServerClient? _client;
  String _identifier = '';
  final String _topic = '/mod/#';

  void setCurrentState(MQTTAppState state) {
    _identifier = Random()
        .nextInt(100000000)
        .toString(); // genero num aleatorio como id de mqtt
    _currentState = state;
  }

  //password como parametro. el usuario esta harcodeado
  void initializeMQTTClient(String clave, String ip) {
    _client = MqttServerClient(ip, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs("aplicacion", clave);

    _client!.connectionMessage = connMess;
  }

  void connect() async {
    assert(_client != null);
    try {
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      disconnect();
    }
  }

  void disconnect() {
    _client!.disconnect();
  }

  void publish(String topico, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topico, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {}

  /// The unsolicited disconnect callback
  void onDisconnected() {
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {}
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.conected);

    _client!.subscribe(_topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      final String msg =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic.toString() == '/mod/modsactivos') {
        _currentState.setReceivedStatus(msg);
      } else if (c[0].topic.toString() == '/mod/tareasactivas') {
        _currentState.setReceivedTask(msg);
      } else {
        _currentState.setReceivedMsg(c[0].topic.toString(), msg.toString());
      }
    });
  }
}
