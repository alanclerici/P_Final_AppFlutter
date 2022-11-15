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

// Estructura Causa:
//modulo-variable-tipo-valor
class _NuevaTareaState extends State<NuevaTarea> {
  TextEditingController timeinput = TextEditingController();
  late TextEditingController _controller;
  double _currentSliderValue = 20;
  late String db1Value;
  late String db2Value;
  late String db3Value;
  late String db4Value;
//-------------------------------- 1er drop buton
  List<String> tipomodulocausa = ['Modulo', 'Tiempo'];
//-------------------------------- 2do drop buton
  List<String> tipovar = ['tipo invalido'];
  //S00001
  List<String> tipoVarS = [
    'Variab.',
    'Temp.',
    'Hum.',
    'Pres.',
  ];
  //M000001
  List<String> tipoVarM = [
    'Variab.',
    'Movimiento',
  ];
  //tiempo
  List<String> tipoVarT = [
    'Variab.',
    'Periodo',
    'Hora exacta',
  ];

//-------------------------------- 3er drop buton
  List<String> tipocomp = ['tipo invalido'];
  List<String> tipoCompS = [
    'Tipo',
    'Mayor que',
    'Menor que',
    'Igual a',
  ];
  List<String> tipoCompM = ['Tipo', 'Detecta mov'];
  List<String> tipoCompT = ['Tipo', 'cada hora', 'hora del dia'];
  //----------------------------------- 1er drop buton efecto
  List<String> tipomoduloefecto = ['Modulo'];

  List<String> tipoVarRefecto = [
    'encender',
    'apagar',
    'conmutar',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    db1Value =
        tipomodulocausa.first; //esta var contiene el tipo de modulo elegido

    if (db1Value[0] == 'S') {
      tipovar = tipoVarS;
      tipocomp = tipoCompS;
    }
    if (db1Value[0] == 'M' && db1Value[1] != 'o') {
      tipovar = tipoVarM;
      tipocomp = tipoCompM;
    }
    if (db1Value[0] == 'T') {
      tipovar = tipoVarT;
      tipocomp = tipoCompT;
    }
    db2Value = tipovar.first;
    db3Value = tipocomp.first;
  }

  @override
  Widget build(BuildContext context) {
    List<String> tipomodulocausa = [
      'Modulo',
      'Tiempo'
    ]; //esta linea es para que no se descoordine todo si entran y salen mods
    List<String> tipomoduloefecto = [
      'Modulo',
    ]; //esta linea es para que no se descoordine todo si entran y salen mods
    if (widget.appState.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(widget.appState.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          tipomodulocausa.add(i['id']);
          tipomoduloefecto.add(i['id']);
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
            //------------------------------------------------------------------ arranca columna
            Container(
              child: const Text(
                'Nombre',
                style: TextStyle(color: Colors.white),
              ),
            ),
            //------------------------------------------------------------------ primer piso
            TextField(
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50)),
                  hintText: 'insertar nombre',
                  hintStyle: const TextStyle(color: Colors.black)),
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
            //------------------------------------------------------------------ segundo piso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //------------------------------------------------------------------ 1er DB
                DropdownButton<String>(
                  value: db1Value,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.orange,
                  ),
                  onChanged: (String? valuemodulocausa) {
                    //para la seleccion de modulo
                    setState(() {
                      db1Value = valuemodulocausa!;
                      if (db1Value[0] == 'S') {
                        tipovar = tipoVarS;
                        tipocomp = tipoCompS;
                      } else {
                        if (db1Value[0] == 'M' && db1Value[1] != 'o') {
                          tipovar = tipoVarM;
                          tipocomp = tipoCompM;
                        } else {
                          if (db1Value[0] == 'T') {
                            tipovar = tipoVarT;
                            tipocomp = tipoCompT;
                          } else {
                            tipovar = ['tipo invalido'];
                            tipocomp = ['Tipo'];
                          }
                        }
                      }
                      db2Value = tipovar.first;
                      db3Value = tipocomp.first;
                    });
                  },
                  items: tipomodulocausa
                      .map<DropdownMenuItem<String>>((String valuemodulocausa) {
                    return DropdownMenuItem<String>(
                      value: valuemodulocausa,
                      child: Text(valuemodulocausa),
                    );
                  }).toList(),
                ),
                //------------------------------------------------------------------ 2do DB

                DropdownButton<String>(
                  value: db2Value,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.orange,
                  ),
                  onChanged: (String? valuevar) {
                    setState(() {
                      db2Value = valuevar!;
                      // manager.publish('/setDB/zona/${widget.id}', valuevar);
                    });
                  },
                  items:
                      tipovar.map<DropdownMenuItem<String>>((String valuevar) {
                    return DropdownMenuItem<String>(
                      value: valuevar,
                      child: Text(valuevar),
                    );
                  }).toList(),
                ),

                //------------------------------------------------------------------ 3er DB
                DropdownButton<String>(
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
                  items: tipocomp
                      .map<DropdownMenuItem<String>>((String valuecomp) {
                    return DropdownMenuItem<String>(
                      value: valuecomp,
                      child: Text(valuecomp),
                    );
                  }).toList(),
                ),
                //------------------------------------------------------------------ 4to DB
              ],
            ),
            //------------------------------------------------------------------ tercer piso
            db1Value[0] == 'S'
                ? Slider(
                    value: _currentSliderValue,
                    max: 50,
                    min: -10,
                    divisions: 60,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  )
                : Container(),
            Container(
              child: const Text(
                'Efecto',
                style: TextStyle(color: Colors.white),
              ),
            ),
            //------------------------------------------------------------------ cuarto piso
            Row(
              children: [
                DropdownButton<String>(
                  value: db4Value,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.orange,
                  ),
                  onChanged: (String? valuemodefecto) {
                    setState(() {
                      db4Value = valuemodefecto!;
                    });
                  },
                  items: tipomoduloefecto
                      .map<DropdownMenuItem<String>>((String valuemodefecto) {
                    return DropdownMenuItem<String>(
                      value: valuemodefecto,
                      child: Text(valuemodefecto),
                    );
                  }).toList(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
