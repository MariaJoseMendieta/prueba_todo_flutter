import 'package:flutter/material.dart';
import 'package:prueba_todo_flutter/screens/welcome_screen.dart';
import 'package:prueba_todo_flutter/screens/login_screen.dart';
import 'package:prueba_todo_flutter/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Prepara Flutter
  await Firebase.initializeApp(); //Conecta con Firebase (autenticación, Firestore, etc.)
  runApp(const MyApp()); //Lanza la app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'welcome_screen',
      routes: {
        'welcome_screen': (context) => WelcomeScreen(),
        'login_screen': (context) => LoginScreen(),
        'register_screen': (context) => RegisterScreen(),
      },
    );
  }
}
