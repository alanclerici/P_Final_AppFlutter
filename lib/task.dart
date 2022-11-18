import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'mqtt/state/MQTTAppState.dart';

class Task extends StatelessWidget {
  Task(this.manager, {super.key});
  final MQTTManager manager;

  List<Widget> tareas = [];

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);

    if (estadomqtt.getReceivedTask.isNotEmpty) {
      for (var i in jsonDecode(estadomqtt.getReceivedTask)) {
        tareas.add(Tarea(manager, i['nombre'], i['estado']));
      }
    }
    return ListView(
      children: tareas,
    );
  }
}

class Tarea extends StatelessWidget {
  const Tarea(this.manager, this.nombre, this.estado, {super.key});
  final String nombre, estado;
  final MQTTManager manager;

  static const Color grisbase = Color.fromARGB(255, 30, 30, 30);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: TextButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Borrar tarea'),
            content: const Text('Desea borrar esta tarea?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  manager.publish('/task/borrar/', nombre);
                  Navigator.pop(context);
                },
                child: const Text('Borrar'),
              ),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(nombre,
                    style: const TextStyle(fontSize: 20, color: Colors.white))),
            SwitchEstado(manager, estado, nombre),
          ],
        ),
      ),
    );
  }
}

class SwitchEstado extends StatelessWidget {
  const SwitchEstado(this.manager, this.estadoinicial, this.nombre,
      {super.key});
  final String estadoinicial, nombre;
  final MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    bool light;
    if (estadoinicial == 'activa') {
      light = true;
    } else {
      light = false;
    }
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: Colors.orange,
      onChanged: ((value) {
        if (light) {
          manager.publish('/task/setestado/$nombre', 'inactiva');
        } else {
          manager.publish('/task/setestado/$nombre', 'activa');
        }
      }),
    );
  }
}
