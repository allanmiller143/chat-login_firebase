// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, avoid_print, avoid_unnecessary_containers, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_chat_ong_user/controller/controller.dart';
import 'package:meu_chat_ong_user/servicos/banco_de_dados.dart';
import 'package:random_string/random_string.dart';
//import 'package:random_string/random_string.dart';

class SignUpController extends GetxController {
  var nome = TextEditingController();
  var email = TextEditingController();
  var senha = TextEditingController();
  var confirmaSenha = TextEditingController();
  late MeuControllerGlobal meuControllerGlobal;
  double tamanhoTela = 0;

  cadastrar(context) async {
    if(senha.text.isNotEmpty && senha.text == confirmaSenha.text){
      print('entrei aqui');
      try{
        String id = randomAlphaNumeric(10);
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: senha.text);
        nome.text = nome.text[0].toUpperCase() + nome.text.substring(1);
        Map<String,dynamic> userInfoMap = {
          'Nome' : nome.text,
          'E-mail': email.text,
          'Id': id,
          'Pesquisa': nome.text[0],
          'ImagemPerfil': ''
        };

        meuControllerGlobal.salvarEmail(email.text);
        meuControllerGlobal.salvarId(id);
        meuControllerGlobal.salvarNome(nome.text);
        meuControllerGlobal.tamanhoTela = tamanhoTela;
        
        await BandoDeDados.addUsuarioDetalhes(userInfoMap, id);
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cadastro Realizado com sucesso')));
        Get.toNamed('/chat');
      }on FirebaseAuthException catch(e){
        if(e.code == 'weak-password'){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha fraca, por favor tente outra mais forte'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));
        }
        if(e.code == 'email-already-in-use'){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Esse email já possui conta'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));
        }
        print(e);
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insira todos os campos'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));

    }

  }

  Future<String> func() async {
    meuControllerGlobal = Get.find();
    return 'a';
  }
}

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  var signUpController = Get.put(SignUpController());
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GetBuilder<SignUpController>(
        init: SignUpController(),
        builder: (_) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              toolbarHeight: 100,
              forceMaterialTransparency: true,
              leading: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios,color: Color.fromARGB(255, 255, 255, 255),)),
            ),
            body:FutureBuilder(
            future: signUpController.func(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  signUpController.tamanhoTela = MediaQuery.of(context).size.width;
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
                                colors: [Color.fromARGB(222, 237, 77, 14) , Color.fromARGB(255, 255, 19, 19)],
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
                                  child: Text('SignUp',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text('Crie uma nova conta',
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
                                        Text('Nome',
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
                                            controller: signUpController.nome,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: Icon(Icons.mail_outline,color: Color.fromARGB(165, 243, 90, 2),)

                                            ),
                                            
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
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
                                            controller: signUpController.email,
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
                                            controller: signUpController.senha,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: Icon(Icons.password,color: Color.fromARGB(165, 243, 90, 2),),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text('Confirmar Senha',
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
                                            controller: signUpController.confirmaSenha,
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
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                print('abrir tela de cadastro');
                                                
                                              },
                                            child: Text('Cadastre-se agora!',style: TextStyle(
                                              fontWeight: FontWeight.bold,color:Color.fromARGB(255, 255, 72, 0),
                                              fontSize: 16
                                              ),

                                            )),

                                          ],
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                      ],
                      
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20,0,20,0),
                                child: GestureDetector(
                                  onTap: ()  {
                                    signUpController.cadastrar(context);
                                  },
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.fromLTRB(35,10,35,10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromARGB(222, 243, 91, 2),
                                      ),
                                      child: Center(child: Text('Cadastrar-se',style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                  );
                } else {
                  return Text('Nenhum pet disponível');
                }
              } else if (snapshot.hasError) {
                return Text('Erro ao carregar a lista de pets: ${snapshot.error}');
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
