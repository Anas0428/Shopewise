import 'package:flutter/material.dart';

import 'package:my_project/screens/splash_screen.dart';
import 'package:firedart/firedart.dart';

const apiKey = "AIzaSyCjZK5ojHcJQh8Sr0sdMG0Nlnga4D94FME";
const projectId = "shopwise-86248";
const bool isLoggedIn = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.initialize(projectId); // Establishing connection with Firestore
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'shopWise',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SafeArea(
        child: Splash(),
      ),
    );
  }
}
