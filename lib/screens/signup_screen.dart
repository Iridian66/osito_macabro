
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:osito_macabro/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controladores para obtener lo que escribe el usuario.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Servicio que conecta con Firebase.
  final AuthService _authService = AuthService();

  // Clave para validar el formulario.
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Registrar una cuenta nueva.
  Future<void> _register() async {
    // Comprobar que todos los campos sean válidos.
    if (!_formKey.currentState!.validate()) return;

    // Comprobar que ambas contraseñas coincidan.
    if (_passwordController.text !=
        _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden 💗'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Registrar al usuario en Firebase.
      await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Mostrar confirmación del registro.
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Cuenta creada! 💗'),
          content: const Text(
            'Tu cuenta se registró correctamente.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'No se pudo crear la cuenta.';

      if (e.code == 'email-already-in-use') {
        message = 'Este correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo electrónico no es válido.';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Liberar los controladores cuando se cierre la pantalla.
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF0F5),
        elevation: 0,
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            color: Color(0xFFAD4D79),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFAD4D79),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFE88BAF),
                  size: 65,
                ),

                const SizedBox(height: 15),

                const Text(
                  '¡Únete a nosotros!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAD4D79),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Crea tu cuenta para comenzar 💗',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),

                // Campo de nombre.
                TextFormField(
                  controller: _nameController,
                  decoration: _decoration(
                    'Nombre completo',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe tu nombre';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 17),

                // Campo de correo electrónico.
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoration(
                    'Correo electrónico',
                    Icons.email_outlined,
                  ),
                 validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Escribe tu correo';
  }

  final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  if (!re.hasMatch(value.trim())) {
    return 'Ingresa un correo válido';
  }

  return null;
},
                ),

                const SizedBox(height: 17),

                // Campo de contraseña.
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _decoration(
                    'Contraseña',
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFFAD4D79),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Escribe una contraseña';
  }

  final re = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  if (!re.hasMatch(value)) {
    return 'Usa 8 caracteres, mayúscula, minúscula, número y símbolo';
  }

  return null;
},
                ),

                const SizedBox(height: 17),

                // Confirmación de contraseña.
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _decoration(
                    'Confirmar contraseña',
                    Icons.lock_reset,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFFAD4D79),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu contraseña';
                    }

                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Botón para crear la cuenta.
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE88BAF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Crear mi cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Diseño reutilizable para los campos de texto.
  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFAD4D79),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFF3C3D6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE88BAF),
          width: 2,
        ),
      ),
    );
  }
}
