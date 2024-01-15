// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, avoid_unnecessary_containers, avoid_print, unnecessary_import, unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_chat_ong_user/controller/controller.dart';
import 'package:meu_chat_ong_user/servicos/banco_de_dados.dart';
class EsqueciSenhaController extends GetxController {
  late MeuControllerGlobal meuControllerGlobal;
  var email = TextEditingController();



  esqueciSenha(context) async{
    if(email.text.isNotEmpty ){
      try{
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Um email para recuperar senha foi enviado'),backgroundColor: Color.fromARGB(155, 33, 250, 0),));
        ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller = ScaffoldMessenger.of(context)
        .showSnackBar(  
          SnackBar(
            content: Text('Um email para recuperar senha foi enviado'),
            backgroundColor: Color.fromARGB(155, 33, 250, 0),
          ),
        );
        await controller.closed;

        Get.toNamed('/');
      } on FirebaseException catch(e){
        if(e.code == "user-not-found"){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario não encontrado, tente novamente!'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));
        }
        else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ocorreu um erro inesperado, tente novamente mais tarde'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));
        }
        print(e);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insira seu Email'),backgroundColor: Color.fromARGB(155, 250, 0, 0),));

    }
    
  }

  Future<String> func() async {
    meuControllerGlobal = Get.find();
    return 'a';
  }
}

class EsqueciSenhaPage extends StatelessWidget {
  EsqueciSenhaPage({super.key});
  var esqueciSenhaController = Get.put(EsqueciSenhaController());
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GetBuilder<EsqueciSenhaController>(
        init: EsqueciSenhaController(),
        builder: (_) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              toolbarHeight: 100,
              forceMaterialTransparency: true,
              leading: IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back_ios,color: Color.fromARGB(255, 255, 255, 255),)),
            ),
            body:FutureBuilder(
            future: esqueciSenhaController.func(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
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
                                  child: Text('Recupere Sua Senha',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold
                                    
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text('Digite seu Email',
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
                                            controller: esqueciSenhaController.email,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              prefixIcon: Icon(Icons.mail_outline,color: Color.fromARGB(165, 243, 90, 2),)

                                            ),
                                            
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                         
                                        SizedBox(
                                          height: 10,
                                        ),
                                        
                                        SizedBox(
                                          height: 30,
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            esqueciSenhaController.esqueciSenha(context);    
                                          },
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(35,10,35,10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: Color.fromARGB(222, 243, 91, 2),
                                              ),
                                              child: Text('Enviar email',style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),),
                                            ),
                                          ),
                                        )
                                        
                                      ],
                      
                                    ),
                                  ),
                                ),
                              ),

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
