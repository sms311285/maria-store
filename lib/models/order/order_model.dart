import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/account_receive/account_receive_model.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/cart/cart_product.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';
import 'package:maria_store/models/product/product.dart';

// enumerador para definir o status do pedido
enum StatusOrder {
  canceled,
  preparing,
  transporting,
  readyPickup,
  delivered,
  selectAll,
}

class OrderModel {
  // variaveis do pedido
  String? orderId;
  num? priceTotal;
  num? priceDelivery;
  num? priceProducts;
  String? userId;
  Timestamp? date;
  String? accountReceiveId;
  num? installments = 0;

  // lista de produtos
  List<CartProduct>? items;

  // endereço, pegando a instancia do endereço
  Address? address;

  // criando o status do pedido
  StatusOrder? statusOrder;

  // varialvel da seleção entrega / retirada
  bool? isDelivery;

  // ID da loja para retirada
  String? storePickup;

  // id forma de pgto
  String? paymentMethod;

  // instancia firebase
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // pegando a referencia do firebase - referencia do pedido em si
  DocumentReference get firestoreRef => firestore.collection('orders').doc(orderId);

  // metodo para formatar o id, padleft com 6 zeros a esquerda
  String get formattedId => '#${orderId?.padLeft(6, '0')}';

  // get para pegar o status e expor a variavel para o app
  String get statusText => getStatusText(statusOrder!);

  // construtor padrão do pedido
  OrderModel({
    this.orderId,
    this.priceTotal,
    this.priceDelivery,
    this.priceProducts,
    this.userId,
    this.date,
    this.items,
    this.address,
    this.statusOrder,
    this.isDelivery,
    this.storePickup,
    this.paymentMethod,
    this.accountReceiveId,
    this.installments,
  });

  // clonar o pedido para usar no filtro de produto - filtrar apenas o produto correspodente no pedido e quando limpar o filtro voltar o pedido original
  OrderModel clone() {
    return OrderModel(
      orderId: orderId,
      priceTotal: priceTotal,
      priceDelivery: priceDelivery,
      priceProducts: priceProducts,
      userId: userId,
      date: date,
      items: items,
      address: address,
      statusOrder: statusOrder,
      isDelivery: isDelivery,
      storePickup: storePickup,
      paymentMethod: paymentMethod,
      accountReceiveId: accountReceiveId,
      installments: installments,
    );
  }

  // construtor para criar um novo pedido a partir do cartManager
  OrderModel.fromCartManager(CartManager cartManager) {
    // duplicando a lista de items
    items = List.from(cartManager.items);
    priceTotal = cartManager.totalPrice;
    priceDelivery = cartManager.deliveryPrice;
    priceProducts = cartManager.productsPrice;
    userId = cartManager.userApp?.id;
    address = cartManager.address;
    isDelivery = cartManager.selectedOptionShipping == 'Entrega';
    // setando o pedido já em preparação
    statusOrder = StatusOrder.preparing;
    storePickup = cartManager.selectedStore?.id;
    paymentMethod = cartManager.selectedPaymentMethod?.id;
    installments = cartManager.selectedInstallmentOrder;
  }

  // construtor obter o pedido pelo seu documento no firebase, buscar os itens do pedido
  OrderModel.fromDocument(DocumentSnapshot doc) {
    orderId = doc.id;

    // acessando doc items lista de prd, definindo como lista dynamic mapeando cada um dos itens
    items = (doc['items'] as List<dynamic>).map((e) {
      // retorna a lista de cartProduct from map e dar um tolist
      return CartProduct.fromMap(e as Map<String, dynamic>);
    }).toList();

    priceTotal = doc['priceTotal'] as num;
    priceDelivery = doc['priceDelivery'] as num;
    priceProducts = doc['priceProducts'] as num;
    userId = doc['user'] as String;
    // address como é mapa, precisa de um fromMap, acessa como map e coloca dentro do obj endereço
    // verificando se é nulo caso for user novo e selecionar retirada e ainda não tem endereço
    address = doc['address'] != null ? Address.fromMap(doc['address'] as Map<String, dynamic>) : null;
    //address = doc['address'] is Map<String, dynamic> ? Address.fromMap(doc['address'] as Map<String, dynamic>) : null;
    // address = Address.fromMap(doc['address'] as Map<String, dynamic>);
    date = doc['date'] as Timestamp;
    isDelivery = doc['isDelivery'] as bool;

    // pegando todos os status e setando um valor inteiro
    statusOrder = StatusOrder.values[doc['statusOrder'] as int];
    storePickup = doc['storePickup'] as String?;
    paymentMethod = doc['paymentMethod'] as String?;
    accountReceiveId = doc['accountReceiveId'] as String?;
    installments = doc['installments'] as num?;
  }

