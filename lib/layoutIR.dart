import 'package:flutter/material.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/funciones.dart';
import 'package:smart_home/iconos.dart';

class LayoutTv extends StatelessWidget {
  LayoutTv(this.manager, this.distbotones, this.id, this.modo, {super.key});
  final String id, modo, distbotones;
  MQTTManager manager;
  @override
  Widget build(BuildContext context) {
    final List<String> aux = distbotones.split(';');
    var boton_codigo = Map();
    boton_codigo = initMap();
    if (modo == 'normal' && aux.isNotEmpty) {
      for (var i in aux) {
        final List<String> aux2 = i.split(':');
        if (aux2.length > 1) {
          boton_codigo.update(
            i.split(':')[0],
            (value) => i.split(':')[1],
            ifAbsent: () => i.split(':')[1],
          );
        }
      }
    }
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 180,
            width: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(
                        manager, 'power', id, 'b06', modo, boton_codigo['b06']),
                    IconoCtrlIR(manager, 'source', id, 'b07', modo,
                        boton_codigo['b07']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(manager, 'canal+', id, 'b08', modo,
                        boton_codigo['b08']),
                    IconoCtrlIR(
                        manager, 'vol+', id, 'b09', modo, boton_codigo['b09']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(manager, 'canal-', id, 'b10', modo,
                        boton_codigo['b10']),
                    IconoCtrlIR(
                        manager, 'vol-', id, 'b11', modo, boton_codigo['b11']),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 170,
            width: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(id, style: const TextStyle(color: Colors.white)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(manager, 'arriba', id, 'b01', modo,
                        boton_codigo['b12']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(
                        manager, 'izq', id, 'b02', modo, boton_codigo['b12']),
                    IconoCtrlIR(
                        manager, 'enter', id, 'b03', modo, boton_codigo['b12']),
                    IconoCtrlIR(
                        manager, 'der', id, 'b04', modo, boton_codigo['b12']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(
                        manager, 'abajo', id, 'b05', modo, boton_codigo['b12']),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LayoutAire extends StatelessWidget {
  LayoutAire(this.manager, this.distbotones, this.id, this.modo, {super.key});
  final String id, modo, distbotones;
  MQTTManager manager;
  @override
  Widget build(BuildContext context) {
    final List<String> aux = distbotones.split(';');
    var boton_codigo = Map();
    boton_codigo = initMap();
    if (modo == 'normal' && aux.isNotEmpty) {
      for (var i in aux) {
        final List<String> aux2 = i.split(':');
        if (aux2.length > 1) {
          boton_codigo.update(
            i.split(':')[0],
            (value) => i.split(':')[1],
            ifAbsent: () => i.split(':')[1],
          );
        }
      }
    }
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
        left: 15,
        right: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconoCtrlIR(manager, 'power', id, 'b12', modo, boton_codigo['b12']),
          IconoCtrlIR(manager, 'mode', id, 'b13', modo, boton_codigo['b13']),
          IconoCtrlIR(manager, 'T+', id, 'b14', modo, boton_codigo['b14']),
          IconoCtrlIR(manager, 'T-', id, 'b15', modo, boton_codigo['b15']),
          IconoCtrlIR(manager, 'swing', id, 'b16', modo, boton_codigo['b16']),
        ],
      ),
    );
  }
}
