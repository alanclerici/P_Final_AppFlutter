import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

const Color grisbase = Color.fromARGB(255, 30, 30, 30);

class NuevaTarea extends StatefulWidget {
  NuevaTarea(this.manager, this.appState, {super.key});
  MQTTManager manager;
  MQTTAppState appState;

  @override
  State<NuevaTarea> createState() => _NuevaTareaState();
}

class _NuevaTareaState extends State<NuevaTarea> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    widget.appState.resetModulo();
    if (widget.appState.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(widget.appState.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          widget.appState.addModulo(i['id']);
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
          RowCausa(widget.appState),
          widget.appState.getModuloCausa.contains('S')
              ? SliderInput(widget.appState)
              : Container(),
          Text('Efecto', style: TextStyle(color: Colors.white)),
          RowEfecto(widget.appState),
        ],
      ),
    );
  }
}

//(estado para guardar var, lista para mostrar)
class DropButton extends StatefulWidget {
  const DropButton(this.estado, this.tipo, {super.key});
  final String tipo; //tipo que representa
  final MQTTAppState estado;
  @override
  State<DropButton> createState() => _DropButtonState();
}

class _DropButtonState extends State<DropButton> {
  late String dropdownValue;
  late List<String> list;

  @override
  void initState() {
    switch (widget.tipo) {
      case 'moduloCausa':
        list = widget.estado.getListModulos();
        break;
      case 'varCausa':
        list = widget.estado.getListVarCausa();
        break;
      case 'tipoCausa':
        list = widget.estado.getListTipoCausa();
        break;
      case 'moduloEfecto':
        list = widget.estado.getListModulos();
        break;
      case 'tipoEfecto':
        list = widget.estado.getListTipoEfecto();
        break;
      default:
        list = ['no valido'];
        break;
    }
    dropdownValue = list.first;
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
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          switch (widget.tipo) {
            case 'moduloCausa':
              widget.estado.setmoduloCausa(dropdownValue);
              break;
            case 'varCausa':
              widget.estado.setvarCausa(dropdownValue);
              break;
            case 'tipoCausa':
              widget.estado.settipoCausa(dropdownValue);
              break;
            case 'moduloEfecto':
              widget.estado.setmoduloEfecto(dropdownValue);
              break;
            case 'tipoEfecto':
              widget.estado.settipoEfecto(dropdownValue);
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
  const RowCausa(this.estado, {super.key});
  final MQTTAppState estado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropButton(estado, 'moduloCausa'),
        DropButton(estado, 'varCausa'),
        estado.getModuloCausa.contains('S')
            ? DropButton(estado, 'tipoCausa')
            : Container(),
      ],
    );
  }
}

class RowEfecto extends StatelessWidget {
  const RowEfecto(this.estado, {super.key});
  final MQTTAppState estado;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropButton(estado, 'moduloEfecto'),
        DropButton(estado, 'tipoEfecto'),
      ],
    );
  }
}

class SliderInput extends StatefulWidget {
  const SliderInput(this.estado, {super.key});
  final MQTTAppState estado;

  @override
  State<SliderInput> createState() => _SliderInputState();
}

class _SliderInputState extends State<SliderInput> {
  double _currentSliderValue = 20;
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentSliderValue,
      max: 50,
      min: -10,
      divisions: 60,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
          widget.estado.setvalorCausa(_currentSliderValue.toString());
        });
      },
    );
  }
}
