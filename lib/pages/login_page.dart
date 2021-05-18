import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chat/widgets/boton_azul.dart';
import 'package:chat/widgets/logo.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/custom_input.dart';

import 'package:chat/services/auth_services.dart';

import 'package:chat/helpers/motrar_alerta.dart';

class LoginPage extends StatelessWidget {

 @override
 Widget build(BuildContext context) {
 return Scaffold(
     backgroundColor: Color(0xffF2F2F2), 
     body: SafeArea(
       child: SingleChildScrollView(
         physics: BouncingScrollPhysics(),
         child: Container(
           height: MediaQuery.of(context).size.height * 0.9,
           child: Column(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [

               Logo(titulo: 'Messenger',),

               _Form(),

               Labels( 
                 ruta: 'register',
                 titulo: '¿No tienes cuenta?',
                 subTitulo: 'Crea una ahora',
                ), 

               Text('Terminos y condiciones de uso', style: TextStyle(fontWeight: FontWeight.w200),)

             ],
           ),
         ),
       ),
     ),
   );
  }
}



class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {

  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>( context );

    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          
           CustomInput(
             icon: Icons.mail_outline,
             placeholder: 'Correo',
             keyboardType: TextInputType.emailAddress ,
             textController: emailCtrl,
           ),

           CustomInput(
             icon: Icons.lock_outline,
             placeholder: 'Contraseña',
             isPassword: true,
             textController: passCtrl,
           ),

          
          BotonAzul(
            text: 'Ingrese',
            onPressed: authService.autenticando ? null :  () async{

              // Quitar el foco de donde este( o el teclado)
              FocusScope.of(context).unfocus();

              final okLogin = await authService.login( emailCtrl.text.trim(), passCtrl.text.trim() );

              if( okLogin){
                // TODO: Conectar a nuestro socket service
                
                Navigator.pushReplacementNamed(context, 'usuarios');

              }else{
                // Mostrara alerta
                motrarAlerta(context, 'Login Incorrecto', 'Revise sus credenciales nuevamente');
              }
            },
          )
          
        ],
      ),
    );
  }
}

