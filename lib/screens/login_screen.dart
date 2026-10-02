import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';  //3.1 Importar el timer 

class LoginScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 //Control para mostrar/ocultar contraseña
  bool _obscure = true;

// 1.1 crear el cerebro de la animacion 
StateMachineController? _controller;
//SMI: State Machine Input  / Entrada de maquina de estado 
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
void _onLogin(){
  
  // 4.5 De lo que escribio el usuario, quitar espacios en blanco
  final email = _emailCtrl.text.trim();
  final pass = _passCtrl.text;

  //4.6 Evaluar los errores 
  final eError = isValidEmail(email) ? null : "Invalid email";
  final pError = isValidPassword(pass)? null : "Invalid password";

  //4.7 Avisar que hubo cambios
  setState(() {
   emailError = eError;
   passError = pError;
  });
  //4.8 cerrar el teclado y bajar las manos 
  FocusScope.of(context).unfocus(); //Quita el foco
  _typingDebounce?.cancel();
  _isChecking?.change(false);
  _isHandsUp?.change(false);
  _numLook?.value = 50.0;

  //4.9 Activar triggers
  if(eError == null && pError == null){
    _trigSucess?.fire();

  } else {
    _trigFail?.fire();

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
      body:SafeArea(
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
                  artboard.addController(_controller!);

                  //Agrega controlador al escenario /tablero
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
                child: const Text( 'Forgot password?',
                //aLINEAR A la derecha 
                textAlign: TextAlign.right,
                style: TextStyle(decoration: TextDecoration.underline)
                
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
                onPressed: _onLogin,
                child: Text('Login', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(onPressed: (){},
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
    );
  }

  @override
  void dispose() {
    //2.4 Liberar el espacio en memoria 
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel(); //3.9 Eliminar el timer 
    super.dispose();
  }
}