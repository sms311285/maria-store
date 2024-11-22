import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';

class AdminsManager extends ChangeNotifier {
  // Lista de user que recebe os users
  List<AdminsManager> adminsUsers = [];

  // Lista de todos os usuários disponíveis
  List<UserApp> userList = [];

  StreamSubscription? _subscription;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? id;
  String? name;
  String? user;

  AdminsManager({
    this.id,
    this.name,
    this.user,
  });

  AdminsManager.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    name = doc['name'] as String;
    user = doc['user'] as String;
  }

  // Verificar se o user é admin e se está habilitado
  void updateUser(UserManager userManager) {
    // cancelando a obsrvação das mudanças, serve para custo do firebase
    _subscription?.cancel();
    if (userManager.adminEnabled) {
      // Listar usuarios
      _listenToAdmins();
      _listenToUsers();
    } else {
      // se não tiver habilitado, limpar a lista de users e não ficar obtendo a lista
      adminsUsers.clear();
      userList.clear();
      notifyListeners();
    }
  }

  // Metodo para listar os usuarios
  void _listenToAdmins() {
    // Buscar docs da coleção users, usar snapshots (fica observando mudanças) para atualizar qdo houver mudanças/atualizações nos usuários
    _subscription = firestore.collection('admins').snapshots().listen(
      (snapshot) {
        // Os users vão para snapshots.docs, pegar cada doc (e) e gerar um user com o fromDocument e transformar list
        adminsUsers = snapshot.docs.map((e) => AdminsManager.fromDocument(e)).toList();
        // Oredenando a lista por ordem alfabética
        adminsUsers.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
        // Inicialmente, todos os usuários estão na lista filtrada de seleção de user nos filtros na tela de seleção de user

        notifyListeners();
      },
    );
  }

  // Metodo para listar os usuarios
  void _listenToUsers() {
    // Buscar docs da coleção users, usar snapshots (fica observando mudanças) para atualizar qdo houver mudanças/atualizações nos usuários e verificando se não está deletado
    _subscription = firestore.collection('users').where('deleted', isEqualTo: false).snapshots().listen(
      (snapshot) {
        // Os users vão para snapshots.docs, pegar cada doc (e) e gerar um user com o fromDocument e transformar list
        userList = snapshot.docs.map((e) => UserApp.fromDocument(e)).toList();
        // Oredenando a lista por ordem alfabética
        userList.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));

        notifyListeners();
      },
    );
  }

  // Pegando os users e adicionando a lista
  List<String> get names => adminsUsers.map((e) => e.name!).toList();

  // Função para salvar ou remover user como admin
  Future<void> saveAdmin(String id, String name) async {
    try {
      // Se o switch for ativado, salva o usuário na coleção "admins"
      await firestore.collection('admins').doc(id).set({
        'user': id,
        'name': name,
      });
    } catch (e) {
      debugPrint("Error updating admin status: $e");
    }
  }

  // remover admin
  Future<void> removeAdmin(AdminsManager admin) async {
    try {
      await FirebaseFirestore.instance.collection('admins').doc(admin.id).delete();
    } catch (e) {
      debugPrint("Error updating admin status: $e");
    }
  }

  // Dispose faz parte do changenotifier, cancela o _subscription e para de ficar obs as mudanças/atualizações
  @override
  dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
