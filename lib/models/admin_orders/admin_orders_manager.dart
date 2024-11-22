import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/user/user_app.dart';

class AdminOrdersManager extends ChangeNotifier {
  //============================== VARIÁVEIS ==============================
  // declarando uma lista vazia de orders, local para não acessar de nenhum lugar isso fez por conta dos filtros, abaixo expõe a varialvel de filtro
  final List<OrderModel> _orders = [];

  // declarando uma lista de filtro dos pedido para a tela de seleção de pedido
  List<OrderModel> filterOrders = [];

  // declarando data de inicio e fim filtros
  DateTime? startDate;
  DateTime? endDate;

  // declarando o userfilter do tipo usuario para filtro de user
  UserApp? userFilter;

  // DECLARANDO PARA FILTRO NUMERO DO PEDIDO
  String? orderIdFilter;

  // declarando para filtro produto
  String? productFilter;

  // filtro tamanho
  String? sizeFilter;

  // forma de envio
  bool? isDeliveryFilter;

  // forma de pagamento - obter o objeto pois salvo no pedido o id então pego o obj e dele obtenho o nome da forma de pgto isso serve para o user
  PaymentMethodModel? paymentMethodFilter;

  // filtro do status lista que vai conter todos os status deixando o em preparação como defalut
  List<StatusOrder> statusFilter = [StatusOrder.preparing];

  // intancia firebasae
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // stream subscription para notificar quando houver mudanças, e cancelar o snapshot
  StreamSubscription? _subscription;

  // atualizar usuário - função que é chamada no main habilitando ou não o admin, parametro nomeado para explicitar que o admin está habilitado no main
  void updateAdmin({required bool adminEnabled}) {
    // limpando as orders
    _orders.clear();
    // cancelando o snapshot, toda vez que o user for alterado, o snapshot deve ser cancelado e recriado
    _subscription?.cancel();
    // limpando a lista de filtro
    filterOrders.clear();

    // verificando se o user é != null e criando uma nova lista, sempre cancela com subscription e cria uma nova
    if (adminEnabled) {
      // função lista order
      _listenToOrders();
    }
  }

  // lista de pedidos
  void _listenToOrders() {
    // subscription para notificar quando houver mudanças e cancelar o snapshot qdo houver uma mudança no estado do pedido a tela será atualizada
    // query para acessar a coleção de pedidos e procurar os pedidos todos os pedidos (com snapshot deve ser recriado toda vez que o user for alterado)
    _subscription = firestore.collection('orders').snapshots().listen(
      (event) {
        // event.docChanges - lista de todas as mudanças dos documentos do pedido no caso qdo avançar ou voltar o status
        for (final change in event.docChanges) {
          // change.type - tipo de mudança ele fala as mudanças no doc
          switch (change.type) {
            // add o doc
            case DocumentChangeType.added:
              _orders.add(
                // indicando a mudança e passando o change.doc
                OrderModel.fromDocument(change.doc),
              );
              break;
            case DocumentChangeType.modified:
              // detectar o pedido que sofreu alteração, procurar onde o primeiro elemento e igual a change
              final modOrder = _orders.firstWhere((o) => o.orderId == change.doc.id);
              // atualizar o pedido com base no change.doc chamando a função em orderModel
              modOrder.updateFromDocument(change.doc);
              break;
            case DocumentChangeType.removed:
              debugPrint('Deu problema sério!!!');
              break;
          }
        }
        // atualizando a lista de pedidos para tela de seleção de pedidos
        filterOrders = List.from(_orders);
        notifyListeners();
      },
    );
  }

  //============================== FUNÇÕES DE FILTRO ==============================

