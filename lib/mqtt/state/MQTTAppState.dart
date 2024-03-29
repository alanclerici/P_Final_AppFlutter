import 'dart:convert';

import 'package:flutter/cupertino.dart';
/////////////////////////////////////////////////////////////
///
///           estado mqtt
///
/////////////////////////////////////////////////////////////

enum MQTTAppConnectionState { conected, disconnected, connecting }

enum RemoteConnectionState { conected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;

  String _receivedStatus = '';
  String _receivedTask = '';
  // String _msg = '';
  // String _topic = '';

  var mensajes = Map();

  //leo el json con la data de todos los modulos
  void setReceivedStatus(String msgstatus) {
    _receivedStatus = msgstatus;
    notifyListeners();
  }

  //leo el json con la data de las tareas
  void setReceivedTask(String msgstatus) {
    _receivedTask = msgstatus;
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
  String get getReceivedTask => _receivedTask;
  // List<String> get getReceivedMsg => [_topic, _msg];
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

  //si estoy conectadoen local devuelvo true
  bool get getLocalState =>
      _appConnectionState == MQTTAppConnectionState.conected ? true : false;

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
    _valorSecundario = '';
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
      _causaSecundaria = '',
      _valorSecundario = '';

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

  void setvalorSecundario(String input) {
    _valorSecundario = input;
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
      _valorSecundario //valor de la causa secundaria [9]
    ];
  }

  //devuelve el nombre de la variable de interes para terminar de armar el topico causa
  String getVarSxxxxx() {
    switch (_varCausa) {
      case 'Temp.':
        return 'temperatura';
      case 'Hum.':
        return 'humedad';
      default:
        return '';
    }
  }

  String getEfectoRxxxx() {
    switch (_tipoEfecto) {
      case 'Encender':
        return 'on';
      case 'Apagar':
        return 'off';
      case 'Invertir':
        return 'tog';
      default:
        return '';
    }
  }

  String getEfectoRevertirRxxxx() {
    switch (_tipoEfecto) {
      case 'Encender':
        return 'off';
      case 'Apagar':
        return 'on';
      case 'Invertir':
        return 'tog';
      default:
        return '';
    }
  }

  String getMsgNewTarea() {
    // si por alguna razon algun dato no es valido en el proceso, devuelvo '' (vacio)
    String msg,
        topicoCausa,
        topicoEfecto,
        msgEfecto,
        msgSecundaria = '',
        aux = '';
    List<String> lista = [];

    // obtengo lista de tareas activas (solo nombres)
    if (_receivedTask.isNotEmpty) {
      for (var i in jsonDecode(_receivedTask)) {
        aux = i['nombre'];
        lista.add(aux.toLowerCase());
      }
    }
    //valido el nombre
    if (lista.contains(_nombre.toLowerCase())) {
      return '';
    }

    //causa
    if (_moduloCausa == 'Tiempo') {
      topicoCausa = 'Tiempo';
      _tipoCausa = _varCausa; //se podria hacer mas legible
    } else {
      topicoCausa = '/mod/$_moduloCausa/';
      switch (_moduloCausa[0]) {
        case 'S':
          topicoCausa = topicoCausa + getVarSxxxxx();
          break;
        default:
          return '';
      }
    }

    //efecto
    switch (_moduloEfecto[0]) {
      case 'R':
        topicoEfecto = '/mod/$_moduloEfecto/comandos';
        msgEfecto = getEfectoRxxxx();
        break;
      default:
        return '';
    }

    //efecto secundario
    if (_tipoSecundario.isNotEmpty && _tipoSecundario != 'Ninguno') {
      //implementado solo para revertir (por ahora)
      switch (_moduloEfecto[0]) {
        case 'R':
          msgSecundaria = getEfectoRevertirRxxxx();
          break;
        default:
          break;
      }
    } else {}

    if (_nombre.isNotEmpty &&
        _tipoCausa.isNotEmpty &&
        _valorCausa.isNotEmpty &&
        topicoEfecto.isNotEmpty &&
        msgEfecto.isNotEmpty) {
      msg =
          '$_nombre;$topicoCausa-$_tipoCausa-$_valorCausa;$topicoEfecto-$msgEfecto;$_tipoSecundario-$_causaSecundaria-$_valorSecundario-$msgSecundaria';
      return msg;
    } else {
      return '';
    }
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
            'Igual a',
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

  /////////////////////////////////////////////////////////////
  ///
  ///           estado firebase
  ///
  /////////////////////////////////////////////////////////////

  RemoteConnectionState _remoteConnectionState =
      RemoteConnectionState.disconnected;

  RemoteConnectionState get getRemoteConnectionState => _remoteConnectionState;

  bool get getRemoteState =>
      _remoteConnectionState == RemoteConnectionState.conected ? true : false;

  String _uid = '';
  String _serverId = '';

  void setRemoteConnectionState(RemoteConnectionState state) {
    _remoteConnectionState = state;
    notifyListeners();
  }

  void setServerId(String id) {
    _serverId = id;
    //no notifico porque esta funcion va de la mano con otra qye lo hace
  }

  String getServerId() {
    return _serverId;
  }

  void setFbUid(String id) {
    _uid = id;
    //no notifico porque esta funcion va de la mano con otra qye lo hace
  }

  String getFbUid() {
    return _uid;
  }

  //conexion general
  String getConnectionGeneral() {
    if (_appConnectionState == MQTTAppConnectionState.conected) {
      return 'local';
    } else if (_remoteConnectionState == RemoteConnectionState.conected) {
      return 'remota';
    } else {
      return 'desconectado';
    }
  }
}
