import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/layoutIR.dart';
import 'dart:convert';

class Config extends StatelessWidget {
  Config(this.manager, {super.key});
  final MQTTManager manager;
  List<dynamic> listamodulos = [];

  List<Widget> _mods = [];

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);

    if (estadomqtt.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(estadomqtt.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          listamodulos.add(i);
        }
      }
      for (var i in listamodulos) {
        if (i['estado'] == 'activo') {
          _mods.add(Modulo(manager, i['id'], i['zona']));
        }
      }
    }
    return ListView(
      children: _mods,
    );
  }
}

class Modulo extends StatelessWidget {
  final String id;
  final String zona;
  const Modulo(this.manager, this.id, this.zona);
  final MQTTManager manager;

  static const Color grisbase = Color.fromARGB(255, 30, 30, 30);

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              margin: const EdgeInsets.only(left: 10),
              child: Text(id,
                  style: const TextStyle(fontSize: 20, color: Colors.white))),
          Row(
            children: [
              id[0] == 'L'
                  ? IconButton(
                      onPressed: (() {
                        manager.publish('/mod/$id/comandos', 'configuracion');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WillPopScope(
                                  onWillPop: () async {
                                    return false;
                                  },
                                  child: Scaffold(
                                    backgroundColor: Colors.black,
                                    appBar: AppBar(
                                      automaticallyImplyLeading: false,
                                      leading: Builder(
                                        builder: (BuildContext context) {
                                          return IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            onPressed: () {
                                              manager.publish(
                                                  '/mod/$id/comandos',
                                                  'normal');
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      ),
                                      backgroundColor: grisbase,
                                      title: const Text('Config led'),
                                    ),
                                    body: Center(
                                        child: LayoutTv(
                                            manager, '', id, 'configuracion')),
                                  ),
                                )));
                      }),
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    )
                  : Container(),
              Container(
                margin: const EdgeInsets.only(right: 5),
                child: DropdownButtonExample(manager, id, zona),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  final String zona;
  final String id;
  const DropdownButtonExample(this.manager, this.id, this.zona);
  final MQTTManager manager;

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  final List<String> list = [
    'Sin zona',
    'Comedor',
    'Cocina',
    'Living',
    'Baño',
    'Habitacion 1',
    'Habitacion 2',
    'Habitacion 3',
  ];
  late String dropdownValue;

  @override
  void initState() {
    for (var i in list) {
      if (i.toLowerCase() == widget.zona.toLowerCase()) {
        dropdownValue = i;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          widget.manager.publish('/setDB/zona/${widget.id}', value);
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
