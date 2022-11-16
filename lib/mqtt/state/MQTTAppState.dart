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

  /////////////////////////////////////////////////////////////
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  //-------------------------------------listas de estado actual
  List<String> listModulos = ['Modulo', 'Tiempo'];

  //borro modulos activos (data que llega de mqtt)
  void resetModulo() {
    listModulos = ['Modulo', 'Tiempo'];
  }

  //agrego modulo activos (data que llega de mqtt)
  void addModulo(String modulo) {
    listModulos.add(modulo);
  }

  //-------------------------------------estados seleccionados
  String _moduloCausa = '',
      _varCausa = '',
      _tipoCausa = '',
      _valorCausa = '',
      _moduloEfecto = '',
      _tipoEfecto = '',
      _nombre = '';

  //---set
  void moduloCausa(String input) {
    _moduloCausa = input;
    notifyListeners();
  }

  void varCausa(String input) {
    _varCausa = input;
    notifyListeners();
  }

  void tipoCausa(String input) {
    _tipoCausa = input;
    notifyListeners();
  }

  void valorCausa(String input) {
    _valorCausa = input;
    notifyListeners();
  }

  void moduloEfecto(String input) {
    _moduloEfecto = input;
    notifyListeners();
  }

  void tipoEfecto(String input) {
    _tipoEfecto = input;
    notifyListeners();
  }

  void nombre(String input) {
    _nombre = input;
    notifyListeners();
  }

  //---get
  String get getModuloCausa => _moduloCausa;
  String get getModuloEfecto => _moduloEfecto;

  List<String> getAll() {
    return [
      _moduloCausa,
      _varCausa,
      _tipoCausa,
      _valorCausa,
      _moduloEfecto,
      _tipoEfecto,
      _nombre,
    ];
  }

  //devuelvo modulos activos (data que llega de mqtt)
  List<String> getListModulos() {
    return listModulos;
  }

  //segun el modulo devuelvo list de variable a utilzar como causa
  List<String> getListVarCausa() {
    if (_moduloCausa.isNotEmpty) {
      switch (_moduloCausa[0]) {
        case 'T':
          return [
            'Periodo',
            'Hora exacta',
          ];
        case 'S':
          return [
            'Temp.',
            'Hum.',
            'Pres.',
          ];
        case 'M':
          return [
            'Detect. Mov.',
          ];
        default:
          return ['tipo invalido'];
      }
    } else {
      return ['tipo invalido'];
    }
  }

  //por ahora solo util para S00001
  List<String> getListTipoCausa() {
    if (_moduloCausa.isNotEmpty) {
      switch (_moduloCausa[0]) {
        case 'S':
          return [
            'Mayor que',
            'Menor que',
            'igual a',
          ];
        default:
          return ['tipo invalido'];
      }
    } else {
      return ['tipo invalido'];
    }
  }

  List<String> getListTipoEfecto() {
    if (_moduloEfecto.isNotEmpty) {
      switch (_moduloEfecto[0]) {
        case 'R':
          return [
            'Encender',
            'Apagar',
            'Invertir',
          ];
        default:
          return ['tipo invalido'];
      }
    } else {
      return ['tipo invalido'];
    }
  }
}
