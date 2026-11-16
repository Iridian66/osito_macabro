import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';  //3.1 Importar el timer 
import 'welcome_back.dart';
import 'package:osito_macabro/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:osito_macabro/services/auth_service.dart';
import 'package:osito_macabro/screens/forgot_password.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // <-- Corregido aquí

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
 //Control para mostrar/ocultar contraseña
  bool _obscure = true;
  // Evitar múltiples intentos mientras Firebase responde.
bool _isLoggingIn = false;

// 1.1 crear el cerebro de la animacion 
StateMachineController? _controller;
//SMI: State Machine Input  / 

SMIBool? _isChecking;
SMIBool? _isHandsUp;
SMITrigger? _trigSucess;
SMITrigger? _trigFail;

//3.2 variable del recorrido de la mirada
SMINumber? _numLook;

//3.3 Timer para detener la mirada al dejar de escribir 
Timer? _typingDebounce;


//1.2 Crear las variables para FocusNode
final _emailFocus = FocusNode();
final _passwordFocus = FocusNode();

//4.1 cONTROLLERS QUE MANIPULAN LO QUE EL USUARIO ESCRIBE
final _emailCtrl = TextEditingController();
final _passCtrl = TextEditingController();

//Errores para mostrarlo en la UI 
String? emailError;
String? passError;

//4.3 Validadores

bool isValidEmail(String email){
  final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return re.hasMatch(email);
}

bool isValidPassword(String pass) {
  final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );
  return re.hasMatch(pass);
  

}
 
//4.4 Dar accion al boton


