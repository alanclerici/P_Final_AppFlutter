import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/datoDB.dart';
import 'package:smart_home/db.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_home/firebasemanager.dart';
import 'package:udp/udp.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

const Color grisbase = Color.fromARGB(255, 50, 50, 50);

class Login extends StatelessWidget {
  Login(this.manager, this.fbManager, {super.key});
  MQTTManager manager;
  FirebaseManager fbManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: grisbase,
        title: const Text("Sesion"),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          LocalLogin(manager),
          SizedBox(height: 20),
          RemoteLogin(fbManager),
        ],
      ),
    );
  }
}

class LocalLogin extends StatefulWidget {
  LocalLogin(this.manager, {super.key});
  MQTTManager manager;

  @override
  State<LocalLogin> createState() => _LocalLoginState();
}

class _LocalLoginState extends State<LocalLogin> {
  late TextEditingController _controller;
  late List<DatoDB> datoDB;
  late String textoinicial;
  late bool estadoLocal;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MQTTAppState>(context);
    estadoLocal = appState.getLocalState;
    return FutureBuilder(
        future: Db.instance.getAllItems(),
        builder: (BuildContext context, AsyncSnapshot<List<DatoDB>> snapshot) {
          if (snapshot.hasData) {
            datoDB = snapshot.data!;
            if (datoDB.isNotEmpty) {
              _controller.text = datoDB[0].toMap()['clave'];
            } else {
              textoinicial = 'Insertar clave';
            }
          } else {
            textoinicial = 'Insertar clave';
          }
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Acceso local',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  estadoLocal
                      ? const Text(
                          '(Conectado)',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        )
                      : const Text(
                          '(Desconectado)',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                ],
              ),
              TextField(
                obscureText: true,
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: decorationTextFiel(textoinicial),
                controller: _controller,
                onSubmitted: (String valuet) {},
              ),
              SizedBox(height: 8),
              Container(
                decoration: decorationContainerButton(),
                child: TextButton(
                  onPressed: () {
                    final ipBroker = '192.168.0.200';
                    // sincronzacion();
                    Db.instance.insert(
                        DatoDB(id: 1, ip: ipBroker, clave: _controller.text));
                    widget.manager
                        .initializeMQTTClient(_controller.text, ipBroker);
                    widget.manager.connect();
                  },
                  child: const Text(
                    'Sincronizar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class RemoteLogin extends StatefulWidget {
  RemoteLogin(this.fbManager, {super.key});
  FirebaseManager fbManager;
  @override
  State<RemoteLogin> createState() => _RemoteLoginState();
}

class _RemoteLoginState extends State<RemoteLogin> {
  late TextEditingController _controllerUser, _controllerPasw;
  late bool estadoRemoto;

  @override
  void initState() {
    super.initState();
    _controllerUser = TextEditingController();
    _controllerPasw = TextEditingController();
  }

  @override
  void dispose() {
    _controllerUser.dispose();
    _controllerPasw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MQTTAppState>(context);
    final dbfirebase = FirebaseFirestore.instance;
    final doc = dbfirebase.doc('/server1toApp/mod-R00001-estado');
    estadoRemoto = appState.getRemoteState;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Acceso remoto',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              width: 10,
            ),
            estadoRemoto
                ? const Text(
                    '(Conectado)',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  )
                : const Text(
                    '(Desconectado)',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
          ],
        ),
        TextField(
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.white),
          decoration: decorationTextFiel('Usuario'),
          controller: _controllerUser,
          onSubmitted: (String valuet) {
            // textoescrito = valuet;
          },
        ),
        SizedBox(height: 4),
        TextField(
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.white),
          decoration: decorationTextFiel('Contrasenia'),
          controller: _controllerPasw,
          onSubmitted: (String valuet) {
            // textoescrito = valuet;
          },
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: decorationContainerButton(),
              child: TextButton(
                onPressed: () {
                  if (estadoRemoto) {
                    widget.fbManager.disconnect();
                  } else {
                    widget.fbManager
                        .connect(_controllerUser.text, _controllerPasw.text);
                  }
                },
                child: estadoRemoto
                    ? const Text(
                        'Desconectar',
                        style: TextStyle(color: Colors.white),
                      )
                    : const Text(
                        'Conectar',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

InputDecoration decorationTextFiel(String textoinicial) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.grey[900],
    enabledBorder: OutlineInputBorder(
      // borderSide: BorderSide(width: 1, color: Colors.orange),
      borderRadius: BorderRadius.circular(10),
    ),
    hintText: textoinicial,
    hintStyle: const TextStyle(color: Colors.white),
  );
}

BoxDecoration decorationContainerButton() {
  return BoxDecoration(
      // border: Border.all(color: Colors.orange, width: 1),
      color: Colors.grey[900],
      borderRadius: const BorderRadius.all(Radius.circular(8)));
}
