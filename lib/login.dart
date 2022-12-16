import 'package:flutter/material.dart';
import 'package:smart_home/datoDB.dart';
import 'package:smart_home/db.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final String textoinicial = 'Insertar clave';
    return FutureBuilder(
        future: Db.instance.getAllItems(),
        builder: (BuildContext context, AsyncSnapshot<List<DatoDB>> snapshot) {
          if (snapshot.hasData) {
            datoDB = snapshot.data!;
            if (datoDB.isNotEmpty) {
              // textoinicial = datoDB[0].toMap()['clave'];
              print(datoDB[0].toMap()['clave']);
            }
          }
          return Column(
            children: [
              TextField(
                cursorColor: Colors.black,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
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
                child: Text(
                  'Conectar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  // if (datoDB.isNotEmpty) {
                  Db.instance.delete(1);
                  // }
                },
                child: Text(
                  'Borra',
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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
