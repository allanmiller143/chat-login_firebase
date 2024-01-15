
// ignore_for_file: use_key_in_widget_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_chat_ong_user/cadastro/esqueci_senha.dart';
import 'package:meu_chat_ong_user/chat/chat.dart';
import 'package:meu_chat_ong_user/chat/chat_conversa.dart';
import 'package:meu_chat_ong_user/controller/controller.dart';
import 'package:meu_chat_ong_user/firebase_options.dart';
import 'package:meu_chat_ong_user/cadastro/signup.dart';
import 'package:meu_chat_ong_user/cadastro/signin.dart';

//import 'exemplo_botao_desativado.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  Get.put(MeuControllerGlobal());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(name: '/',page: () => SignIpPage()),
        GetPage(name: '/signin',page: () => SignIpPage()),
        GetPage(name: '/signup',page: () => SignUpPage()),
        GetPage(name: '/chat',page: () => ChatPage()),
        GetPage(name: '/chatConversa',page: () => ChatConversaPage()),
        GetPage(name: '/esqueciSenha',page: () => EsqueciSenhaPage()),
      ],
    );
  }
}


