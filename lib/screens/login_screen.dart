import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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
SMIBool? _trigSucess;
SMITrigger? _trigFail;

//1.2 Crear las variables para FocusNode
final _emailFocus = FocusNode();
final _passwordFocus = FocusNode();


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

                },
                
                ),
              ),
              //Para separar espacio
              SizedBox(height:  10),
              // Campo Para email
              TextField(
                focusNode: _emailFocus,

                onTap: () {
  if (_isHandsUp != null) {
    //No tapes los ojos al ver el email
   //  _isHandsUp!.change(false);
  }
   // Si esCheking es nulo 
  if (_isChecking == null) return;
  //Activar el modo chismoso
    _isChecking!.change(true);
  
},
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
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
                  hintText: 'Contraseña',
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
    super.dispose();
  }
}