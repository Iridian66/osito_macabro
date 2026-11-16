import 'package:flutter/material.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  // Mostrar u ocultar contraseña
  bool _obscurePassword = true;

  // Estado de Remember me
  bool _rememberMe = false;

  // PISTA 1:
  // Indica si la animación está actualmente en ejecución.
  bool _isAnimating = false;

  // Duración de la animación
  static const Duration _animationDuration =
      Duration(milliseconds: 400);

  // Controla Remember me
  Future<void> _toggleRememberMe() async {
    // PISTA 2:
    // Si la animación está ejecutándose,
    // no hacemos nada y evitamos otro toque.
    if (_isAnimating) {
      return;
    }

    // Comienza la animación
    setState(() {
      _isAnimating = true;
      _rememberMe = !_rememberMe;
    });

    // Esperamos a que termine la animación
    await Future.delayed(_animationDuration);

    // Verificamos que la pantalla todavía exista
    if (!mounted) {
      return;
    }

    // La animación terminó
    setState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // TÍTULO
            const Center(
              child: Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // DESCRIPCIÓN
            const Center(
              child: Text(
                'Sign in to access your personalized travel\n'
                'plans made for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 35),

            // EMAIL
            const Text(
              'Email address',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PASSWORD
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),

                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // REMEMBER ME + FORGOT PASSWORD
            Row(
              children: [
                // PISTA 2:
                // GestureDetector deja de responder mientras
                // _isAnimating sea true.
                GestureDetector(
                  onTap: _isAnimating
                      ? null
                      : _toggleRememberMe,
                  child: AnimatedContainer(
                    duration: _animationDuration,
                    curve: Curves.easeInOut,

                    width: 24,
                    height: 24,

                    decoration: BoxDecoration(
                      color: _rememberMe
                          ? Colors.pinkAccent
                          : Colors.transparent,

                      borderRadius: BorderRadius.circular(5),

                      border: Border.all(
                        color: _rememberMe
                            ? Colors.pinkAccent
                            : Colors.grey,
                        width: 2,
                      ),
                    ),

                    child: AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: 250),

                      child: _rememberMe
                          ? const Icon(
                              Icons.check,
                              key: ValueKey('checked'),
                              color: Colors.white,
                              size: 18,
                            )
                          : const SizedBox(
                              key: ValueKey('unchecked'),
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // REMEMBER ME
                const Flexible(
                  child: Text(
                    'Remember me',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // FORGOT PASSWORD
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      // Después conectaremos Forgot Password.
                    },
                    child: const Text(
                      'Forgot password?',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        decoration:
                            TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // SIGN IN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // SIGN UP
            Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Flexible(
                    child: Text(
                      "Don't have an account?",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      // Después conectaremos
                      // Create your account.
                    },

                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration:
                            TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}