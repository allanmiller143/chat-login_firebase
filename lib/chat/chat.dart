// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, unnecessary_string_escapes, avoid_function_literals_in_foreach_calls, avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meu_chat_ong_user/controller/controller.dart';
import 'package:meu_chat_ong_user/servicos/banco_de_dados.dart';


class ChatController extends GetxController {
  late MeuControllerGlobal meuControllerGlobal;
  RxBool barraDePesquisa = false.obs;
  var nome = TextEditingController();
  var queryResultado = [];
  var tempSearchStore = [];
  var temp = [];
  late String meuNome;
  late String meuEmail;
  late String meuId;
  List<Widget> listachats = [];
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;
  var listaDeIds = [];
  File? imageFile;

  getChatrooms() async {
      
      stream = (await BandoDeDados.getChatRooms(meuId)) as Stream<QuerySnapshot<Map<String, dynamic>>>?;
      stream?.listen((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      listachats.clear();
      listaDeIds.clear();
      
      if (snapshot.docs.isNotEmpty) {
        print(snapshot.size);
        for (DocumentSnapshot<Map<String, dynamic>> ds in snapshot.docs) {
          
          print(ds.data());
          var idContato = '';
          if(ds.data()?['users'][0] == meuId){
            idContato = ds.data()?['users'][1];
          }else{
            idContato = ds.data()?['users'][0];
          }
          var user = await BandoDeDados.getUsuarioPorId(idContato);
          var info = {
            'ultimaMensagem' : ds.data()?['ultimaMensagem'],
            'Id' : idContato,
            'ultimaMensagemTs' : ds.data()?['ultimaMensagemTs'],
            'Nome': user.docs[0]['Nome'],
            'ImagemPerfil' : user.docs[0]['ImagemPerfil'],
          };
        
          if(!listaDeIds.contains(idContato)){
            listachats.add(contruirCard(info));
            listaDeIds.add(idContato);
          } 
          barraDePesquisa.value = !barraDePesquisa.value;
          barraDePesquisa.value = !barraDePesquisa.value;
        }
      }
    });
  }


