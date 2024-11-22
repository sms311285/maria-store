import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';

// Extendendo o changeNotifier para notificar as mudanças se user é admin ou não]
class AdminUsersManager extends ChangeNotifier {
  // Lista de user que recebe os users
  List<UserApp> users = [];

  // controlador do texto do filtro
  final TextEditingController searchController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Criando _subscription para matar quando a tela for fechada e parar de ficar observando as mudanças como o snapshot faz
  StreamSubscription? _subscription;

  // Verificar se o user é admin e se está habilitado
  void updateUser(UserManager userManager) {
    // cancelando a obsrvação das mudanças, serve para custo do firebase
    _subscription?.cancel();
    if (userManager.adminEnabled) {
      // Listar usuarios
      _listenToUsers();
    } else {
      // se não tiver habilitado, limpar a lista de users e não ficar obtendo a lista
      users.clear();
      // limpar a lista filtrada
      notifyListeners();
    }
  }

  // Metodo para listar os usuarios
  void _listenToUsers() {
    // Buscar docs da coleção users, usar snapshots (fica observando mudanças) para atualizar qdo houver mudanças/atualizações nos usuários e verificando se não está deletado
    _subscription = firestore.collection('users').where('deleted', isEqualTo: false).snapshots().listen(
      (snapshot) {
        // Os users vão para snapshots.docs, pegar cada doc (e) e gerar um user com o fromDocument e transformar list
        users = snapshot.docs.map((e) => UserApp.fromDocument(e)).toList();
        // Oredenando a lista por ordem alfabética
        users.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));

        notifyListeners();
      },
    );
  }

  // Pegando os users e adicionando a lista
  List<String> get names => users.map((e) => e.name!).toList();

  // deletar USER, recebendo o USER que vai ser deletado, PEGANDO METODO DELETE LÁ DO USERAPP
  void delete(UserApp userApp) {
    // pedindo para prd se deletar a si mesmo
    userApp.delete();
    // procurando o prd a ser deletado
    users.removeWhere((u) => u.id == userApp.id);
    notifyListeners();
  }

  // Função para buscar os usuários pelo ID e obter todos os seus dados caso necessário
  UserApp? findUserById(String id) {
    // Tratando exceção caso não encontre o prd
    try {
      // Pesquisar e Retornar o primeiro item que for igual ao ID
      return users.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Dispose faz parte do changenotifier, cancela o _subscription e para de ficar obs as mudanças/atualizações
  @override
  dispose() {
    _subscription?.cancel();
    // Dispose do controller quando não for mais necessário
    searchController.dispose();
    super.dispose();
  }
}
