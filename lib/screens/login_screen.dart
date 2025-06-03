import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prueba_todo_flutter/screens/todo_screen.dart';

/// [LoginScreen] es una pantalla que permite a los usuarios iniciar sesión
/// utilizando su correo electrónico y contraseña mediante Firebase Authentication.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Estado asociado a la pantalla de inicio de sesión [LoginScreen].
///
/// Maneja la lógica para capturar el correo y la contraseña del usuario,
/// realizar la autenticación con Firebase y mostrar errores si la autenticación falla.

class _LoginScreenState extends State<LoginScreen> {
  // Controlador para el campo de texto del correo electrónico.
  TextEditingController textEditingControllerEmail = TextEditingController();

  /// Controlador para el campo de texto de la contraseña.
  TextEditingController textEditingControllerPassword = TextEditingController();

  // Instancia de Firebase Authentication para manejar la autenticación de usuarios.
  final _auth = FirebaseAuth.instance;

  // Correo electrónico ingresado por el usuario.
  String email = '';
  // Contraseña ingresada por el usuario.
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono representativo de la app envuelto en un [Hero] para animación.
              Hero(
                tag: 'logo',
                child: Icon(
                  Icons.check_box_outlined,
                  color: Color(0xFF8BC34A),
                  size: 150.0,
                ),
              ),

              SizedBox(height: 30.0),

              // Campo de texto para ingresar el correo electrónico del usuario.
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                controller: textEditingControllerEmail,
                onChanged: (value) {
                  email = value.trim();
                },
                decoration: InputDecoration(
                  hintText: 'Introduce tu correo electrónico',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(
                      color: Color(0xFF689F38),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(
                      color: Color(0xFF689F38),
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.0),

              // Campo de texto para ingresar la contraseña del usuario.
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                controller: textEditingControllerPassword,
                onChanged: (value) {
                  password = value.trim();
                },
                decoration: InputDecoration(
                  hintText: 'Ingrese su contraseña',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(
                      color: Color(0xFF689F38),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide(
                      color: Color(0xFF689F38),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              // Botón para iniciar sesión con Firebase Authentication.
              // Si la autenticación es exitosa, navega a [TodoScreen].
              // Si falla, muestra un diálogo con el mensaje de error.
              ElevatedButton(
                onPressed: () async {
                  try {
                    //Intentar hacer login con Firebase usando email y password
                    final user = await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    //Si el inicio de sesión fue exitoso, navegar a la pantalla de to-do
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TodoScreen()),
                    );
                    // Limpiar los campos después del inicio de sesión exitoso.
                    textEditingControllerEmail.clear();
                    textEditingControllerPassword.clear();
                    email = '';
                    password = '';
                  } on FirebaseAuthException catch (e) {
                    // Manejo de errores comunes de inicio de sesión
                    String errorMessage;
                    // print('Código de error: ${e.code}');
                    // print('Mensaje: ${e.message}');

                    switch (e.code) {
                      case 'invalid-email':
                        errorMessage = 'Correo electrónico no válido.';
                        break;
                      case 'invalid-credential':
                        errorMessage =
                            'Correo/Contraseña incorrecto o expirado.';
                        break;
                      case 'too-many-requests':
                        errorMessage =
                            'Demasiados intentos fallidos. Intenta más tarde.';
                        break;
                      default:
                        errorMessage = 'Error inesperado. Intenta nuevamente.';
                    }

                    // Muestra un diálogo de alerta con el mensaje de error.
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text('Error de inicio de sesión'),
                            content: Text(errorMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFAED581),
                ),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
