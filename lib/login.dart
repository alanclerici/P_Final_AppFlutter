import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_home/datoDB.dart';
import 'package:smart_home/db.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_home/firebasemanager.dart';
import 'package:udp/udp.dart';

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
      body: Center(
        child: Column(
          children: [
            LocalLogin(manager),
            RemoteLogin(fbManager),
          ],
        ),
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

  void sincronzacion() async {
    var sender = await UDP.bind(Endpoint.any());

    var receiver = await UDP.bind(Endpoint.any(port: Port(2222)));
    receiver.asStream(timeout: Duration(seconds: 10)).listen((datagram) {
      var str = String.fromCharCodes(datagram!.data);
      if (str.isNotEmpty && str != 'GetIp') {
        print(str);
        receiver.close();
      }
    });

    await sender.send("GetIp".codeUnits,
        Endpoint.unicast(InternetAddress('192.168.0.255'), port: Port(2222)));
    sender.close();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
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
                children: [
                  const Text(
                    'Acceso local',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.wheelchair_pickup_outlined),
                ],
              ),
              TextField(
                obscureText: true,
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.orange),
                decoration: InputDecoration(
                  // filled: true,
                  // fillColor: Colors.grey[700],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.orange),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  hintText: textoinicial,
                  hintStyle: const TextStyle(color: Colors.orange),
                ),
                controller: _controller,
                onSubmitted: (String valuet) {},
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
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
                    style: TextStyle(color: Colors.orange, fontSize: 18),
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
    /////
    final dbfirebase = FirebaseFirestore.instance;
    final doc = dbfirebase.doc('/server1toApp/mod-R00001-estado');

    ///
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Acceso remoto',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(
              width: 10,
            ),
            const Text(
              '(Desconectado)',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
        TextField(
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            // filled: true,
            // fillColor: Colors.grey[700],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.orange),
              borderRadius: BorderRadius.circular(50),
            ),
            hintText: 'Usuario',
            hintStyle: const TextStyle(color: Colors.white),
          ),
          controller: _controllerUser,
          onSubmitted: (String valuet) {
            // textoescrito = valuet;
          },
        ),
        TextField(
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            // filled: true,
            // fillColor: Colors.grey[700],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.orange),
              borderRadius: BorderRadius.circular(50),
            ),
            hintText: 'Contrasenia',
            hintStyle: const TextStyle(color: Colors.white),
          ),
          controller: _controllerPasw,
          onSubmitted: (String valuet) {
            // textoescrito = valuet;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                widget.fbManager.connect('user1@app.com', 'user123');
              },
              child: const Text(
                'Conectar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.fbManager.disconnect();
              },
              child: const Text(
                'Desonectar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
