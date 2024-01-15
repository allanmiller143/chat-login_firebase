// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:meu_chat_ong_user/controller/controller.dart';


class BandoDeDados{



  //adiciona informações sobre um usuario no firebase firestore
  static Future addUsuarioDetalhes(Map<String,dynamic> infoMap, String id)async{
    return await FirebaseFirestore.instance
    .collection("users")
    .doc(id)
    .set(infoMap);
  }


  static Future saveImageToFirestore(File imageFile, String userId) async {
    try {
    

      // cria um id unico para a foto
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Referência ao local no Firebase Storage onde o arquivo será armazenado
      Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$userId/$fileName');

      // Upload do arquivo
      await storageReference.putFile(imageFile);

      // Obter a URL do arquivo no Firebase Storage
      String downloadURL = await storageReference.getDownloadURL();

      // crio uma instancia no controlador global para salvar o dado da foto de perfil do usuario 
      MeuControllerGlobal meuControllerGlobal;
      meuControllerGlobal = Get.find();
      meuControllerGlobal.salvarImagemPerfil(downloadURL);

      // insire os dados no firesrtore
      await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userId)
      .update({'ImagemPerfil': downloadURL});
    } catch (e) {
      print('Erro ao salvar a imagem no Firestore: $e');
    }
  }



  //retorna as informações de um usuario que forneceu um email
  static Future<QuerySnapshot> getUsuarioPorEmail(String email)async{
    return await FirebaseFirestore.instance.collection('users').where('E-mail', isEqualTo: email).get();
  }

  static Future<QuerySnapshot> getUsuarioPorId(String id)async{
    return await FirebaseFirestore.instance.collection('users').where('Id', isEqualTo: id).get();
  }


  // retorna uma lista com todos os usuarios que comecam uma letra especifica.
  
  static Future<QuerySnapshot>pesquisa(String nome) async {
    return await FirebaseFirestore.instance.collection('users').where('Pesquisa', isEqualTo: nome[0]).get();
  }

  static criaChatRoom(String chatRoomId,Map<String,dynamic> chatRoomInfoMap) async{
    // cria uma chat novo se nao existe.

    print('----------------------------------');
    print('chatRoomId: $chatRoomId\nchatRoomInfoMap: $chatRoomInfoMap');
    final snapshot = await FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId).get();
    print(snapshot.data());
    if(snapshot.exists){
      print('Chat ja existe');
      return true;
    }else{
      print('nao existe');
      return FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId).set(chatRoomInfoMap);
    }
  }

  static Future addMensagem(String chatRoomId,String idMensagem,Map<String,dynamic> infoMensagemMap) async{ 
    return FirebaseFirestore.instance
    .collection('chatrooms')
    .doc(chatRoomId)
    .collection('chats')
    .doc(idMensagem)
    .set(infoMensagemMap);
  }

  static atualizaUltimaMensagem(String chatRoomId,Map<String,dynamic> ultimaMensagemEnviadaMap) async {
    return await FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId).update(ultimaMensagemEnviadaMap);
  }

  static Future<Stream<QuerySnapshot>> getChatRooms(String id) async {
  return FirebaseFirestore
      .instance
      .collection('chatrooms')
      .orderBy('time',descending: true)
      .where('users', arrayContains: id)
      .snapshots();
}

  static Future<Stream<QuerySnapshot>> getMensagens(String chatRoomId) async {
    return FirebaseFirestore
    .instance
    .collection('chatrooms')
    .doc(chatRoomId)
    .collection('chats')
    .orderBy('time',descending: false)
    .snapshots();
  }

    
}

