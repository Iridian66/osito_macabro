
import 'package:flutter/material.dart';

// 1. Importar Firebase Core para inicializar Firebase.
import 'package:firebase_core/firebase_core.dart';

// 2. Importar las opciones generadas por FlutterFire.
import 'firebase_options.dart';

// 3. Importar nuestra pantalla original del osito.
import 'package:osito_macabro/screens/login_screen.dart';


// FUNCIÓN PRINCIPAL DE LA APLICACIÓN
Future<void> main() async {

  // 4. Preparar Flutter antes de ejecutar operaciones asíncronas.
  WidgetsFlutterBinding.ensureInitialized();

  try {

    // 5. Inicializar Firebase utilizando la configuración de FlutterFire.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 6. Confirmar que Firebase inició correctamente.
    debugPrint('Firebase conectado correctamente 💗');

  } catch (e) {

    // 7. Mostrar el error si Firebase no consigue inicializarse.
    debugPrint('Error al conectar Firebase: $e');

    // No continuar como si Firebase estuviera disponible.
    rethrow;
  }

  // 8. Ejecutar nuestra aplicación Flutter.
  runApp(const MyApp());
}


// WIDGET PRINCIPAL DE LA APLICACIÓN
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Osito Macabro',

      // Configuración visual de la aplicación.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
        ),
      ),

      // Conservamos el Login original del profesor.
      home: const LoginScreen(),
    );
  }
}
