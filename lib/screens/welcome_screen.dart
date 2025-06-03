import 'package:flutter/material.dart';

/// Pantalla de bienvenida de la aplicación.
///
/// Muestra el nombre de la app y permite al usuario navegar
/// hacia las pantallas de inicio de sesión o registro.
///
/// Esta pantalla incluye:
/// - Un ícono animado con Hero
/// - El título "My To-Do List"
/// - Botón para iniciar sesión
/// - Botón para registrarse

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              // Fila con logo animado y nombre de la app.
              Row(
                children: [
                  // Hero permite animar la transición del ícono a otras pantallas.
                  Hero(
                    tag: 'logo',
                    child: Icon(
                      Icons.check_box_outlined,
                      color: Color(0xFF8BC34A),
                      size: 60.0,
                    ),
                  ),
                  Text(
                    'My To-Do List',
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.0),

              // Botón para navegar a la pantalla de inicio de sesión.
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'login_screen');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFAED581),
                ),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),

              SizedBox(height: 10.0),

              // Botón para navegar a la pantalla de registro.
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'register_screen');
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
