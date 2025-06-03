import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prueba_todo_flutter/screens/todo_screen.dart';

/// Pantalla de registro de usuario.
///
/// Permite al usuario crear una cuenta con su correo electrónico y contraseña.
/// Si el registro es exitoso, se redirige a la pantalla de tareas [TodoScreen].
/// Si ocurre un error, se muestra un mensaje descriptivo al usuario.

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controlador para el campo de texto del correo electrónico.
  TextEditingController textEditingControllerEmail = TextEditingController();
  // Controlador para el campo de texto de la contraseña.
  TextEditingController textEditingControllerPassword = TextEditingController();

  // Variables para almacenar temporalmente el correo y la contraseña introducidos.
  String email = '';
  String password = '';

  // Instancia de Firebase Authentication.
  final _auth = FirebaseAuth.instance;

  // Construye la interfaz gráfica de la pantalla de registro.
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
              // Ícono principal con animación [Hero].
              Hero(
                tag: 'logo',
                child: Icon(
                  Icons.check_box_outlined,
                  color: Color(0xFF8BC34A),
                  size: 150.0,
                ),
              ),

              SizedBox(height: 30.0),

              // Campo de texto para ingresar el correo electrónico.
              TextField(
                controller: textEditingControllerEmail,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
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

              // Campo de texto para ingresar la contraseña.
              TextField(
                controller: textEditingControllerPassword,
                obscureText: true,
                textAlign: TextAlign.center,
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

              // Botón para registrar al usuario usando Firebase Authentication.
              // En caso de error se muestra un [AlertDialog] con el mensaje correspondiente.
              ElevatedButton(
                onPressed: () async {
                  try {
                    //Crear usuario con email y contraseña en Firebase
                    final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    //Si el registro fue exitoso, navegar a la pantalla de to-do
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TodoScreen()),
                    );
                    // Limpiar campos
                    textEditingControllerEmail.clear();
                    textEditingControllerPassword.clear();
                    email = '';
                    password = '';
                  } on FirebaseAuthException catch (e) {
                    // Manejo de errores comunes de registro
                    String errorMessage = '';
                    if (e.code == 'email-already-in-use') {
                      errorMessage =
                          'Este correo ya está registrado. Intenta iniciar sesión.';
                    } else if (e.code == 'invalid-email') {
                      errorMessage = 'Correo electrónico no válido.';
                    } else if (e.code == 'weak-password') {
                      errorMessage =
                          'La contraseña debe tener al menos 6 caracteres.';
                    } else {
                      errorMessage = 'Ocurrió un error. Intenta nuevamente.';
                    }

                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Error de registro'),
                            content: Text(errorMessage),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                    );
                  } catch (e) {
                    // Captura de errores inesperados
                    print('Error inesperado: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9CCC65),
                ),
                child: Text(
                  'Registrarse',
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
