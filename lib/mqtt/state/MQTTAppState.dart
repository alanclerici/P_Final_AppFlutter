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
  ///           estado new tarea
  ///
  ///
  /////////////////////////////////////////////////////////////

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

  void resetAll() {
    _moduloCausa = '';
    _varCausa = '';
    _tipoCausa = '';
    _valorCausa = '20';
    _moduloEfecto = '';
    _tipoEfecto = '';
    _nombre = '';
    _tipoSecundario = 'Ninguno';
    _causaSecundaria = '';
  }

  //-------------------------------------estados seleccionados
  String _moduloCausa = '',
      _varCausa = '',
      _tipoCausa = '',
      _valorCausa = '20',
      _moduloEfecto = '',
      _tipoEfecto = '',
      _nombre = '',
      _tipoSecundario = 'Ninguno',
      _causaSecundaria = '';

  //---set
  void setmoduloCausa(String input) {
    _moduloCausa = input;
    notifyListeners();
  }

  void setvarCausa(String input) {
    _varCausa = input;
    notifyListeners();
  }

  void settipoCausa(String input) {
    _tipoCausa = input;
    notifyListeners();
  }

  void setvalorCausa(String input) {
    _valorCausa = input;
    notifyListeners();
  }

  void setmoduloEfecto(String input) {
    _moduloEfecto = input;
    notifyListeners();
  }

  void settipoEfecto(String input) {
    _tipoEfecto = input;
    notifyListeners();
  }

  void setnombre(String input) {
    _nombre = input;
    notifyListeners();
  }

  void settipoSecundario(String input) {
    _tipoSecundario = input;
    notifyListeners();
  }

  void setcausaSecundaria(String input) {
    _causaSecundaria = input;
    notifyListeners();
  }

  //---get
  String get getModuloCausa => _moduloCausa;
  String get getModuloEfecto => _moduloEfecto;
  String get getValorCausa => _valorCausa;

  String get getVarCausa => _varCausa;
  String get getCausaSecundaria => _causaSecundaria;
  String get getTipoSecundario => _tipoSecundario;

  List<String> getAll() {
    return [
      _nombre, //nombre de la tarea [0]
      _moduloCausa, //tipo de modulo para la causa [1]
      _varCausa, //variable-tipo para la causa [2]
      _tipoCausa, //tipo de comparacion [3]
      _valorCausa, //valor para causa [4]
      _moduloEfecto, //tipo de modulo para el efecto [5]
      _tipoEfecto, //tipo de efecto [6]
      _tipoSecundario, //tipo de efecto secundario [7]
      _causaSecundaria, //causa que lo genera [8]
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
            'Var.',
            'Periodo',
            'Hora exacta',
          ];
        case 'S':
          return [
            'Var.',
            'Temp.',
            'Hum.',
          ];
        case 'M':
          return [
            'Var.',
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
            'Tipo',
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
            'Accion',
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

  List<String> getListTipoSecundario() {
    if (_moduloEfecto.isNotEmpty) {
      switch (_moduloEfecto[0]) {
        case 'R':
          return [
            'Ninguno',
            'Revertir',
          ];
        default:
          return ['tipo invalido'];
      }
    } else {
      return ['tipo invalido'];
    }
  }

  List<String> getListCausaSecundaria() {
    if (_moduloEfecto.isNotEmpty) {
      switch (_moduloEfecto[0]) {
        case 'R':
          return [
            'Causa',
            'Despues de',
          ];
        default:
          return ['tipo invalido'];
      }
    } else {
      return ['tipo invalido'];
    }
  }
}
