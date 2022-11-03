import 'package:flutter/cupertino.dart';

enum MQTTAppConnectionState { local, remote, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedStatus = '';
  // String _msg = '';
  // String _topic = '';

  var mensajes = Map();

  //leo el json con la data de todos los modulos
  void setReceivedStatus(String msgstatus) {
    _receivedStatus = msgstatus;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  //todos los mensajes menos los de status
  void setReceivedMsg(String topico, String mensaje) {
    // _msg = mensaje;
    // _topic = topico;
    mensajes.update(topico, (value) => mensaje, ifAbsent: () => mensaje);
    // print('$_topic:::::$_msg');
    notifyListeners();
  }

  String get getReceivedStatus => _receivedStatus;
  // List<String> get getReceivedMsg => [_topic, _msg];
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

  String getMensajes(String topico) {
    if (mensajes.containsKey(topico)) {
      return mensajes[topico];
    } else {
      return '';
    }
  }
}
