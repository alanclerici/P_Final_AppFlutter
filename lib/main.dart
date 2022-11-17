import 'package:flutter/material.dart';
import 'package:smart_home/mainwidget.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';

const Color grisbase = Color.fromARGB(255, 30, 30, 30);

void main() => runApp(const MyApp());

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
