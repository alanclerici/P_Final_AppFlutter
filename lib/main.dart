import 'package:flutter/material.dart';
import 'package:smart_home/mainwidget.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const Color grisbase = Color.fromARGB(255, 30, 30, 30);

void main() async {
  WidgetsFlutterBinding();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Smart home';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: grisbase,
        ),
        title: _title,
        home: ChangeNotifierProvider<MQTTAppState>(
          create: (_) => MQTTAppState(),
          child: MainWidget(),
        ));
  }
}
