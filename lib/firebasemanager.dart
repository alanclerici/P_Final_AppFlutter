import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:smart_home/mqtt/state/MQTTAppState.dart';

class FirebaseManager {
  MQTTAppState _currentState = MQTTAppState();

  void set(MQTTAppState state) {
    _currentState = state;
  }

  void connect() {
    Future ConectarFirebase(String user, String password) async {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: user, password: password);
    }
  }

  void disconnect() {
    FirebaseAuth.instance.signOut();
  }
}
