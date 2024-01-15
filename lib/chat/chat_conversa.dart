// ignore_for_file: must_be_immutable, unnecessary_string_escapes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_chat_ong_user/chat/chat.dart';
import 'package:meu_chat_ong_user/controller/controller.dart';
import 'package:intl/intl.dart';
import 'package:meu_chat_ong_user/servicos/banco_de_dados.dart';
import 'package:random_string/random_string.dart';

class ChatConversaController extends GetxController {
  late MeuControllerGlobal meuControllerGlobal;
  String idMensagem = '';
  String id = Get.arguments[0]; 
  String nome = Get.arguments[1]; 
  var mensagem = TextEditingController();
  List<Widget> listaDeMensagens = [];
  RxInt addSingleMessage = 0.obs;
  late ChatController chatController;
  

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamMensagem;

  
  getMensagens() async {
    String chatRoomId = getChatRoomByUserName(meuControllerGlobal.obterId(), id);
      streamMensagem = (await BandoDeDados.getMensagens(chatRoomId)) as Stream<QuerySnapshot<Map<String, dynamic>>>?;
      streamMensagem?.listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        listaDeMensagens.clear();
      if (snapshot.docs.isNotEmpty) {
        for (DocumentSnapshot<Map<String, dynamic>> ds in snapshot.docs) {
          bool enviadoPorMim = ds['EnviadoPor'] == meuControllerGlobal.obterNome();
          String mensagemTexto = ds['mensagem'];
          String horaMinuto = ds['ts'];
          String nomeUsuario = ds['EnviadoPor'];
          // Imprimir os dados da mensagem
          chatMensagemTile(mensagemTexto,horaMinuto,nomeUsuario,enviadoPorMim);
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

  void addMensagem(String mensagem) async {
  if (mensagem.isNotEmpty) {
    addSingleMessage.value += 1;
    DateTime now = DateTime.now();
    var saoPaulo = now.toLocal().toUtc().add(const Duration(hours: -3)); 
    String dataFormatada = DateFormat('hh:mma').format(saoPaulo);
    
    Map<String, dynamic> infoMensagemMap = {
      'mensagem': mensagem,
      'EnviadoPor': meuControllerGlobal.obterNome(),
      'ts': dataFormatada,
      'time': FieldValue.serverTimestamp(),
    };
    if (idMensagem == '') {
      idMensagem = randomAlphaNumeric(10);
    }

    

    String chatRoomId = getChatRoomByUserName(meuControllerGlobal.obterId(), id);
    
    listaDeMensagens.add(ChatMessageSenderWidget(message: mensagem,horaMinuto: dataFormatada));

    BandoDeDados.addMensagem(chatRoomId, idMensagem, infoMensagemMap).then((value) {

      Map<String, dynamic> ultimaMensagemEnviadaMap = {
        'ultimaMensagem': mensagem,
        'ultimaMensagemEnviadaPor': meuControllerGlobal.obterNome(),
        'ultimaMensagemTs': dataFormatada,
        'time': FieldValue.serverTimestamp(),
      };
      BandoDeDados.atualizaUltimaMensagem(chatRoomId, ultimaMensagemEnviadaMap);
    });
    idMensagem = '';
  }  
}

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>?> func() async {
    chatController = Get.find();
    meuControllerGlobal = Get.find();
    await getMensagens();
    return streamMensagem;
  }

  void chatMensagemTile(String mensagem,String horaMinuto,String nomeUsuario, bool enviadoPorMim){
    Widget mensagemWidget;
    if(enviadoPorMim == true) {
      mensagemWidget = ChatMessageSenderWidget(message: mensagem,horaMinuto: horaMinuto);  
    } 
    else{
      mensagemWidget = ChatMessageReceiverWidget(message: mensagem,horaMinuto: horaMinuto,);
    }
    listaDeMensagens.add(mensagemWidget);
    addSingleMessage.value +=1;
    

  }

}

class ChatConversaPage extends StatelessWidget {
  var chatConversaController = Get.put(ChatConversaController());

  ChatConversaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GetBuilder<ChatConversaController>(
        init: ChatConversaController(),
        builder: (_) {
          return Scaffold(
            backgroundColor:const Color.fromARGB(222, 243, 91, 2),
            body: FutureBuilder(
              future: chatConversaController.func(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.12,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 255, 255, 255), size: 14),
                              ),
                              Text(
                                chatConversaController.nome,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.8,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child:Obx(
                                () => SingleChildScrollView(
                                    reverse: true,
                                    child: chatConversaController.addSingleMessage.value != -1 ?  Column(
                                      children: chatConversaController.listaDeMensagens
                                    ): const SizedBox(),
                                  ),
                              ),
                              ),
    
                        ),
                        Container(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Material(
                            elevation: 15,
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: const Color.fromARGB(137, 255, 255, 255),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller:chatConversaController.mensagem,
                                      decoration: InputDecoration(
                                        hintText: 'Digite algo',
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            chatConversaController.addMensagem(chatConversaController.mensagem.text);
                                            chatConversaController.mensagem.clear();
                                          },
                                          icon: const Icon(Icons.send),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Text('erro');
                  }
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar a tela: ${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 253, 72, 0)));
                }
              },
            ),
          );
        },
      ),
    );
  }
}


class ChatMessageReceiverWidget extends StatelessWidget {
  final String message;
  final String horaMinuto;


  const ChatMessageReceiverWidget({Key? key, required this.message, required this.horaMinuto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Container(
        margin: EdgeInsets.only(right: MediaQuery.of(context).size.width / 3),
        padding: const EdgeInsets.fromLTRB(8,8,8,4),
        alignment: Alignment.bottomLeft,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 238, 143, 60),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  textAlign: TextAlign.end,
                  horaMinuto,
                  style: const TextStyle(fontSize: 10,color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class ChatMessageSenderWidget extends StatelessWidget {
  final String message;
  final String horaMinuto;

  const ChatMessageSenderWidget({Key? key, required this.message, required this.horaMinuto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Container(
        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width / 3),
        padding: const EdgeInsets.all(8),
        alignment: Alignment.bottomLeft,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 60, 205, 238),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  textAlign: TextAlign.end,
                  horaMinuto,
                  style: const TextStyle(fontSize: 10,color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}