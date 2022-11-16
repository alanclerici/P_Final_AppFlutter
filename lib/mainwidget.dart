import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/nuevatarea.dart';
import 'package:smart_home/task.dart';
import 'package:smart_home/config.dart';
import 'package:smart_home/home.dart';

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
            builder: (context) => ChangeNotifierProvider<MQTTAppState>.value(
                value: appState, child: NuevaTarea(manager))));
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

    List<Widget> _vistas = [Home(manager), Task(manager), Config(manager)];

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
      body: _vistas[_selectedIndex],
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


/////////////////////////////////////////////////
///
///
///           nueva tarea
/// 
/// 
///  /////////////////////////////////////////////

