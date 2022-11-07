import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/nuevatarea.dart';

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
  late String db3Value;
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
    db3Value = tipocomparacion.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (tipocomparacion.length > 1) {
      return DropdownButton<String>(
        value: db3Value,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        dropdownColor: Colors.black,
        style: const TextStyle(color: Colors.white),
        underline: Container(
          height: 2,
          color: Colors.orange,
        ),
        onChanged: (String? valuecomp) {
          setState(() {
            db3Value = valuecomp!;
            // manager.publish('/setDB/zona/${widget.id}', valuecomp);
          });
        },
        items:
            tipocomparacion.map<DropdownMenuItem<String>>((String valuecomp) {
          return DropdownMenuItem<String>(
            value: valuecomp,
            child: Text(valuecomp),
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }
}
