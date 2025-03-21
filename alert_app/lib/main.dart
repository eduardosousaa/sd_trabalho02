import 'package:alert_app/screens/my_home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALERT_APP',
      initialRoute: '/',
      routes: {
        "/": (context) => const MyHomePage(),
      },
    );
  }
}