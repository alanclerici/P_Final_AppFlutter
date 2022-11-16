import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

// final appState = Provider.of<MQTTAppState>(context);

const Color grisbase = Color.fromARGB(255, 30, 30, 30);

class NuevaTarea extends StatelessWidget {
  NuevaTarea(this.manager, {super.key});
  MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MQTTAppState>(context);
    // final appState = Provider.of<MQTTAppState>(context);
    appState.resetModulo();
    if (appState.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(appState.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          appState.addModulo(i['id']);
        }
      }
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: grisbase,
        title: const Text("Nueva tarea"),
      ),
      body: Column(
        children: [
          Text('Nombre', style: TextStyle(color: Colors.white)),
          InputText(),
          Text('Causa', style: TextStyle(color: Colors.white)),
          RowCausa(),
          appState.getModuloCausa.contains('S') ? SliderInput() : Container(),
          Text('Efecto', style: TextStyle(color: Colors.white)),
          RowEfecto(),
        ],
      ),
    );
  }
}

//(estado para guardar var, lista para mostrar)
class DropButton extends StatefulWidget {
  const DropButton(this.tipo, {super.key});
  final String tipo; //tipo que representa

  @override
  State<DropButton> createState() => _DropButtonState();
}

class _DropButtonState extends State<DropButton> {
  late String dropdownValue;
  late List<String> list;

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    ////
    switch (widget.tipo) {
      case 'moduloCausa':
        list = estado.getListModulos();
        break;
      case 'varCausa':
        list = estado.getListVarCausa();
        break;
      case 'tipoCausa':
        list = estado.getListTipoCausa();
        break;
      case 'moduloEfecto':
        list = estado.getListModulos();
        break;
      case 'tipoEfecto':
        list = estado.getListTipoEfecto();
        break;
      default:
        list = ['no valido'];
        break;
    }
    dropdownValue = list.first;

    ///
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
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          switch (widget.tipo) {
            case 'moduloCausa':
              estado.setmoduloCausa(dropdownValue);
              break;
            case 'varCausa':
              estado.setvarCausa(dropdownValue);
              break;
            case 'tipoCausa':
              estado.settipoCausa(dropdownValue);
              break;
            case 'moduloEfecto':
              estado.setmoduloEfecto(dropdownValue);
              break;
            case 'tipoEfecto':
              estado.settipoEfecto(dropdownValue);
              break;
            default:
              break;
          }
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

class InputText extends StatefulWidget {
  const InputText({super.key});

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}

class RowCausa extends StatelessWidget {
  const RowCausa({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    return Row(
      children: [
        DropButton('moduloCausa'),
        DropButton('varCausa'),
        estado.getModuloCausa.contains('S')
            ? DropButton('tipoCausa')
            : Container(),
      ],
    );
  }
}

class RowEfecto extends StatelessWidget {
  const RowEfecto({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropButton('moduloEfecto'),
        DropButton('tipoEfecto'),
      ],
    );
  }
}

class SliderInput extends StatefulWidget {
  const SliderInput({super.key});

  @override
  State<SliderInput> createState() => _SliderInputState();
}

class _SliderInputState extends State<SliderInput> {
  double _currentSliderValue = 20;
  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    return Slider(
      value: _currentSliderValue,
      max: 50,
      min: -10,
      divisions: 60,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
          estado.setvalorCausa(_currentSliderValue.toString());
        });
      },
    );
  }
}
