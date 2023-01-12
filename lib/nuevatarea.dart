import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:intl/intl.dart';

const Color grisbase = Color.fromARGB(255, 50, 50, 50);

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
      body: ListView(
        children: [
          Container(
              margin: const EdgeInsets.only(top: 5),
              child:
                  const Text('Nombre', style: TextStyle(color: Colors.white))),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: const InputText(),
          ),
          Container(
              margin: const EdgeInsets.only(top: 20),
              child:
                  const Text('Causa', style: TextStyle(color: Colors.white))),
          const RowCausa(),
          if (appState.getModuloCausa.contains('S')) ...[const SliderInput()],
          if (appState.getModuloCausa.contains('Ti') &&
              appState.getVarCausa.contains('Hora')) ...[InputTime()],
          if (appState.getModuloCausa.contains('Ti') &&
              appState.getVarCausa.contains('Per')) ...[InputPeriodo('causa')],
          Container(
              margin: const EdgeInsets.only(top: 20),
              child:
                  const Text('Efecto', style: TextStyle(color: Colors.white))),
          const RowEfecto(),
          if (appState.getModuloEfecto.contains('R')) ...[
            Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Text('Efecto secundario',
                    style: TextStyle(color: Colors.white))),
          ],
          const RowEfectoSecundario(),
          if (appState.getCausaSecundaria.contains('Desp')) ...[
            InputPeriodo('secundario')
          ],
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: GuardarCancelar(manager),
          )
        ],
      ),
    );
  }
}

class GuardarCancelar extends StatelessWidget {
  GuardarCancelar(this.manager, {super.key});
  MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: grisbase,
          child: TextButton(
              onPressed: () {
                estado.resetAll();
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              )),
        ),
        SizedBox(
          width: 60,
        ),
        Container(
          color: grisbase,
          child: TextButton(
              onPressed: () {
                if (estado.getMsgNewTarea().isNotEmpty) {
                  manager.publish('/task/nueva', estado.getMsgNewTarea());
                  estado.resetAll();
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              )),
        )
      ],
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

    // switch (widget.tipo) {
    //   case 'moduloCausa':
    //     list = estado.getListModulos();
    //     break;
    //   case 'varCausa':
    //     list = estado.getListVarCausa();
    //     break;
    //   case 'tipoCausa':
    //     list = estado.getListTipoCausa();
    //     break;
    //   case 'moduloEfecto':
    //     list = estado.getListModulos();
    //     break;
    //   case 'tipoEfecto':
    //     list = estado.getListTipoEfecto();
    //     break;
    //   case 'tipoSecundario':
    //     list = estado.getListTipoSecundario();
    //     break;
    //   case 'causaSecundaria':
    //     list = estado.getListCausaSecundaria();
    //     break;
    //   default:
    //     list = ['no valido'];
    //     break;
    // }
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
    final estado = Provider.of<MQTTAppState>(context);
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
      onChanged: (value) {
        estado.setnombre(value);
      },
      onSubmitted: (String valuet) {
        estado.setnombre(valuet);
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
        if (estado.getModuloCausa.contains('S')) ...[TextValorCausa()],
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
        if (estado.getModuloEfecto.contains('R') &&
            estado.getTipoSecundario != 'Ninguno') ...[
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
      default:
        min = -10;
        max = 50;
        divisions = 60;
        break;
    }
    return Slider(
      activeColor: Colors.orange,
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

class InputTime extends StatefulWidget {
  const InputTime({super.key});

  @override
  State<InputTime> createState() => _InputTimeState();
}

class _InputTimeState extends State<InputTime> {
  TextEditingController timeinput = TextEditingController();
  @override
  void initState() {
    timeinput.text = "Ingresar hora"; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String etiqueta = 'Ingresar tiempo';
    final estado = Provider.of<MQTTAppState>(context);
    return Container(
        padding: EdgeInsets.all(15),
        width: 250,
        child: Center(
            child: TextField(
          style: TextStyle(color: Colors.black),
          controller: timeinput, //editing controller of this TextField
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50)),
            filled: true,
            fillColor: Colors.grey,
            icon: Icon(Icons.timer, color: Colors.grey), //icon of text field
            // labelText: etiqueta //label text of field
          ),
          readOnly: true, //set it true, so that user will not able to edit text
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Colors.orange, // <-- SEE HERE
                    ),
                  ),
                  child: child!,
                );
              },
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (pickedTime != null) {
              DateTime parsedTime =
                  DateFormat.jm().parse(pickedTime.format(context).toString());
              String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
              setState(() {
                formattedTime =
                    '${formattedTime.split(':')[0]}:${formattedTime.split(':')[1]}';
                print(formattedTime);
                timeinput.text = formattedTime;
                estado.setvalorCausa(formattedTime);
              });
            }
          },
        )));
  }
}

class InputPeriodo extends StatefulWidget {
  const InputPeriodo(this.tipo, {super.key});
  final String tipo;

  @override
  State<InputPeriodo> createState() => _InputPeriodoState();
}

class _InputPeriodoState extends State<InputPeriodo> {
  int min = 1, hora = 0;
  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<MQTTAppState>(context);
    return Container(
      child: Column(
        children: [
          SpinBox(
            min: 0,
            max: 100,
            value: 1,
            onChanged: (value) {
              hora = value.toInt();
              if (widget.tipo == 'causa') {
                estado.setvalorCausa('$hora:$min');
              } else {
                estado.setvalorSecundario('$hora:$min');
              }
            },
            decoration: InputDecoration(
                labelText: 'Horas', labelStyle: TextStyle(color: Colors.white)),
          ),
          SizedBox(
            height: 10,
          ),
          SpinBox(
            min: 0,
            max: 24,
            value: 0,
            onChanged: (value) {
              min = value.toInt();
              if (widget.tipo == 'causa') {
                estado.setvalorCausa('$hora:$min');
              } else {
                estado.setvalorSecundario('$hora:$min');
              }
            },
            decoration: InputDecoration(
                labelText: 'Minutos',
                labelStyle: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
