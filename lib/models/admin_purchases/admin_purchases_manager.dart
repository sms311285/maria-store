import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/purchase/purchase_model.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';

class AdminPurchasesManager extends ChangeNotifier {
  final List<PurchaseModel> _purchases = [];

  // declarando uma lista de filtro dos pedido para a tela de seleção de pedido
  List<PurchaseModel> filterPurchases = [];

  // declarando data de inicio e fim filtros
  DateTime? startDate;
  DateTime? endDate;

  // declarando o userfilter do tipo usuario para filtro de user
  SupplierApp? supplierFilter;

  // DECLARANDO PARA FILTRO NUMERO DO PEDIDO
  String? purchaseIdFilter;

  // declarando para filtro produto
  String? productFilter;

  // filtro tamanho
  String? sizeFilter;

  // forma de pagamento
  PaymentMethodModel? paymentMethodFilter;

  // filtro do status lista que vai conter todos os status deixando o em pending como defalut
  List<StatusPurchase> statusFilter = [StatusPurchase.pending];

  // intancia firebasae
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // stream subscription para notificar quando houver mudanças, e cancelar o snapshot
  StreamSubscription? _subscription;

  // atualizar usuário - função que é chamada no main habilitando ou não o admin, parametro nomeado para explicitar que o admin está habilitado no main
  void updateAdmin({required bool adminEnabled}) {
    // limpando as purchases
    _purchases.clear();
    // cancelando o snapshot, toda vez que o user for alterado, o snapshot deve ser cancelado e recriado
    _subscription?.cancel();
    // limpando a lista de filtro
    filterPurchases.clear();

    // verificando se o user é != null e criando uma nova lista, sempre cancela com subscription e cria uma nova
    if (adminEnabled) {
      // função lista order
      _listenToPurchases();
    }
  }

  // lista de pedidos
  void _listenToPurchases() {
    // subscription para notificar quando houver mudanças e cancelar o snapshot qdo houver uma mudança no estado do pedido a tela será atualizada
    // query para acessar a coleção de pedidos e procurar os pedidos todos os pedidos (com snapshot deve ser recriado toda vez que o user for alterado)
    _subscription = firestore.collection('purchases').snapshots().listen(
      (event) {
        // event.docChanges - lista de todas as mudanças dos documentos do pedido no caso qdo avançar ou voltar o status
        for (final change in event.docChanges) {
          // change.type - tipo de mudança ele fala as mudanças no doc
          switch (change.type) {
            // add o doc
            case DocumentChangeType.added:
              _purchases.add(
                // indicando a mudança e passando o change.doc
                PurchaseModel.fromDocument(change.doc),
              );
              break;
            case DocumentChangeType.modified:
              // detectar o pedido que sofreu alteração, procurar onde o primeiro elemento e igual a change
              final modPurchase = _purchases.firstWhere((p) => p.purchaseId == change.doc.id);
              // atualizar o pedido com base no change.doc chamando a função em orderModel
              modPurchase.updateFromDocument(change.doc);
              break;
            case DocumentChangeType.removed:
              debugPrint('Deu problema sério!!!');
              break;
          }
        }
        // atualizando a lista de pedidos para tela de seleção de pedidos
        filterPurchases = List.from(_purchases);
        notifyListeners();
      },
    );
  }

  List<PurchaseModel> get filteredPurchases {
    // declarando uma lista de order output que é o que vai sair da lista filtrada reversa
    List<PurchaseModel> output = _purchases.reversed.toList();

    // verificando se o userFilter e != null e adicionando na lista de order
    if (supplierFilter != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito por um userid seja igual ao userid passado no filtro
      output = output.where((p) => p.supplierId == supplierFilter!.id).toList();
    }

    // FILTRO DATA
    if (startDate != null && endDate != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito antes ou depois das datas passado no filtro
      output = output.where((p) {
        DateTime purchaseDateTime = p.date!.toDate();
        return purchaseDateTime.isAfter(startDate!) && purchaseDateTime.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // FILTRO NUMERO DA COMPRA
    if (purchaseIdFilter != null && purchaseIdFilter!.isNotEmpty) {
      output = output.where((p) => p.purchaseId!.contains(purchaseIdFilter!)).toList();
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

    // filtro forma de pagamento
    if (paymentMethodFilter != null) {
      output = output.where((o) => o.paymentMethod == paymentMethodFilter!.id).toList();
    }

    //filtra o status, passando por eles e cada pedido se contem o status filtrando retornando diretamente o filtro output com status filtrado apagando o return output apenas
    return output = output.where((o) => statusFilter.contains(o.statusPurchase)).toList();
  }

  // criando a função para setar o user filtrado filtrando os pedidos de user
  void setSupplierFilter(SupplierApp? supplier) {
    supplierFilter = supplier;
    notifyListeners();
  }

  // criando a função para setar o status filtrando os pedidos de user
  void setStatusFilter({StatusPurchase? status, bool? enablad}) {
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
  void setPurchaseIdFilter(String? purchaseId) {
    purchaseIdFilter = purchaseId;
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

  // forma de pagamento
  void setPaymentMethodFilter(PaymentMethodModel? paymentMethod) {
    paymentMethodFilter = paymentMethod;
    notifyListeners();
  }

  //TOTAL PEDIDO
  double calculateTotalPurchase(List<PurchaseModel> purchases) {
    return purchases.fold(0, (total, purchases) => total + purchases.priceTotal!);
  }

  //TOTAL PRODUTOS FILTRADOS
  double calculateTotalProducts(List<PurchaseModel> purchases) {
    double total = 0;
    for (final purchase in purchases) {
      total += purchase.items!.fold(0, (subtotal, item) => subtotal + (item.fixedPrice! * item.quantity!));
    }
    return total;
  }

  //TOTAL PRODUTOS
  int calculateQuantityProducts(List<PurchaseModel> purchases) {
    return purchases.fold(0, (total, purchase) => total + purchase.items!.length);
  }

  // TOTAL ITENS
  int calculateQuantityItems(List<PurchaseModel> purchases) {
    return purchases.fold(
      0,
      (total, purchase) => total + purchase.items!.fold(0, (subtotal, item) => subtotal + item.quantity!),
    );
  }

  // TOTAL QTDE DE PEDIDOS
  int calculateQuantityPurchases(List<PurchaseModel> purchases) {
    return purchases.length;
  }

  // Método de filtragem para pesquisa de user para a tela de seleção de pedido
  void filterPurchase(String query) {
    if (query.isEmpty) {
      filterPurchases = List.from(_purchases);
    } else {
      filterPurchases = _purchases.where((o) => o.purchaseId!.contains(query)).toList();
    }
    notifyListeners();
  }

  // Função para selecioanr e desselecionar todos os status
  // Este método é chamado quando o checkbox "Selecionar Todos" é marcado ou desmarcado.
  void setAllStatusFilters(bool value) {
    // Se checkbox "Selecionar Todos" foi marcado
    if (value) {
      // Ele define a lista statusFilter com todos os status disponíveis, exceto selectAll. O método where filtra a lista para excluir selectAll.
      statusFilter = StatusPurchase.values.where((s) => s != StatusPurchase.selectAll).toList();
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
