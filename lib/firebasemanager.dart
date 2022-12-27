import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class FirebaseManager {
  MQTTAppState _currentState = MQTTAppState();

  void set(MQTTAppState state) {
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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentState
            .setRemoteConnectionState(RemoteConnectionState.disconnected);
      } else {
        _currentState.setRemoteConnectionState(RemoteConnectionState.conected);
      }
    });
  }
}
