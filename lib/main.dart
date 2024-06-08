import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

import './pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117, 188, 1),
        colorScheme: const ColorScheme.dark(
          primary: Color.fromRGBO(42, 117, 188, 1),
          secondary: Color.fromRGBO(42, 117, 188, 1),
        ),
        scaffoldBackgroundColor: Color.fromRGBO(28, 27, 27, 1),
      ),
      home: LoginPage(),
    );
  }
}
