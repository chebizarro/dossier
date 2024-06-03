import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/preferences.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Preferences preferences = await Preferences.load();

  runApp(MyApp(preferences: preferences));

  if (preferences.startMaximized) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

class MyApp extends StatelessWidget {
  final Preferences preferences;

  MyApp({required this.preferences});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dossier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(preferences: preferences),
    );
  }
}
