//icono para sens temp
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class IconoModSens extends StatefulWidget {
  const IconoModSens(this.id, this.tipo);
  final String tipo;
  final String id;

  @override
  State<IconoModSens> createState() => _IconoModSensState();
}

class _IconoModSensState extends State<IconoModSens> {
  String valor = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final estadomqtt = Provider.of<MQTTAppState>(context);

    String msg = estadomqtt.getMensajes('/mod/${widget.id}/${widget.tipo}');
    if (msg != '') {
      valor = msg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget icono;
    switch (widget.tipo) {
      case 'temperatura':
        icono = const Icon(
          Icons.thermostat,
          color: Colors.white,
        );
        break;
      case 'humedad':
        icono = const Icon(
          Icons.water_drop_outlined,
          color: Colors.white,
        );
        break;
      case 'presion':
        icono = const Icon(
          Icons.atm,
          color: Colors.white,
        );
        break;
      default:
        icono = const Icon(
          Icons.error_outline,
          color: Colors.white,
        );
    }

    return Container(
      height: 90,
      width: 90,
      margin: const EdgeInsets.only(
        top: 5,
        bottom: 8,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(valor, style: const TextStyle(color: Colors.white)),
          ),
          Container(child: icono),
        ],
      ),
    );
  }
}

//icono para los rele
class IconoModRele extends StatefulWidget {
  const IconoModRele(this.manager, this.id);
  final String id;
  final MQTTManager manager;

  @override
  State<IconoModRele> createState() => _IconoModReleState();
}

class _IconoModReleState extends State<IconoModRele> {
  bool estadorele = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final estadomqtt = Provider.of<MQTTAppState>(context);

    String msg = estadomqtt.getMensajes('/mod/${widget.id}/estado');
    if (msg != '') {
      if (msg == 'on') {
        estadorele = true;
      }
      if (msg == 'off') {
        estadorele = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 90,
      margin: const EdgeInsets.only(
        top: 5,
        left: 8,
        right: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
          color: estadorele ? Colors.orange : Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: TextButton(
          onPressed: () {
            if (estadorele) {
              widget.manager.publish('/mod/${widget.id}/comandos', 'off');
            } else {
              widget.manager.publish('/mod/${widget.id}/comandos', 'on');
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Text(widget.id,
                    style: TextStyle(
                        color: estadorele ? Colors.white : Colors.white)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.power_settings_new,
                  color: estadorele ? Colors.grey : Colors.orange,
                ),
              ),
            ],
          )),
    );
  }
}

class IconoCtrlIR extends StatelessWidget {
  //el constructor recibe objeto para mandar mqtt, tipo de icono, id del modulo, modo de operacion
  //y codigo que debe enviar cuanbdo se pulse
  IconoCtrlIR(this.manager, this.tipo, this.idmodulo, this.idboton, this.modo,
      this.codigo,
      {super.key});
  final String tipo, idmodulo, idboton, modo, codigo;
  MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    var icono;

    switch (tipo) {
      case 'power':
        icono = Icons.power_settings_new;
        break;
      case 'arriba':
        icono = Icons.arrow_upward;
        break;
      case 'abajo':
        icono = Icons.arrow_downward;
        break;
      case 'izq':
        icono = Icons.arrow_back;
        break;
      case 'der':
        icono = Icons.arrow_forward;
        break;
      case 'canal+':
        icono = Icons.text_increase;
        break;
      case 'canal-':
        icono = Icons.text_decrease;
        break;
      case 'vol+':
        icono = Icons.volume_up;
        break;
      case 'vol-':
        icono = Icons.volume_down;
        break;
      case 'enter':
        icono = Icons.system_update_tv;
        break;
      case 'source':
        icono = Icons.reset_tv;
        break;
      case 'mode':
        icono = Icons.density_medium_outlined;
        break;
      case 'T+':
        icono = Icons.arrow_upward;
        break;
      case 'T-':
        icono = Icons.arrow_downward;
        break;
      case 'swing':
        icono = Icons.swap_calls_outlined;
        break;
      default:
        icono = Icons.error;
    }

    return Container(
      child: IconButton(
        icon: Icon(icono),
        color: Colors.white,
        onPressed: () {
          if (modo == 'normal' && codigo != 'null') {
            manager.publish(
                '/mod/$idmodulo', int.parse(codigo, radix: 16).toString());
          }
          if (modo == 'configuracion') {
            manager.publish('/mod/$idmodulo', idboton);
          }
        },
      ),
    );
  }
}