Future<void> _onLogin() async {
  if (_isLoggingIn) return;

  final email = _emailCtrl.text.trim();
  final pass = _passCtrl.text;

  // Guardamos si el osito tenía las manos arriba antes de quitar el foco
  final hadHandsUp = _isHandsUp?.value ?? false;

  // Bajamos las manos y quitamos el teclado de inmediato
  FocusScope.of(context).unfocus();
  _typingDebounce?.cancel();
  _isChecking?.change(false);
  _isHandsUp?.change(false);
  _numLook?.value = 50.0;

  // 1. Evaluar errores de formato
  final eError = isValidEmail(email) ? null : 'Correo electrónico no válido';
  final pError = isValidPassword(pass)
      ? null
      : 'La contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y símbolo';

  if (eError != null || pError != null) {
    setState(() {
      emailError = eError;
      passError = pError;
    });

    // Si tenía las manos arriba, esperamos 700ms a que llegue al estado Idle
    if (hadHandsUp) {
      await Future.delayed(const Duration(milliseconds: 700));
    }
    if (!mounted) return;

    _trigFail?.fire();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Revisa tu correo y contraseña.')),
    );
    return;
  }

  // 2. Formato válido: consultar Firebase
  setState(() {
    emailError = null;
    passError = null;
    _isLoggingIn = true;
  });

  try {
    await AuthService().login(
      email: email,
      password: pass,
    );

    if (!mounted) return;

    // Si Firebase respondió muy rápido y aún estaba bajando las manos, esperamos
    if (hadHandsUp) {
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (!mounted) return;

    // Disparar animación de alegría
    _trigSucess?.fire();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Inicio de sesión correcto! 💗'),
        duration: Duration(seconds: 2),
      ),
    );

  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    // Si Firebase rechazó rápido y aún estaba bajando las manos, esperamos
    if (hadHandsUp) {
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (!mounted) return;

    // Disparar animación de tristeza
    _trigFail?.fire();

    String message = 'No se pudo iniciar sesión.';
    if (e.code == 'invalid-credential' ||
        e.code == 'wrong-password' ||
        e.code == 'user-not-found') {
      message = 'Correo o contraseña incorrectos.';
    } else if (e.code == 'invalid-email') {
      message = 'El correo electrónico no es válido.';
    } else if (e.code == 'too-many-requests') {
      message = 'Demasiados intentos. Intenta más tarde.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    if (!mounted) return;

    if (hadHandsUp) {
      await Future.delayed(const Duration(milliseconds: 600));
    }
    if (!mounted) return;

    _trigFail?.fire();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ocurrió un error al iniciar sesión.')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }
}











//2.2 Listeners(oyentes/chismosos)
@override
  void initState() {
   
    super.initState();
    _emailFocus.addListener((){
      //Verificar que no sea nulo
      if (_isHandsUp != null){
        //Manos abajo en el email
        _isHandsUp?.change(false);
      }
    });
    _passwordFocus.addListener((){
      //Manos arriba en password
      _isHandsUp?.change(_passwordFocus.hasFocus);
      //3.4 mirada neutra 
      _numLook?.value = 50.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla 
    final Size size =MediaQuery.of(context).size;
    return  Scaffold(
      body:SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/login_bear.riv',
                    stateMachines: ['Login Machine'],
                  //1.2 Vincular animacion
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                    'Login Machine',
                    );
        
                    // 1.3 Verificar que inicio bien 
                    if(_controller == null) return;
                    
        
                    //Agrega controlador al escenario /tablero
                    

                    if (_controller == null) return;

artboard.addController(_controller!);


        
                    //Vinculamos variables 
                    _isChecking = _controller!.findSMI('isChecking');
                    _isHandsUp = _controller!.findSMI('isHandsUp');
                    _trigSucess = _controller!.findSMI('trigSuccess');
                    _trigFail = _controller!.findSMI('trigFail');
                    //3.5 vincular numLook
                    _numLook = _controller!.findSMI('numLook');
        
                  },
                  
                  ),
                ),
                //Para separar espacio
                SizedBox(height:  10),
                // Campo Para email
                TextField(
                   //4.10 Enlazar controller
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
        
                  onChanged: (value) {
          if (_isHandsUp != null) {
            //No tapes los ojos al ver el email
           //  _isHandsUp!.change(false);
          }
           // Si esCheking es nulo 
          if (_isChecking == null) return;
          //Activar el modo chismoso
            _isChecking!.change(true);
            // 3.6 Implementar numLook
            //Ajustes de Límites del 0 al 100
            //80 es la medida calibracion
            final look = (value.length / 40.0 * 100.0).clamp(0.0, 100.0);
            //Clamp es el rango (abrazadera )
            _numLook?.value = look;
             
        
             //3.7 Debonce: si vuelve a teclear, reinicia el contador
             //cancelar cualquier timer exitstente 
             _typingDebounce?.cancel();
             //crear un nuevo timer 
             _typingDebounce = Timer(Duration(seconds:3), (){
        //Si se cierra la pantalla, quita ek contador
        if (!mounted) return;
        //Mirada neutra
        _isChecking?.change(false);
             });
        },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: emailError,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                ),
        
                //Para separar espacio
                SizedBox(height:  10),
                
                
                //Campo de texto para contraseña
                //Para mostrar el tipo de teclado 
                TextField(
                  //4.10 Enlazar controller
                  controller: _passCtrl,
                 //2.3 Asiganr foco al campo de texto 
                 focusNode: _passwordFocus,
                  onChanged: (value){
                    if(_isChecking != null) {
        
                      //No tapes los ojos al ver email
                     // _isChecking!.change(false);
                    } 
                    // si isCheking es nulo 
                    if (_isHandsUp == null) return;
        
                    //Activar el modo chismoso
                    _isHandsUp!.change(true);
                    
                  },
        
        
        
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    //4.11 mostrar el texto de error 
                    errorText: passError,
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      // If ternario
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                     onPressed: (){
                      //Refrescar el icono 
                      setState(() {
                        _obscure = !_obscure;
                        
                      });
                     },
                     ),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                ),
                SizedBox(height: 10),
                //Texto olvide la contraseña
                SizedBox(
  width: size.width,
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen(),
        ),
      );
    },
    child: const Text(
      'Forgot password?',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: Color(0xFFAD4D79),
        decoration: TextDecoration.underline,
      ),
    ),
  ),
),
                const SizedBox(height: 10),
                //4.13 Boton de login
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _isLoggingIn ? null : _onLogin,
                  child: _isLoggingIn
    ? const CircularProgressIndicator(color: Colors.white)
    : const Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
  Flexible(
    child: const Text("Don't have an account?"),
  ),
  TextButton(onPressed: (){
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SignupScreen(),
    ),
  );
  },
                       child: Text('Sign up', style: TextStyle(
                        color: Colors.black,
                        //Subrayado
                        decoration: TextDecoration.underline,
                        //Negritas
                        fontWeight: FontWeight.bold
                       ),))
                    ],
                  ),
                )
              
              ],
            ),
            ),
            ),
      ),
    );
  }


  @override
void dispose() {
  // Liberar los recursos utilizados por los campos.
  _emailFocus.dispose();
  _passwordFocus.dispose();
  _emailCtrl.dispose();
  _passCtrl.dispose();

  // Cancelar el temporizador.
  _typingDebounce?.cancel();

  super.dispose();
}
}