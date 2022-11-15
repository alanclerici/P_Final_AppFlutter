// import 'package:flutter/material.dart';
// import 'package:smart_home/mqtt/MQTTManager.dart';
// import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class EstadoNuevaTarea {
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
  set moduloCausa(String input) => _moduloCausa = input;
  set varCausa(String input) => _varCausa = input;
  set tipoCausa(String input) => _tipoCausa = input;
  set valorCausa(String input) => _valorCausa = input;

  set moduloEfecto(String input) => _moduloEfecto = input;
  set tipoEfecto(String input) => _tipoEfecto = input;

  set nombre(String input) => _nombre = input;

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
