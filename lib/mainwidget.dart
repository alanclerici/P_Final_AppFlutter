import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/nuevatarea.dart';

class MainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainWidgetState();
  }
}

class _MainWidgetState extends State<MainWidget> {
  List<dynamic> listamodulos = [];

  late MQTTAppState currentAppState;
  MQTTManager manager = MQTTManager();

  @override
  void initState() {
    super.initState();

    // CLAVE
    // ----- Esto se ejecuta una vez se construye el widget. Me permite ejecutar la func de conexion al broker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      manager.set(
        '192.168.0.200',
        '/mod/#',
        'app',
        currentAppState,
      );
      _configureAndConnect();
    });
    //-------------------
  }

  @override
  void dispose() {
    super.dispose();
  }

  static const Color grisbase =
      Color.fromARGB(255, 30, 30, 30); //constante para colores
  int _selectedIndex = 0; //indice de pagina

  //funcion para cambio de pagina
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    final Widget iconosuperior;

    final Widget botonflotante = FloatingActionButton(
      onPressed: (() {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NuevaTarea(manager, currentAppState)));
      }),
      backgroundColor: Colors.orange,
      child: const Icon(Icons.add),
    );

    switch (currentAppState.getAppConnectionState) {
      case MQTTAppConnectionState.local:
        iconosuperior = const Icon(
          Icons.wifi,
          color: Colors.green,
        );
        break;
      case MQTTAppConnectionState.connecting:
        iconosuperior = const Icon(
          Icons.wifi_off,
          color: Colors.red,
        );
        // iconosuperior = CircularProgressIndicator();
        break;
      case MQTTAppConnectionState.remote:
        iconosuperior = const Icon(
          Icons.satellite_alt,
          color: Colors.blue,
        );
        break;
      default:
        iconosuperior = const Icon(
          Icons.wifi_off,
          color: Colors.white,
        );
    }

    List<Widget> _vistas = [Home(), Task(), Config()];

    return Scaffold(
      floatingActionButton: _selectedIndex == 1 ? botonflotante : null,
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              onPressed: () {
                if (currentAppState.getAppConnectionState ==
                    MQTTAppConnectionState.disconnected) {
                  _configureAndConnect();
                }
              },
              icon: iconosuperior)
        ],
        backgroundColor: grisbase,
        title: const Text('Smart Home'),
      ),
      body: Provider.value(value: manager, child: _vistas[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: grisbase,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: 'task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'config',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  void _configureAndConnect() {
    manager.initializeMQTTClient();
    manager.connect();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);
    List<Widget> zonas = [];
    List<String> aux = [];

    if (estadomqtt.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(estadomqtt.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          if (!aux.contains(i['zona'])) {
            aux.add(i['zona']);
            zonas.add(Zona(i['zona']));
          }
        }
      }
    }
    return ListView(
      children: zonas,
    );
  }
}

class Task extends StatelessWidget {
  const Task({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('cpsp');
  }
}

class Config extends StatelessWidget {
  List<dynamic> listamodulos = [];

  List<Widget> _mods = [];

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);

    if (estadomqtt.getReceivedStatus.isNotEmpty) {
      for (var i in jsonDecode(estadomqtt.getReceivedStatus)) {
        if (i['estado'] == 'activo') {
          listamodulos.add(i);
        }
      }
      for (var i in listamodulos) {
        if (i['estado'] == 'activo') {
          _mods.add(Modulo(i['id'], i['zona']));
        }
      }
    }
    return ListView(
      children: _mods,
    );
  }
}

class Zona extends StatelessWidget {
  const Zona(this.nombrezona);

  final String nombrezona;

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);
    int cont = 0;
    List<Widget> mods = [];
    List<Widget> grilla = []; //arreglo de row

    grilla.add(Container(
        child: Text(nombrezona, style: const TextStyle(color: Colors.white))));

    if (estadomqtt.getReceivedStatus.isNotEmpty) {
      //recorro para cada elemento del JSON
      for (var i in jsonDecode(estadomqtt.getReceivedStatus)) {
        //si el elemento esta activo y corresponde con la zona
        if (i['zona'] == nombrezona && i['estado'] == 'activo') {
          //en caso de que sea un modulo de sensores, agrega 3 iconos a la lista
          if (i['id'][0] == 'S') {
            grilla.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconoModSens(i['id'], 'temperatura'),
                IconoModSens(i['id'], 'humedad'),
                IconoModSens(i['id'], 'presion'),
              ],
            ));
          }
          //en caso de que sea un modulo de rele agrega un icono a una lista auxiliar
          if (i['id'][0] == 'R') {
            cont++;
            mods.add(IconoModRele(i['id']));
          }
          //si se juntan 3 rele los agrega a la lista final
          if (cont > 0 && cont % 3 == 0) {
            grilla.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: mods.sublist(cont - 3),
            ));
          }
        }
      }
      //si juntamos menos de 3 elementos, los agregamos al final
      if (cont % 3 > 0) {
        grilla.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: mods.sublist(cont - (cont % 3)),
        ));
      }
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Column(
        children: grilla,
      ),
    );
  }
}

//icono para los rele
class IconoModRele extends StatefulWidget {
  const IconoModRele(this.id);
  final String id;

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
    final manager = Provider.of<MQTTManager>(context);
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
              manager.publish('/mod/${widget.id}/comandos', 'off');
            } else {
              manager.publish('/mod/${widget.id}/comandos', 'on');
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

//icono para sens temp
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

class Modulo extends StatelessWidget {
  final String id;
  final String zona;
  const Modulo(this.id, this.zona);

  @override
  Widget build(BuildContext context) {
    final estadomqtt = Provider.of<MQTTAppState>(context);
    return Container(
      height: 60,
      margin: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(id,
                  style: const TextStyle(fontSize: 20, color: Colors.white))),
          Container(
            margin: EdgeInsets.only(right: 5),
            child: DropdownButtonExample(id, zona),
          )
        ],
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  final String zona;
  final String id;
  const DropdownButtonExample(this.id, this.zona);

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  final List<String> list = [
    'Sin zona',
    'Comedor',
    'Cocina',
    'Living',
    'Baño',
    'Habitacion 1',
    'Habitacion 2',
    'Habitacion 3',
  ];
  late String dropdownValue;

  @override
  void initState() {
    for (var i in list) {
      if (i.toLowerCase() == widget.zona.toLowerCase()) {
        dropdownValue = i;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<MQTTManager>(context);
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
        setState(() {
          dropdownValue = value!;
          manager.publish('/setDB/zona/${widget.id}', value);
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
