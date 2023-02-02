import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class FirebaseManager {
  MQTTAppState _currentState = MQTTAppState();
  CollectionReference db = FirebaseFirestore.instance.collection('serverUid');

  void setCurrentState(MQTTAppState state) {
    _currentState = state;
  }

  void connect(String user, String password) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user, password: password);
  }

  void disconnect() {
    FirebaseAuth.instance.signOut();
  }

  void listen() {
    //escucho cambios en la autenticacion
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        //si no estoy logueado seteo el estado como desconectado
        _currentState
            .setRemoteConnectionState(RemoteConnectionState.disconnected);
      } else {
        //si estoy logueado voy a buscar el nro de servidor que le corresponde a mi usuario
        _currentState.setFbUid(user.uid.toString());
        db.doc(user.uid.toString()).get().then((value) {
          Map<String, dynamic> aux = value.data() as Map<String, dynamic>;
          _currentState.setServerId(aux['nroserver']);
          _currentState
              .setRemoteConnectionState(RemoteConnectionState.conected);
        });
      }
    });
  }
}
