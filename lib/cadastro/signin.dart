// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, avoid_unnecessary_containers, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_chat_ong_user/controller/controller.dart';
import 'package:meu_chat_ong_user/servicos/banco_de_dados.dart';



class SignInController extends GetxController {
  late MeuControllerGlobal meuControllerGlobal;
  var email = TextEditingController();
  var senha = TextEditingController();
  String nome = '';
  String id = '';
  double tamanhoTela = 0;


  login(context) async{
    if(email.text.isNotEmpty || senha.text.isNotEmpty){
      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: senha.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login bem sucedido'),backgroundColor: Color.fromARGB(155, 33, 250, 0),));
        QuerySnapshot querySnapshot = await BandoDeDados.getUsuarioPorEmail(email.text);
        nome = "${querySnapshot.docs[0]['Nome']}";
        id = "${querySnapshot.docs[0]['Id']}";
        String imagemPerfil = "${querySnapshot.docs[0]['ImagemPerfil']}";
        meuControllerGlobal.salvarEmail(email.text);
        meuControllerGlobal.salvarId(id);
        meuControllerGlobal.salvarNome(nome);
        meuControllerGlobal.salvarImagemPerfil(imagemPerfil);
        meuControllerGlobal.tamanhoTela = tamanhoTela;
        
        Get.toNamed('/chat');
      } on FirebaseException catch(e){
        if(e.code == 'invalid-credential'){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('E-mail ou senha incorreta'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));
        }
        else if(e.code == 'wrong-password'){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha incorreta'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));
        }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ocorreu um erro inesperado, tente novamente mais tarde'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));
        }
        print(e);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insira Email e senha'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));

    }
    
  }

  Future<String> func() async {
    meuControllerGlobal = Get.find();
  
    return 'a';
  }
}

class SignIpPage extends StatelessWidget {
  SignIpPage({super.key});
  var signInController = Get.put(SignInController());
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      home: GetBuilder<SignInController>(
        init: SignInController(),
        builder: (_) {
          return Scaffold(
            body:FutureBuilder(
            future: signInController.func(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  signInController.tamanhoTela = MediaQuery.of(context).size.width;
                  return 
                  Container(
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color.fromARGB(222, 237, 77, 14), Color.fromARGB(255, 255, 19, 19)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(MediaQuery.of(context).size.width, 90),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,50,0,0),
                                child: Center(
                                  child: Text('Sign in',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text('Entre na sua conta',
                                  style: TextStyle(
                                    color: Color.fromARGB(200, 255, 255, 255),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(10),
                                
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                                    width: MediaQuery.of(context).size.width,
                                    
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text('Email',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 0.4,
                                              color: Colors.black45
                                  
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: TextFormField(
                                            controller: signInController.email,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: Icon(Icons.mail_outline,color: Color.fromARGB(165, 243, 90, 2),)

                                            ),
                                            
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text('Senha',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 0.4,
                                              color: Colors.black45
                                  
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: TextFormField(
                                            controller: signInController.senha,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: Icon(Icons.password,color: Color.fromARGB(165, 243, 90, 2),),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                Get.toNamed('/esqueciSenha');
                                                print('abrir tela de esqueci a senha');
                                              },
                                              child: Text('Esqueceu a senha?',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            signInController.login(context);    
                                          },
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(35,10,35,10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Color.fromARGB(222, 243, 91, 2),
                                              ),
                                              child: Text('Entrar',style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
                                            ),
                                          ),
                                        )
                                        
                                      ],
                      
                                    ),
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Ainda não possui um conta?  ',style: TextStyle(fontWeight: FontWeight.bold),),
                                  GestureDetector(
                                    onTap: (){
                                      print('abrir tela de cadastro');
                                      Get.toNamed('/signup');
                                    },
                                  child: Text('Cadastre-se agora!',style: TextStyle(fontWeight: FontWeight.bold,color:Color.fromARGB(255, 255, 72, 0) ),)),

                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                  );

                } else {
                  return Text('erro');
                }
              } else if (snapshot.hasError) {
                return Text('Erro ao carregar a tela: ${snapshot.error}');
              } else {
                return Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 253, 72, 0),));
              }
            },
          ),

          );
        },
      ),
    );
  }
}