  // Função para voltar o status do pedido
  Function()? get back {
    return statusOrder == StatusOrder.preparing
        ? null
        : () {
            // Verifica se deve pular o status de transporte (para retirada) ou de pronto para retirar (para entrega)
            if (isDelivery! && statusOrder == StatusOrder.delivered) {
              statusOrder = StatusOrder.transporting;
            } else if (!isDelivery! && statusOrder == StatusOrder.readyPickup) {
              statusOrder = StatusOrder.preparing;
            } else {
              statusOrder = StatusOrder.values[statusOrder!.index - 1];
            }

            // Atualiza o status no Firebase
            firestoreRef.update(
              {'statusOrder': statusOrder!.index},
            );
          };
  }

  // Função para avançar o status do pedido
  Function()? get advance {
    return statusOrder == StatusOrder.delivered
        ? null
        : () {
            // Verifica se deve pular o status de transporte (para retirada) ou de pronto para retirar (para entrega)
            if (isDelivery! && statusOrder == StatusOrder.transporting) {
              statusOrder = StatusOrder.delivered;
            } else if (!isDelivery! && statusOrder == StatusOrder.preparing) {
              statusOrder = StatusOrder.readyPickup;
            } else {
              statusOrder = StatusOrder.values[statusOrder!.index + 1];
            }

            // Atualiza o status no Firebase
            firestoreRef.update(
              {'statusOrder': statusOrder!.index},
            );
          };
  }

  // incrementar estoque ao cancelar ou efetuar uma compra
  Future<void> _incrementStock() {
    return firestore.runTransaction(
      (tx) async {
        final List<Product> productsToUpdate = [];

        // Percorre todos os itens do pedido
        for (final cartProduct in items!) {
          Product product;

          // Verifica se o produto já está na lista de produtos a serem atualizados
          if (productsToUpdate.any((p) => p.id == cartProduct.productId)) {
            product = productsToUpdate.firstWhere((p) => p.id == cartProduct.productId);
          } else {
            final doc = await tx.get(
              firestore.doc('products/${cartProduct.productId}'),
            );
            product = Product.fromDocument(doc);
          }

          cartProduct.product = product;

          final size = product.findSize(cartProduct.size!);

          // Incrementa o estoque
          size!.stock = size.stock! + cartProduct.quantity!;
          productsToUpdate.add(product);
        }

        // Atualiza os estoques no Firebase
        for (final product in productsToUpdate) {
          tx.update(
            firestore.doc('products/${product.id}'),
            {
              'sizes': product.exportSizeList(),
            },
          );
        }
      },
    );
  }

  // cancelar movimentação - realizando o lançamento do cancelamento de forma separada sem recalcular estoque
  Future<void> _cancelStockMovement() async {
    for (var item in items!) {
      // Obter o produto correspondente
      Product product = item.product!;
      // Encontrar o tamanho correspondente
      final size = product.findSize(item.size!);
      // Calcular estoque atual e final
      final finalStock = size!.stock!; // obtendo estoque já atualizado
      final initialStock = finalStock - item.quantity!; // calculando para salvar o estoque inicial

      // Caminho para a subcoleção do tamanho dentro do produto
      final movementRef =
          firestore.collection('products').doc(product.id).collection(item.size!); // Nome do tamanho como subcoleção
      // Adicionando a movimentação na subcoleção
      await movementRef.add({
        'quantity': item.quantity,
        'date': Timestamp.now(),
        'type': 'order',
        'orderId': orderId,
        'initialStock': initialStock,
        'finalStock': finalStock,
        'status': StatusOrder.canceled.index,
      });
    }
  }

  // cancelar movimentação - realizando o lançamento do cancelamento de forma separada sem recalcular financeiro
  Future<void> _cancelFinancialMovement() async {
    final FinancialManager financialManager = FinancialManager();
    // obtendo a lista atualizada da movimentação financeira
    await financialManager.fetchMovementsFinancial();
    // Buscar função da última movimentação financeira
    final lastMovement = await financialManager.getLastMovement();
    // Usar o saldo final da última movimentação como saldo inicial
    var initialBalance = lastMovement?.finalBalance ?? 0;

    final finalBalance = initialBalance - priceProducts!;

    // Salvando a movimentação financeira diretamente
    await firestore.collection('movementsFinancial').add({
      'accountReceiveId': accountReceiveId,
      'priceTotal': priceProducts,
      'date': Timestamp.now(),
      'status': StatusAccountReceive.canceled.index,
      'type': 'accountReceive',
      'initialBalance': initialBalance,
      'finalBalance': finalBalance,
    });
  }

