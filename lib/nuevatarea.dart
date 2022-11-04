import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class NuevaTarea extends StatefulWidget {
  NuevaTarea(this.manager, this.appState, {super.key});
  MQTTManager manager;
  MQTTAppState appState;
  static const Color grisbase = Color.fromARGB(255, 30, 30, 30);
  @override
  State<NuevaTarea> createState() => _NuevaTareaState();
}

class _NuevaTareaState extends State<NuevaTarea> {
  TextEditingController timeinput = TextEditingController();

  late String dbComparacionValue;

  List<String> tipocomparacion = ['tipo invalido'];

  List<String> tipoS = [
    'Tipo',
    'Mayor que',
    'Menor que',
    'Igual a',
  ];
  List<String> tipoM = ['Tipo', 'Detecta mov'];

  late TextEditingController _controller;
  late String dbCausaValue;
  List<String> tipomodulo = ['Modulo', 'Tiempo'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    dbCausaValue =
        tipomodulo.first; //esta var contiene el tipo de modulo elegido

    if (dbCausaValue[0] == 'S') {
      tipocomparacion = tipoS;
    }
    if (dbCausaValue[0] == 'M' && dbCausaValue[1] != 'o') {
      tipocomparacion = tipoM;
    }
    dbComparacionValue = tipocomparacion.first;
  }

  @override
  Widget build(BuildContext context) {
    List<String> tipomodulo = [
      'Modulo'
    ]; //esta linea es para que no se descoordine todo si entran y salen mods
    if (widget.appState.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(widget.appState.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          tipomodulo.add(i['id']);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: NuevaTarea.grisbase,
        title: const Text("Nueva tarea"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child: const Text(
                'Nombre',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50)),
                  hintText: 'insertar nombre',
                  hintStyle: const TextStyle(color: Colors.white)),
              controller: _controller,
              onSubmitted: (String valuet) async {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Thanks!'),
                      content: Text(
                          'You typed "$valuet", which has length ${valuet.characters.length}.'),
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
            ),
            Container(
              child: const Text(
                'Causa',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Row(
              children: [
                DropdownButton<String>(
                  value: dbCausaValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.orange,
                  ),
                  onChanged: (String? valuemodulo) {
                    //para la seleccion de modulo
                    setState(() {
                      dbCausaValue = valuemodulo!;
                      if (dbCausaValue[0] == 'S') {
                        tipocomparacion = tipoS;
                      } else {
                        if (dbCausaValue[0] == 'M' && dbCausaValue[1] != 'o') {
                          tipocomparacion = tipoM;
                        } else {
                          tipocomparacion = ['tipo invalido'];
                        }
                      }
                      dbComparacionValue = tipocomparacion.first;
                      // manager.publish('/setDB/zona/${widget.id}', valuemodulo);
                    });
                  },
                  items: tipomodulo
                      .map<DropdownMenuItem<String>>((String valuemodulo) {
                    return DropdownMenuItem<String>(
                      value: valuemodulo,
                      child: Text(valuemodulo),
                    );
                  }).toList(),
                ),
                //------------------------------------------------------------
                tipocomparacion.first == 'tipo invalido'
                    ? Container()
                    : DropdownButton<String>(
                        value: dbComparacionValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(
                          height: 2,
                          color: Colors.orange,
                        ),
                        onChanged: (String? valuecomparacion) {
                          setState(() {
                            dbComparacionValue = valuecomparacion!;
                            // manager.publish('/setDB/zona/${widget.id}', valuecomparacion);
                          });
                        },
                        items: tipocomparacion.map<DropdownMenuItem<String>>(
                            (String valuecomparacion) {
                          return DropdownMenuItem<String>(
                            value: valuecomparacion,
                            child: Text(valuecomparacion),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