  // criando a lista de pedidos filtrados
  List<OrderModel> get filteredOrders {
    // declarando uma lista de order output que é o que vai sair da lista filtrada reversa
    List<OrderModel> output = _orders.reversed.toList();
    // FILTROS

    // verificando se o userFilter e != null e adicionando na lista de order
    if (userFilter != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito por um userid seja igual ao userid passado no filtro
      output = output.where((o) => o.userId == userFilter!.id).toList();
    }

    // FILTRO POR FORMA DE ENVIO (Entrega ou Retirada)
    if (isDeliveryFilter != null) {
      output = output.where((o) => o.isDelivery == isDeliveryFilter).toList();
    }

    // filtro forma de pagamento
    if (paymentMethodFilter != null) {
      output = output.where((o) => o.paymentMethod == paymentMethodFilter!.id).toList();
    }

    // FILTRO NUMERO DA PEDIDO
    if (orderIdFilter != null && orderIdFilter!.isNotEmpty) {
      output = output.where((p) => p.orderId!.contains(orderIdFilter!)).toList();
    }

    // FILTRO DATA
    if (startDate != null && endDate != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito antes ou depois das datas passado no filtro
      output = output.where((o) {
        DateTime orderDateTime = o.date!.toDate();
        return orderDateTime.isAfter(startDate!) && orderDateTime.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // FILTRO POR PRODUTO
    if (productFilter != null) {
      output = output
          // Verifica se algum item do pedido corresponde ao filtro por id
          .where((o) => o.items!.any((item) => item.product!.name!.contains(productFilter!)))
          // mapeando os pedidos com todos os itens filtrados
          .map((order) {
        // Clona o pedido e filtra os itens correspondentes
        return order.clone()
          ..items = order.items!.where((item) => item.product!.name!.contains(productFilter!)).toList();
      }).toList();
    }

    // FILTRO POR TAMANHO
    if (sizeFilter != null) {
      // Filtrando os pedidos que possuem algum item com o tamanho especificado
      output = output
          // Verifica se algum item do pedido corresponde ao filtro por id
          .where((o) => o.items!.any((item) => item.size!.contains(sizeFilter!)))
          // mapeando os pedidos com todos os itens filtrados
          .map((order) {
        // Clona o pedido e filtra os itens correspondentes
        return order.clone()..items = order.items!.where((item) => item.size!.contains(sizeFilter!)).toList();
      }).toList();
    }

    //filtra o status, passando por eles e cada pedido se contem o status filtrando retornando diretamente o filtro output com status filtrado apagando o return output apenas
    return output = output.where((o) => statusFilter.contains(o.statusOrder)).toList();
  }

  //============================== FUNÇÕES PARA SETAR OS FILTROS ==============================

  // criando a função para setar o user filtrado filtrando os pedidos de user
  void setUserFilter(UserApp? user) {
    userFilter = user;
    notifyListeners();
  }

  // criando a função para setar o status filtrando os pedidos de user
  void setStatusFilter({StatusOrder? status, bool? enablad}) {
    // se o status está habilitado
    if (enablad!) {
      // acessa o status filter e add o status que habilitou
      statusFilter.add(status!);
    } else {
      // se está desabilitado, remove o statusFilter
      statusFilter.remove(status);
    }
    notifyListeners();
  }

  // criando a função para setar o status filtrando os pedidos de user por data
  void setStartDate(DateTime? start) {
    startDate = start;
    notifyListeners();
  }

  // FILTRO DATA FINAL
  void setEndDate(DateTime? end) {
    endDate = end;
    notifyListeners();
  }

  // setar o filtro pelo numero do pedido
  void setOrderIdFilter(String? orderId) {
    orderIdFilter = orderId;
    notifyListeners();
  }

  // setar filtro produto
  void setProductFilter(String? productName) {
    productFilter = productName;
    notifyListeners();
  }

  // setar filtro de tamanho
  void setSizeFilter(String? size) {
    sizeFilter = size;
    notifyListeners();
  }

  // Setar o filtro para forma de envio
  void setIsDeliveryFilter(bool? isDelivery) {
    isDeliveryFilter = isDelivery;
    notifyListeners();
  }

  // forma de pagamento
  void setPaymentMethodFilter(PaymentMethodModel? paymentMethod) {
    paymentMethodFilter = paymentMethod;
    notifyListeners();
  }

  //============================== FUNÇÕES SUMMARY ==============================
  //TOTAL PEDIDO
  double calculateTotalOrder(List<OrderModel> orders) {
    return orders.fold(0, (total, order) => total + order.priceTotal!);
  }

  //TOTAL FRETES
  double calculateTotalDelivery(List<OrderModel> orders) {
    return orders.fold(0, (total, order) => total + order.priceDelivery!);
  }

  //TOTAL PRODUTOS FILTRADOS
  double calculateTotalProducts(List<OrderModel> orders) {
    double total = 0;
    for (final order in orders) {
      total += order.items!.fold(0, (subtotal, item) => subtotal + (item.fixedPrice! * item.quantity!));
    }
    return total;
  }

  //TOTAL PRODUTOS
  int calculateQuantityProducts(List<OrderModel> orders) {
    return orders.fold(0, (total, order) => total + order.items!.length);
  }

  // TOTAL ITENS
  int calculateQuantityItems(List<OrderModel> orders) {
    return orders.fold(
      0,
      (total, order) => total + order.items!.fold(0, (subtotal, item) => subtotal + item.quantity!),
    );
  }

  // TOTAL QTDE DE PEDIDOS
  int calculateQuantityOrders(List<OrderModel> orders) {
    return orders.length;
  }

  // Método de filtragem para pesquisa de user para a tela de seleção de pedido
  void filterOrder(String query) {
    if (query.isEmpty) {
      filterOrders = List.from(_orders);
    } else {
      //filterOrders = _orders.where((order) => order.orderId!.contains(query)).toList();
      filterOrders = _orders.where((o) => o.orderId!.contains(query)).toList();
    }
    notifyListeners();
  }

  // Função para selecioanr e desselecionar todos os status
  // Este método é chamado quando o checkbox "Selecionar Todos" é marcado ou desmarcado.
  void setAllStatusFiltersOrders(bool value) {
    // Se checkbox "Selecionar Todos" foi marcado
    if (value) {
      // Ele define a lista statusFilter com todos os status disponíveis, exceto selectAll. O método where filtra a lista para excluir selectAll.
      statusFilter = StatusOrder.values.where((s) => s != StatusOrder.selectAll).toList();
    } else {
      // removendo todos os status
      statusFilter.clear();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // cancelando a subscription
    _subscription?.cancel();
    super.dispose();
  }
}
