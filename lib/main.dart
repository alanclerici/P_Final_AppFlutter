import 'package:flutter/material.dart';
import 'package:smart_home/mainwidget.dart';
import 'package:smart_home/mqtt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Smart home';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        home: ChangeNotifierProvider<MQTTAppState>(
          create: (_) => MQTTAppState(),
          child: MainWidget(),
        ));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MultiProvider(
  //     providers: [
  //       Provider<MQTTAppState>(create: (context) => MQTTAppState()),
  //       // Provider<Model1>(create: (context) => Model1()),
  //     ],
  //     child: MaterialApp(title: _title, home: MainWidget()),
  //   );
  // }
}
