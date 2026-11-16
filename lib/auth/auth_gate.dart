
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:osito_macabro/screens/login_screen.dart';
import 'package:osito_macabro/screens/home_screen.dart';
import 'package:osito_macabro/services/auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  // Servicio de autenticación.
  final AuthService _authService = AuthService();

  // Usuario que tiene la sesión activa.
  User? _user;

  // Indica si estamos comprobando la sesión.
  bool _loading = true;

  // Temporizador para permitir la animación de Rive.
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Escuchar los cambios de autenticación de Firebase.
    _authService.authStateChanges.listen((User? user) {

      // Cancelar cualquier navegación pendiente.
      _navigationTimer?.cancel();

      if (user == null) {
        // No existe una sesión activa.
        setState(() {
          _user = null;
          _loading = false;
        });

      } else {
        // Existe un usuario autenticado.
        // Esperar para permitir la animación de éxito de Rive.
        _navigationTimer = Timer(
          const Duration(milliseconds: 1800),
          () {
            if (!mounted) return;

            setState(() {
              _user = user;
              _loading = false;
            });
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Mostrar indicador mientras se comprueba la sesión.
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF0F5),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE88BAF),
          ),
        ),
      );
    }

    // Si hay usuario, mostrar Home.
    if (_user != null) {
      return const HomeScreen();
    }

    // Si no hay usuario, mostrar Login.
    return const LoginScreen();
  }
}
