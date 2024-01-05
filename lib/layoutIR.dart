import 'package:flutter/material.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/funciones.dart';
import 'package:smart_home/iconos.dart';

class LayoutTv extends StatelessWidget {
  LayoutTv(this.estadomqtt, this.manager, this.distbotones, this.id, this.modo,
      {super.key});
  final String id, modo, distbotones;
  final MQTTAppState estadomqtt;
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
                    IconoCtrlIR(estadomqtt, manager, 'power', id, 'b06', modo,
                        boton_codigo['b06']),
                    IconoCtrlIR(estadomqtt, manager, 'source', id, 'b07', modo,
                        boton_codigo['b07']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(estadomqtt, manager, 'canal+', id, 'b08', modo,
                        boton_codigo['b08']),
                    IconoCtrlIR(estadomqtt, manager, 'vol+', id, 'b09', modo,
                        boton_codigo['b09']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(estadomqtt, manager, 'canal-', id, 'b10', modo,
                        boton_codigo['b10']),
                    IconoCtrlIR(estadomqtt, manager, 'vol-', id, 'b11', modo,
                        boton_codigo['b11']),
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
                    IconoCtrlIR(estadomqtt, manager, 'arriba', id, 'b01', modo,
                        boton_codigo['b12']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(estadomqtt, manager, 'izq', id, 'b02', modo,
                        boton_codigo['b12']),
                    IconoCtrlIR(estadomqtt, manager, 'enter', id, 'b03', modo,
                        boton_codigo['b12']),
                    IconoCtrlIR(estadomqtt, manager, 'der', id, 'b04', modo,
                        boton_codigo['b12']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconoCtrlIR(estadomqtt, manager, 'abajo', id, 'b05', modo,
                        boton_codigo['b12']),
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
