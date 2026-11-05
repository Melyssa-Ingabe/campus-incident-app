import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Incident App',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C4CF1),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Firebase connected')),
      ),
    );
  }
}