import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/models/user/user_app.dart';

class OrdersManager extends ChangeNotifier {
  // instancia userapp para obter os dados do user logado
  UserApp? userApp;

  // declarando uma lista vazia de orders
  List<OrderModel> orders = [];

  // intancia firebasae
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // stream subscription para notificar quando houver mudanças, e cancelar o snapshot
  StreamSubscription? _subscription;

  // atualizar usuário - função que é chamada no main
  void updateUser(UserApp? userApp) {
    // salvar user no obj user local
    this.userApp = userApp;
    // limpando as orders
    orders.clear();
    // cancelando o snapshot, toda vez que o user for alterado, o snapshot deve ser cancelado e recriado
    _subscription?.cancel();

    // verificando se o user é != null e criando uma nova lista, sempre cancela com subscription e cria uma nova
    if (userApp != null) {
      // função lista order
      _listenToOrders();
    }
  }

  // lista de pedidos
  void _listenToOrders() {
    // subscription para notificar quando houver mudanças e cancelar o snapshot qdo houver uma mudança no estado do pedido a tela será atualizada
    // query para acessar a coleção de pedidos e procurar os pedidos do user logado (com snapshot deve ser recriado toda vez que o user for alterado)
    _subscription = firestore.collection('orders').where('user', isEqualTo: userApp?.id).snapshots().listen(
      (event) {
        // limpando a lista
        orders.clear();
        // percorrendo os docs e adicionando na lista
        for (final doc in event.docs) {
          // obtendo a lista de pedidos, tranformando em obj order
          orders.add(OrderModel.fromDocument(doc));
        }
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    // cancelando a subscription
    _subscription?.cancel();
    super.dispose();
  }
}
