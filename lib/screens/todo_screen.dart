import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Pantalla principal para mostrar y agregar tareas.
///
/// Esta pantalla permite al usuario autenticado ver sus tareas almacenadas en
/// Cloud Firestore, agregarlas y marcarlas como completadas o eliminarlas.

final _firestore = FirebaseFirestore.instance;

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

/// Estado asociado a la pantalla [TodoScreen].
///
/// Gestiona la autenticación, obtención de usuario actual y el flujo de tareas.

class _TodoScreenState extends State<TodoScreen> {
  // Instancia de FirebaseAuth para la autenticación.
  final _auth = FirebaseAuth.instance;

  // Usuario autenticado actualmente.
  User? loggedInUser;

  // Variable para guardar temporalmente el texto de la tarea que se está ingresando.
  String? taskText;

  // Controlador para el campo de texto de la tarea.
  TextEditingController taskTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Obtener el usuario que ha iniciado sesión al cargar la pantalla
    getCurrentUser();
  }

  // Obtiene el usuario actual autenticado y actualiza el estado.
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          // Botón para cerrar sesión.
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('To-Do'),
        backgroundColor: Color(0xFFAED581),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (loggedInUser == null)
              const Center(child: CircularProgressIndicator())
            else
              // Lista de tareas en tiempo real. (! asegura que loggedInUser no es nulo)
              TasksStream(user: loggedInUser!),

            // Campo de texto para agregar nuevas tareas.
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFAED581), width: 2.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskTextController,
                      onChanged: (value) {
                        taskText = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Agregar tarea',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Solo enviar si hay texto no vacío
                      if (taskText != null && taskText!.trim().isNotEmpty) {
                        //Añadir el mensaje a la colección 'tasks' en Firestore
                        _firestore.collection('tasks').add({
                          'task': taskText!.trim(),
                          'sender': loggedInUser!.email,
                          'timestamp':
                              FieldValue.serverTimestamp(), // Marca de tiempo automática del servidor
                          'completed': false,
                        });
                      }
                      //Limpiar el campo de texto después de enviar
                      taskTextController.clear();
                      taskText = null;
                    },
                    child: Text(
                      'Agregar',
                      style: TextStyle(color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que representa el flujo de tareas en tiempo real desde Firestore.
///
/// Solo muestra tareas del usuario autenticado.
class TasksStream extends StatelessWidget {
  // Crea una instancia de [TasksStream] con el usuario autenticado.
  const TasksStream({super.key, required this.user});

  // Usuario autenticado cuyos datos se mostrarán.
  final User user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //Escucha la colección 'task' ordenada por 'timestamp' para actualizaciones en tiempo real
      stream:
          _firestore
              .collection('tasks')
              .orderBy('timestamp', descending: false)
              .snapshots(),
      builder: (context, snapshot) {
        //Mostrar indicador de carga mientras no hay datos
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xFF388E3C),
            ),
          );
        }

        // Acceder a los documentos recibidos de Firestore
        final tasks = snapshot.data!.docs.reversed;
        List<TaskBubble> taskBubbles = [];
        for (var task in tasks) {
          final taskText = task['task'];
          final taskSender = task['sender'];
          final docId = task.id;

          // Usuario actual para comparar
          final currentUser = user.email;

          if (currentUser == taskSender) {
            final isCompleted = task['completed'] ?? false;
            final taskBubble = TaskBubble(
              sender: taskSender,
              text: taskText,
              docId: docId,
              completed: isCompleted,
            );
            taskBubbles.add(taskBubble);
          }
        }

        return Expanded(
          child: ListView(
            reverse: false,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: taskBubbles,
          ),
        );
      },
    );
  }
}

/// Widget que muestra una tarea individual con opción de completarla o eliminarla.
class TaskBubble extends StatelessWidget {
  // Crea un nuevo [TaskBubble] para representar una tarea.
  const TaskBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.docId,
    required this.completed,
  });

  final String sender; // Email del remitente de la tarea.
  final String text; // Texto de la tarea.
  final String docId; // ID del documento en Firestore.
  final bool completed; // Estado de finalización de la tarea.

  // Alterna el estado de la tarea en Firestore (completada/no completada).
  void toggleCompleted(bool? value) {
    _firestore.collection('tasks').doc(docId).update({'completed': value});
  }

  // Elimina la tarea tras la confirmación del usuario.
  void deleteTask(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('¿Eliminar tarea?'),
            content: Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Eliminar'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      try {
        await _firestore.collection('tasks').doc(docId).delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tarea eliminada')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          //Mostrar el email del remitente encima del mensaje
          Material(
            elevation: 5.0,
            color: Color(0xFFDCEDC8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                    ),
                  ),
                ),
                Checkbox(
                  checkColor: Colors.white,
                  activeColor: Color(0xFF388E3C),
                  value: completed,
                  onChanged: toggleCompleted,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteTask(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
