//icono para sens temp
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class IconoModSens extends StatelessWidget {
  IconoModSens(this.id, this.tipo, {super.key});
  final String tipo;
  final String id;

  String valor = '';

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);
    final Widget icono = tipoIconoSensores(tipo);
    final dbfirebase = FirebaseFirestore.instance;
    final doc = dbfirebase.doc('/server1toApp/mod-$id-$tipo');

    if (estadomqtt.getAppConnectionState ==
            MQTTAppConnectionState.disconnected &&
        estadomqtt.getRemoteConnectionState == RemoteConnectionState.conected) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            String datafirebase = snapshot.data!['mod-$id-$tipo'];
            if (datafirebase != '') {
              valor = datafirebase;
            }
            return ContainerModSens(valor: valor, icono: icono);
          }
        },
      );
    } else {
      String msg = estadomqtt.getMensajes('/mod/$id/$tipo');
      if (msg != '') {
        valor = msg;
      }
      return ContainerModSens(valor: valor, icono: icono);
    }
  }
}

class ContainerModSens extends StatelessWidget {
  const ContainerModSens({
    Key? key,
    required this.valor,
    required this.icono,
  }) : super(key: key);

  final String valor;
  final Widget icono;

  @override
  Widget build(BuildContext context) {
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
class IconoModRele extends StatelessWidget {
  IconoModRele(this.manager, this.id, {super.key});
  final String id;
  final MQTTManager manager;

  bool estadorele = false;

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);
    final dbfirebase = FirebaseFirestore.instance;
    final doc = dbfirebase.doc('/server1toApp/mod-$id-estado');

    if (estadomqtt.getAppConnectionState ==
            MQTTAppConnectionState.disconnected &&
        estadomqtt.getRemoteConnectionState == RemoteConnectionState.conected) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            String datafirebase = snapshot.data!['mod-$id-estado'];
            if (datafirebase != '') {
              if (datafirebase == 'on') {
                estadorele = true;
              }
              if (datafirebase == 'off') {
                estadorele = false;
              }
            }
            return ContainerModRele(
                estadorele: estadorele,
                manager: manager,
                id: id,
                tipoConexion: 'remota');
          }
        },
      );
    } else {
      String msg = estadomqtt.getMensajes('/mod/$id/estado');
      if (msg != '') {
        if (msg == 'on') {
          estadorele = true;
        }
        if (msg == 'off') {
          estadorele = false;
        }
      }
      return ContainerModRele(
          estadorele: estadorele,
          manager: manager,
          id: id,
          tipoConexion: 'local');
    }
  }
}

class ContainerModRele extends StatelessWidget {
  const ContainerModRele({
    Key? key,
    required this.estadorele,
    required this.manager,
    required this.id,
    required this.tipoConexion,
  }) : super(key: key);

  final bool estadorele;
  final MQTTManager manager;
  final String id;
  final String tipoConexion;

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
              if (tipoConexion == 'local') {
                manager.publish('/mod/$id/comandos', 'off');
              }
              if (tipoConexion == 'remota') {
                CollectionReference writedb =
                    FirebaseFirestore.instance.collection('server1toServer');
                writedb
                    .doc('mod-$id-comandos')
                    .update({'mod-$id-comandos': 'off'});
              }
            } else {
              if (tipoConexion == 'local') {
                manager.publish('/mod/$id/comandos', 'on');
              }
              if (tipoConexion == 'remota') {
                CollectionReference writedb =
                    FirebaseFirestore.instance.collection('server1toServer');
                writedb
                    .doc('mod-$id-comandos')
                    .update({'mod-$id-comandos': 'on'});
              }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Text(id,
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

Widget tipoIconoSensores(String tipo) {
  switch (tipo) {
    case 'temperatura':
      return const Icon(
        Icons.thermostat,
        color: Colors.white,
      );
    case 'humedad':
      return const Icon(
        Icons.water_drop_outlined,
        color: Colors.white,
      );

    case 'presion':
      return const Icon(
        Icons.atm,
        color: Colors.white,
      );

    default:
      return const Icon(
        Icons.error_outline,
        color: Colors.white,
      );
  }
}