  getChatRoomByUserName(String a,String b){
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    }else{
      return "$a\_$b";
    }
  }
  Widget contruirCard(info) {
    return 
    Padding(
      padding: const EdgeInsets.fromLTRB(0,0,0,20),
      child: GestureDetector(
        onTap: () async{
          barraDePesquisa.value = false;
          tempSearchStore = [];
          queryResultado = [];

          var chatRoomId = getChatRoomByUserName(meuId, info['Id']); // quem envia e quem recebe 
          Map<String, dynamic> chatRoomInfoMap = {
            'users' : [meuId,info['Id']],
          };

          await BandoDeDados.criaChatRoom(chatRoomId, chatRoomInfoMap);
          Get.toNamed('/chatConversa',arguments: [info['Id'], info['Nome']]);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: info['ImagemPerfil'] != '' ?  Image.network(info['ImagemPerfil'],fit: BoxFit.cover,width: double.infinity,height: double.infinity,):
                    Image.asset('assets/perfil.png',fit: BoxFit.cover,width: double.infinity,height: double.infinity,)
                  )
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5,),
                    Text(
                      info['Nome'],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15
                      ),
                    ),

                    info['ultimaMensagem'] != null?
                    SizedBox(
                      width: meuControllerGlobal.tamanhoTela / 2,
                      child: Text(
                        info['ultimaMensagem'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Adicione essa linha
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                      ),
                    ):
                    Text(
                      'Digite uma mensagem',
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 14
                      ),
                    ),
                  ],
                ),
              ],
            ),
            info['ultimaMensagemTs'] != null?
            Text(
              info['ultimaMensagemTs'],
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12
              ),
            ):
            SizedBox()
          ],
        ),
      ),
    );
  }
  buscaInicial(valor) async {
    if (valor.length == 0) {
      queryResultado = [];
      tempSearchStore = [];
      
    } else {
      var capitalizedValor = valor[0].toUpperCase() + valor.substring(1);
      barraDePesquisa.value = true;

      if (queryResultado.isEmpty && valor.length == 1) {
        QuerySnapshot querySnapshot = await BandoDeDados.pesquisa(capitalizedValor);
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          queryResultado.add(querySnapshot.docs[i].data());
        }
      } else {
        tempSearchStore = [];
        queryResultado.forEach((element) {
          if (element['Nome'].toString().startsWith(capitalizedValor)) {
            print(element);
            tempSearchStore.add(element);
          }
        });
        if(tempSearchStore.isNotEmpty){
          barraDePesquisa.value = false;
          barraDePesquisa.value = true;
        } 
      }
    }
  }

  void pick(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      await BandoDeDados.saveImageToFirestore(imageFile!, meuControllerGlobal.obterId());

    }
  }
  
  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          // Conteúdo do BottomSheet
         height: 200,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Inserir uma foto',
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'AsapCondensed-Medium'),
                ),
              ),
              ListTile(
                title: Text(
                  'Galeria',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'AsapCondensed-Medium'),
                ),
                leading: Icon(
                  Icons.photo,
                  color: Color.fromARGB(255, 255, 84, 16),
                ),
                onTap: () {
                  pick(ImageSource.gallery);
                },
              ),
              ListTile(
                title: Text(
                  'Camera',
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'AsapCondensed-Medium'),
                ),
                leading: Icon(
                  Icons.camera_alt,
                  color: Color.fromARGB(255, 255, 84, 16),
                ),
                onTap: () {
                  pick(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>?>func() async {
    meuControllerGlobal = Get.find();
    meuNome = meuControllerGlobal.obterNome();
    meuEmail = meuControllerGlobal.obterEmail();
    meuId = meuControllerGlobal.obterId();
    //await imprimirValoresDaConsulta();
    await getChatrooms();
    return stream;
    
  }
}

class ChatPage extends StatelessWidget {
  ChatPage({super.key});
  var chatController = Get.put(ChatController());
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GetBuilder<ChatController>(
        builder: (_) {
          return Scaffold(
            backgroundColor: Color.fromARGB(222, 243, 91, 2),

            body:FutureBuilder(
            future: chatController.func(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(10,15,10,0),
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Obx(
                                ()=> Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    chatController.barraDePesquisa.value == false ?
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                      child: GestureDetector(
                                        onTap: (){
                                        },
                                        child: Row(
                                          children: [
                                            IconButton(
                                            onPressed: (){
                                              chatController.showBottomSheet(context);             
                                            },
                                            icon: Icon(Icons.menu,color: Color.fromARGB(255, 255, 255, 255),)),
                                            Text(
                                              chatController.meuControllerGlobal.obterNome(),
                                              style: TextStyle(
                                                color: Color.fromARGB(255, 255, 255, 255),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                                                          
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ):
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          borderRadius: BorderRadius.circular(25)
                            
                                        ),
                                        margin: EdgeInsets.fromLTRB(0,0,15,0),
                                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        
                                        child: TextFormField(
                                          onChanged: (value) {
                                            chatController.buscaInicial(value);
                                          },
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Procurar um contato',
                                            hintStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(255, 72, 68, 68),
                                              fontSize: 16
                                            )
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(30)
                                      ),
                                      child: IconButton(
                                        onPressed: (){
                                          chatController.barraDePesquisa.value = !chatController.barraDePesquisa.value;
                                        },
                                         icon: Icon(Icons.search,color: const Color.fromARGB(255, 255, 255, 255),)
                                      )
                                    )
                                  ],
                                ),
                              
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)
                                )
                              ),
                              child: Obx(
                                () => Column(
                                  children: [
                                    (chatController.barraDePesquisa.value == true && chatController.tempSearchStore.isNotEmpty) ?
                                    SingleChildScrollView(
                                      child: ListView(
                                        primary: false,
                                        shrinkWrap: true,
                                        children: chatController.tempSearchStore.map((e) {
                                          return chatController.contruirCard(e);
                                        }).toList(),
                                      ),
                                    ):
                                      SingleChildScrollView(
                                        child: Column(
                                        children: chatController.listachats,),                                  
                                      )                      
                                  ],
                                ),
                              )
                            ),
                          )
                        ], 
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
