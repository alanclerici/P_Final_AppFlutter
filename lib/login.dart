import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/datoDB.dart';
import 'package:smart_home/db.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color grisbase = Color.fromARGB(255, 50, 50, 50);

class Login extends StatelessWidget {
  Login(this.manager, {super.key});
  MQTTManager manager;

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
            RemoteLogin(),
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
              textoinicial = datoDB[0].toMap()['clave'];
            } else {
              textoinicial = 'Insertar clave';
            }
          } else {
            textoinicial = 'Insertar clave';
          }
          return Column(
            children: [
              const Text(
                'Clave',
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(40)),
                    hintText: textoinicial,
                    hintStyle: const TextStyle(color: Colors.black)),
                controller: _controller,
                onSubmitted: (String valuet) {
                  // textoescrito = valuet;
                },
              ),
              TextButton(
                onPressed: () {
                  Db.instance.insert(
                      DatoDB(id: 1, autologin: 'si', clave: _controller.text));
                  widget.manager.initializeMQTTClient(_controller.text);
                  widget.manager.connect();
                },
                child: const Text(
                  'Conectar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }
}

class RemoteLogin extends StatefulWidget {
  const RemoteLogin({super.key});

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
  Widget build(BuildContext context) {
    /////
    final dbfirebase = FirebaseFirestore.instance;
    final doc = dbfirebase.doc('/test/S9sdvpACwomZZOALTnus');

    ///
    return Column(
      children: [
        const Text(
          'Acceso remoto',
          style: TextStyle(color: Colors.white),
        ),
        TextField(
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(40)),
              hintText: 'Usuario',
              hintStyle: const TextStyle(color: Colors.black)),
          controller: _controllerUser,
          onSubmitted: (String valuet) {
            // textoescrito = valuet;
          },
        ),
        TextField(
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(40)),
              hintText: 'Contrasenia',
              hintStyle: const TextStyle(color: Colors.black)),
          controller: _controllerPasw,
          onSubmitted: (String valuet) {
            // textoescrito = valuet;
          },
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Conectar',
            style: TextStyle(color: Colors.white),
          ),
        ),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: doc.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            } else {
              return Text(
                snapshot.data!['mensaje'] ?? 'sin data',
                style: TextStyle(color: Colors.white),
              );
            }
          },
        )
      ],
    );
  }
}
