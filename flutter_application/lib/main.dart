import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // Replace 'Hello World!' with your login screen
    );
  }
}
