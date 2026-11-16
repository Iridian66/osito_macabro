
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:osito_macabro/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();

  bool _isLoading = false;
  String? _emailError;

  // Control del contador para reenviar el correo.
  Timer? _resendTimer;
  int _secondsRemaining = 0;

  // Validar el formato del correo.
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  // Iniciar el contador de 30 segundos.
  void _startResendTimer() {
    setState(() {
      _secondsRemaining = 30;
    });

    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _secondsRemaining--;
        });

        if (_secondsRemaining <= 0) {
          timer.cancel();
        }
      },
    );
  }

  // Enviar el correo de recuperación mediante Firebase.
  Future<void> _sendResetEmail() async {
    // Evitar envíos simultáneos o durante el contador.
    if (_isLoading || _secondsRemaining > 0) return;

    final email = _emailCtrl.text.trim();

    setState(() {
      _emailError = isValidEmail(email)
          ? null
          : 'Escribe un correo electrónico válido';
    });

    if (_emailError != null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().resetPassword(email);

      if (!mounted) return;

      // Iniciar los 30 segundos después del envío exitoso.
      _startResendTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Si la cuenta existe, recibirás un correo para recuperar tu contraseña. 💗',
          ),
          duration: Duration(seconds: 4),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo procesar la solicitud. Intenta nuevamente.',
          ),
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF0F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFAD4D79),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(
            color: Color(0xFFAD4D79),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE88BAF).withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                children: [

                  // Osito decorativo.
                  const Text(
                    'ʕ •ᴥ• ʔ',
                    style: TextStyle(
                      fontSize: 75,
                      color: Color(0xFFAD4D79),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    '¿Olvidaste tu contraseña?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAD4D79),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    '¡No te preocupes! 💗 '
                    'Escribe el correo electrónico de tu cuenta '
                    'y te enviaremos un enlace para crear '
                    'una contraseña nueva.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Campo de correo electrónico.
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Correo electrónico',
                      errorText: _emailError,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFFE88BAF),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFF0F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Botón de envío y reenvío.
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _secondsRemaining > 0)
                          ? null
                          : _sendResetEmail,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        disabledBackgroundColor: const Color(0xFFF3C5D6),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              _secondsRemaining > 0
                                  ? 'Reenviar en $_secondsRemaining s'
                                  : 'Enviar enlace de recuperación',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mensaje del contador.
                  if (_secondsRemaining > 0)
                    Text(
                      '¿No te llegó el correo? '
                      'Podrás solicitar otro en $_secondsRemaining segundos.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFAD4D79),
                      ),
                    )
                  else
                    const Text(
                      'Revisa también tu carpeta de spam. 💌',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Volver al inicio de sesión',
                      style: TextStyle(
                        color: Color(0xFFAD4D79),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