  // função para alterar o status para cancelado
  void cancel(BuildContext context) async {
    // Incrementa o estoque
    await _incrementStock().then((_) async {
      // Seta o status de cancelado
      statusOrder = StatusOrder.canceled;
      // Atualiza no Firebase
      await firestoreRef.update(
        {'statusOrder': statusOrder!.index},
      );
      // cancelar a duplicata a receber
      if (accountReceiveId != null) {
        await firestore.collection('accountreceive').doc(accountReceiveId).update(
          {
            'statusAccountReceive': StatusAccountReceive.canceled.index,
            'dateReceive': null,
          },
        );
      }
      await _cancelFinancialMovement();
      await _cancelStockMovement();
    }).catchError((e) {
      // Lida com o erro, se houver
      debugPrint('Erro ao incrementar o estoque: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar compra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  // metodo para salvar o pedido
  Future<void> save() async {
    // acessando a coleção de pedidos e transformando em um map
    firestore.collection('orders').doc(orderId).set(
      {
        // transformando a lista de itens em uma lista de map toOrderItemMap criado cartProduct
        'items': items!.map((e) => e.toOrderItemMap()).toList(),
        'priceTotal': priceTotal,
        'priceDelivery': priceDelivery,
        'priceProducts': priceProducts,
        'user': userId,
        // pegando o mapa de endereço
        'address': address?.toMap(),
        // pegando o index do status
        'statusOrder': statusOrder?.index,
        // setando a data atual do pedido
        'date': Timestamp.now(),
        'isDelivery': isDelivery,
        'storePickup': storePickup,
        'paymentMethod': paymentMethod,
        'accountReceiveId': accountReceiveId,
        'installments': installments,
      },
    );

    // Criando uma conta a receber associada à compra
    final DateTime now = DateTime.now(); // obtendo a data atual

    // SALVANDO A CONTA
    final accountReceive = AccountReceiveModel(
      paymentMethod: paymentMethod,
      orderId: orderId,
      user: userId,
      priceTotal: priceProducts,
      installments: installments,
      date: Timestamp.now(),
      dueDate: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59)),
      statusAccountReceive: StatusAccountReceive.pending,
    );

    // Salvando a conta a receber na coleção 'accountreceive'
    await accountReceive.save();

    // Salvando a movimentação de estoque na coleção 'movements'
    for (var item in items!) {
      // Obter o produto correspondente como já tenho o prd obtenho a instancia e passo o item
      Product product = item.product!;
      // Encontrar o tamanho correspondente
      final size = product.findSize(item.size!);
      // Calcular estoque atual e final
      final finalStock = size!.stock!; // obtendo estoque já atualizado
      final initialStock = finalStock + item.quantity!; // calculando para salvar o estoque inicial

      // Caminho para a subcoleção do tamanho dentro do produto
      final movementRef =
          firestore.collection('products').doc(product.id).collection(item.size!); // Nome do tamanho como subcoleção

      // Adicionando a movimentação na subcoleção
      await movementRef.add({
        'quantity': item.quantity,
        'date': Timestamp.now(),
        'type': 'order',
        'orderId': orderId,
        'initialStock': initialStock,
        'finalStock': finalStock,
        'status': statusOrder?.index,
      });
    }
  }

  // função para atualizar as modificações no pedido do orderManager para quando avançar ou voltar o status
  void updateFromDocument(DocumentSnapshot doc) {
    // passando apenas o status pois somente o status q vamos alterar
    statusOrder = StatusOrder.values[doc['statusOrder'] as int];
    // atualizando o accountReceiveId na conta
    accountReceiveId = doc['accountReceiveId'] as String;
  }

  // função que retorna string para converter os status que são int em string, static para acessar de outro local do app sem ter a instancia do pedido
  static String getStatusText(StatusOrder statusOrder) {
    // pega todos os status
    switch (statusOrder) {
      case StatusOrder.canceled:
        return 'Cancelado';
      case StatusOrder.preparing:
        return 'Em preparação';
      case StatusOrder.transporting:
        return 'Em transporte';
      case StatusOrder.readyPickup:
        return 'Pronto p/ Retirar';
      case StatusOrder.delivered:
        return 'Entregue';
      case StatusOrder.selectAll:
        return 'Selecionar Todos';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'OrderModel{orderId: $orderId, price: $priceTotal, userId: $userId, date: $date, items: $items, address: ${address?.toString() ?? 'N/A'}, priceDelivery: $priceDelivery, priceProducts: $priceProducts}';
  }
}
