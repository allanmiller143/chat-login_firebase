import 'package:get/get.dart';

class MeuControllerGlobal extends GetxController {
  final nome = ''.obs;
  final email = ''.obs; 
  final id = ''.obs; 
  final pesquisa = ''.obs;
  final imagemPerfil = ''.obs;
  double tamanhoTela = 0;

  void salvarNome(String dado) {
    nome.value = dado;
  }
  void salvarEmail(String dado) {
    email.value = dado;
  }
  void salvarId(String dado) {
    id.value = dado;
  }
  void salvarPesquisa(String dado) {
    pesquisa.value = dado;
  }
  void salvarImagemPerfil(String dado) {
    imagemPerfil.value = dado;
  }

  String obterNome() {
    return nome.value;
  }
  String obterEmail() {
    return email.value;
  }
  String obterId() {
    return id.value;
  }
  String obterPesquisa() {
    return pesquisa.value;
  }
  String obterimagemPerfil() {
    return imagemPerfil.value;
  }

}