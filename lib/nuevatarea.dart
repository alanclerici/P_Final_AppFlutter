import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class NuevaTarea extends StatelessWidget {
  NuevaTarea(this.manager, this.appState);
  MQTTManager manager;
  MQTTAppState appState;
  static const Color grisbase =
      Color.fromARGB(255, 30, 30, 30); //constante para colore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: grisbase,
          title: const Text("Nueva tarea"),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                child: Text(
                  'Nombre',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              RecuadroTexto(),
              Container(
                child: Text(
                  'Causa',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Row(
                children: [
                  DBCausaModulo(manager, appState),
                ],
              ),
            ],
          ),
        ));
  }
}

//drop buttom para las causa, apartado modulos
class DBCausaModulo extends StatefulWidget {
  DBCausaModulo(this.manager, this.appState);
  MQTTManager manager;
  MQTTAppState appState;

  @override
  State<DBCausaModulo> createState() => _DBCausaModuloState();
}

class _DBCausaModuloState extends State<DBCausaModulo> {
  late String dropdownValue;
  List<String> tipocomparacion = ['Modulo'];
  @override
  void initState() {
    dropdownValue = tipocomparacion.first;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> tipocomparacion = [
      'Modulo'
    ]; //esta linea es para que no se descoordine todo si entran y salen mods
    if (widget.appState.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(widget.appState.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          tipocomparacion.add(i['id']);
        }
      }
    }

    return Row(
      children: [
        DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          dropdownColor: Colors.black,
          style: const TextStyle(color: Colors.white),
          underline: Container(
            height: 2,
            color: Colors.orange,
          ),
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
              // manager.publish('/setDB/zona/${widget.id}', value);
            });
          },
          items: tipocomparacion.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        //------------------------
        DBCausaTipo(dropdownValue, widget.manager, widget.appState),
      ],
    );
  }
}

//drop buttom para las causa, apartado tipo de comparacion
class DBCausaTipo extends StatefulWidget {
  DBCausaTipo(this.id, this.manager, this.appState);
  MQTTManager manager;
  MQTTAppState appState;
  String id;

  @override
  State<DBCausaTipo> createState() => _DBCausaTipoState();
}

class _DBCausaTipoState extends State<DBCausaTipo> {
  late String dropdownValue;
  List<String> tipocomparacion = ['tipo invalido'];

  List<String> tipoS = [
    'Tipo',
    'Mayor que',
    'Menor que',
    'Igual a',
  ];
  List<String> tipoM = ['Tipo', 'Detecta mov'];

  @override
  void initState() {
    print(widget.id[0]);
    if (widget.id[0] == 'S') {
      tipocomparacion = tipoS;
    }
    if (widget.id[0] == 'M' && widget.id[1] != 'o') {
      tipocomparacion = tipoM;
    }
    dropdownValue = tipocomparacion.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (tipocomparacion.length > 1) {
      return DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        dropdownColor: Colors.black,
        style: const TextStyle(color: Colors.white),
        underline: Container(
          height: 2,
          color: Colors.orange,
        ),
        onChanged: (String? value) {
          setState(() {
            dropdownValue = value!;
            // manager.publish('/setDB/zona/${widget.id}', value);
          });
        },
        items: tipocomparacion.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }
}

class RecuadroTexto extends StatefulWidget {
  const RecuadroTexto({super.key});

  @override
  State<RecuadroTexto> createState() => _RecuadroTextoState();
}

class _RecuadroTextoState extends State<RecuadroTexto> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.white,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey,
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(50)),
          hintText: 'insertar nombre',
          hintStyle: TextStyle(color: Colors.white)),
      controller: _controller,
      onSubmitted: (String value) async {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thanks!'),
              content: Text(
                  'You typed "$value", which has length ${value.characters.length}.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'OK',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
