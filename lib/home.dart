import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/iconos.dart';
import 'package:smart_home/layoutIR.dart';

class Home extends StatelessWidget {
  const Home(this.manager, {super.key});
  final MQTTManager manager;
  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);
    List<Widget> zonas = [];
    List<String> aux = [];

    if (estadomqtt.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(estadomqtt.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          if (!aux.contains(i['zona'])) {
            aux.add(i['zona']);
            zonas.add(Zona(manager, i['zona']));
          }
        }
      }
    }
    return ListView(
      children: zonas,
    );
  }
}

class Zona extends StatelessWidget {
  const Zona(this.manager, this.nombrezona);
  final MQTTManager manager;
  final String nombrezona;

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);

    int cont = 0;
    List<Widget> mods = [];
    List<Widget> grilla = []; //arreglo de row

    grilla.add(Container(
        child: Text(nombrezona, style: const TextStyle(color: Colors.white))));

    if (estadomqtt.getReceivedStatus.isNotEmpty) {
      //recorro para cada elemento del JSON
      for (var i in jsonDecode(estadomqtt.getReceivedStatus)) {
        //si el elemento esta activo y corresponde con la zona
        if (i['zona'] == nombrezona && i['estado'] == 'activo') {
          //en caso de que sea un modulo de sensores, agrega 3 iconos a la lista
          if (i['id'][0] == 'S') {
            grilla.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconoModSens(i['id'], 'temperatura'),
                IconoModSens(i['id'], 'humedad'),
                IconoModSens(i['id'], 'presion'),
              ],
            ));
          }
          if (i['id'][0] == 'L') {
            grilla.add(LayoutTv(manager, i['funcion'], i['id'], 'normal'));
            //me aseguro de mandar el msg para que el mod este en funcionamiento normal
            // manager.publish('/mod/${i['id']}/comandos', 'normal');
          }
        }
      }
      for (var i in jsonDecode(estadomqtt.getReceivedStatus)) {
        //si el elemento esta activo y corresponde con la zona
        if (i['zona'] == nombrezona && i['estado'] == 'activo') {
          //en caso de que sea un modulo de rele agrega un icono a una lista auxiliar
          if (i['id'][0] == 'R') {
            cont++;
            mods.add(IconoModRele(manager, i['id']));
          }
          //si se juntan 3 rele los agrega a la lista final
          if (cont > 0 && cont % 3 == 0) {
            grilla.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: mods.sublist(cont - 3),
            ));
          }

          //si juntamos menos de 3 elementos, los agregamos al final
          if (cont % 3 > 0) {
            grilla.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: mods.sublist(cont - (cont % 3)),
            ));
          }
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Column(
        children: grilla,
      ),
    );
  }
}
