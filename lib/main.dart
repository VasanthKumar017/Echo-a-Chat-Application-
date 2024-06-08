import 'package:flutter/material.dart';


import 'package:firebase_analytics/firebase_analytics.dart';

import "./pages/login_page.dart";
import './pages/registration_page.dart';
import './pages/home_page.dart';

import './services/navigation_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo',
      
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromRGBO(42, 117, 188, 1),
        colorScheme: const ColorScheme.dark(
          primary: Color.fromRGBO(42, 117, 188, 1),
          secondary: Color.fromRGBO(42, 117, 188, 1),
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(28, 27, 27, 1),
      ),

      
     initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
        "home": (BuildContext _context) => HomePage(),
      },
    );
  }
}
