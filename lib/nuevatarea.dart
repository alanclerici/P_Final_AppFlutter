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
          Container(
              margin: EdgeInsets.only(top: 5),
              child:
                  const Text('Nombre', style: TextStyle(color: Colors.white))),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: const InputText(),
          ),
          Container(
              margin: EdgeInsets.only(top: 20),
              child:
                  const Text('Causa', style: TextStyle(color: Colors.white))),
          const RowCausa(),
          appState.getModuloCausa.contains('S')
              ? const SliderInput()
              : Container(),
          Container(
              margin: EdgeInsets.only(top: 20),
              child:
                  const Text('Efecto', style: TextStyle(color: Colors.white))),
          const RowEfecto(),
          if (appState.getModuloEfecto.contains('R')) ...[
            Container(
                margin: EdgeInsets.only(top: 20),
                child: const Text('Efecto secundario',
                    style: TextStyle(color: Colors.white))),
          ],
          const RowEfectoSecundario(),
        ],
      ),
    );
  }
}

class GuardarCancelar extends StatelessWidget {
  const GuardarCancelar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [],
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
  bool aux = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final estado = Provider.of<MQTTAppState>(context);

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
      case 'tipoSecundario':
        list = estado.getListTipoSecundario();
        break;
      case 'causaSecundaria':
        list = estado.getListCausaSecundaria();
        break;
      default:
        list = ['no valido'];
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);

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
      case 'tipoSecundario':
        list = estado.getListTipoSecundario();
        break;
      case 'causaSecundaria':
        list = estado.getListCausaSecundaria();
        break;
      default:
        list = ['no valido'];
        break;
    }
    if (aux) {
      dropdownValue = list.first;
      aux = false;
    }

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
            case 'tipoSecundario':
              estado.settipoSecundario(dropdownValue);
              break;
            case 'causaSecundaria':
              estado.setcausaSecundaria(dropdownValue);
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const DropButton('moduloCausa'),
        if (estado.getModuloCausa.contains('S') ||
            estado.getModuloCausa.contains('T')) ...[
          const DropButton('varCausa')
        ],
        if (estado.getModuloCausa.contains('S')) ...[
          const DropButton('tipoCausa')
        ],
        if (estado.getModuloCausa.contains('S')) ...[
          Container(
            child: TextValorCausa(),
          )
        ],
      ],
    );
  }
}

class TextValorCausa extends StatelessWidget {
  const TextValorCausa({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    String simbolo;
    switch (estado.getVarCausa) {
      case 'Hum.':
        simbolo = '%';
        break;
      case 'Pres.':
        simbolo = 'HPa';
        break;
      default:
        simbolo = '°C';
        break;
    }
    return Text(
      maxLines: 5,
      '${estado.getValorCausa}$simbolo',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }
}

class RowEfecto extends StatelessWidget {
  const RowEfecto({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DropButton('moduloEfecto'),
        if (estado.getModuloEfecto.contains('R')) ...[DropButton('tipoEfecto')],
      ],
    );
  }
}

class RowEfectoSecundario extends StatelessWidget {
  const RowEfectoSecundario({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (estado.getModuloEfecto.contains('R')) ...[
          DropButton('tipoSecundario')
        ],
        if (estado.getModuloEfecto.contains('R')) ...[
          DropButton('causaSecundaria')
        ],
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
  late double min, max;
  late int divisions;
  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    switch (estado.getVarCausa) {
      case 'Hum.':
        min = 20;
        max = 80;
        divisions = 60;
        _currentSliderValue = 50;
        break;
      case 'Pres.':
        min = -10;
        max = 50;
        divisions = 60;
        break;
      default:
        min = -10;
        max = 50;
        divisions = 60;
        break;
    }
    return Slider(
      value: _currentSliderValue,
      max: max,
      min: min,
      divisions: divisions,
      label: _currentSliderValue.round().toString(),
      onChanged: (double value) {
        setState(() {
          _currentSliderValue = value;
          estado.setvalorCausa(_currentSliderValue.round().toString());
        });
      },
    );
  }
}
