import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager {
  // Private instance of client
  MQTTAppState _currentState = MQTTAppState();
  MqttServerClient? _client;
  String _identifier = '';
  String _host = '';
  String _topic = '';
  // String _clave = '';

  // Constructor
  // ignore: sort_constructors_first

  void set(String host, String topic, String identifier, MQTTAppState state) {
    _identifier = identifier;
    _host = host;
    _topic = topic;
    _currentState = state;
  }

  void initializeMQTTClient(String clave) {
    _client = MqttServerClient(_host, _identifier);
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
    // print('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      // print('EXAMPLE::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      // print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    // print('Disconnected');
    _client!.disconnect();
  }

  void publish(String topico, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topico, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    // print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    // print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      // print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.local);
    // print('EXAMPLE::Mosquitto client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      // final MqttPublishMessage recMess = c![0].payload;
      final String msg =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic.toString() == '/mod/modsactivos') {
        _currentState.setReceivedStatus(msg);
      } else if (c[0].topic.toString() == '/mod/tareasactivas') {
        _currentState.setReceivedTask(msg);
      } else {
        _currentState.setReceivedMsg(c[0].topic.toString(), msg.toString());
      }
      // print(
      //     'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $msg -->');
      // print('');
    });
  }
}
