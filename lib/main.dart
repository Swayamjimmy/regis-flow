import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are ready before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with the generated config
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
      title: 'SpendSense',
      home: Scaffold(
        appBar: AppBar(title: const Text('SpendSense')),
        body: const Center(child: Text('Hello SpendSense')),
      ),
    );
  }
}