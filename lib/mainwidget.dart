import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/datoDB.dart';
import 'package:smart_home/db.dart';
import 'package:smart_home/login.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:smart_home/mqtt/MQTTManager.dart';
import 'package:smart_home/nuevatarea.dart';
import 'package:smart_home/task.dart';
import 'package:smart_home/config.dart';
import 'package:smart_home/home.dart';
import 'package:smart_home/firebasemanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MainWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainWidgetState();
  }
}

class _MainWidgetState extends State<MainWidget> {
  List<dynamic> listamodulos = [];
  List<DatoDB> datoDB = [];
  late MQTTAppState currentAppState;
  MQTTManager manager = MQTTManager();
  late String ipbroker;
  late dynamic subscription;
  FirebaseManager fbManager = FirebaseManager();

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
      fbManager.set(currentAppState);
      fbManager.listen();

      Db.instance.getAllItems().then((value) {
        datoDB = value;
        if (datoDB.isNotEmpty) {
          //si encuentro el codigo conecto y lanzo el listener para detectar cambios en la red
          manager.initializeMQTTClient(datoDB[0].toMap()['clave']);
          // manager.connect();
          subscription = Connectivity()
              .onConnectivityChanged
              .listen((ConnectivityResult result) {
            if (result == ConnectivityResult.wifi) {
              print(';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;');
              print('conectao');
            } else {
              print(';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;');
              print('no conectao');
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
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

    iconosuperior = getIconoEstadoConexion(appState.getConnectionGeneral());

    List<Widget> vistas = [Home(manager), Task(manager), Config(manager)];

    return Scaffold(
      floatingActionButton: _selectedIndex == 1 ? botonflotante : null,
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider<MQTTAppState>.value(
                          value: appState, child: Login(manager, fbManager))));
            },
            icon: iconosuperior,
          )
        ],
        backgroundColor: grisbase,
        title: const Text('Smart Home'),
      ),
      body: vistas[_selectedIndex],
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
}

String getBrokerIp(String ip) {
  //recive la direccion de difusion, devuelve la ultima dir-4
  final aux = ip.split('.');
  aux[3] = (int.parse(aux[3]) - 5).toString();
  return aux.join('.');
}

Widget getIconoEstadoConexion(String estado) {
  switch (estado) {
    case 'local':
      return const Icon(
        Icons.wifi,
        color: Colors.green,
      );
    case 'remota':
      return const Icon(
        Icons.satellite_alt_outlined,
        color: Colors.yellow,
      );

    default:
      return const Icon(
        Icons.wifi_off,
        color: Colors.red,
      );
  }
}
