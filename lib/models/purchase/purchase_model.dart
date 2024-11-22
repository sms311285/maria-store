import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/bag/bag_product.dart';
import 'package:maria_store/models/account_pay/account_pay_model.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';
import 'package:maria_store/models/product/product.dart';

enum StatusPurchase {
  canceled,
  confirmed,
  pending,
  selectAll,
}

class PurchaseModel {
  String? purchaseId;
  num? priceTotal;
  //num? priceProducts;
  String? userId;
  Timestamp? date;
  List<BagProduct>? items;
  StatusPurchase? statusPurchase;
  String? paymentMethod;
  String? supplierId;
  String? accountPayId;
  num? installments = 0;

  int? daysBetweenInstallments;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // pegando a referencia do firebase - referencia do pedido em si
  DocumentReference get firestoreRef => firestore.collection('purchases').doc(purchaseId);

  String get formattedId => '#${purchaseId?.padLeft(6, '0')}';

  // get para pegar o status e expor a variavel para o app
  String get statusText => getStatusText(statusPurchase!);

  // construtor padrão da compra
  PurchaseModel({
    this.purchaseId,
    this.priceTotal,
    //this.priceProducts,
    this.userId,
    this.date,
    this.items,
    this.statusPurchase,
    this.paymentMethod,
    this.supplierId,
    this.accountPayId,
    this.installments,
  });

  // clonar compra
  PurchaseModel clone() {
    return PurchaseModel(
      purchaseId: purchaseId,
      priceTotal: priceTotal,
      //priceProducts: priceProducts,
      userId: userId,
      date: date,
      items: items,
      statusPurchase: statusPurchase,
      paymentMethod: paymentMethod,
      supplierId: supplierId,
      accountPayId: accountPayId,
      installments: installments,
    );
  }

  // construtor para criar um novo pedido a partir do cartManager
  PurchaseModel.fromBagManager(BagManager bagManager) {
    // duplicando a lista de items
    items = List.from(bagManager.items);
    priceTotal = bagManager.totalPrice;
    //priceProducts = bagManager.productsPrice;
    supplierId = bagManager.selectedSupplier?.id;
    userId = bagManager.userApp?.id;
    // setando o pedido já em preparação
    statusPurchase = StatusPurchase.pending;
    paymentMethod = bagManager.selectedPaymentMethod?.id;
    installments = bagManager.selectedInstallmentPurchase;
    // Incluindo o número de dias entre parcelas
    daysBetweenInstallments = bagManager.selectedDays;
  }

  // construtor obter o pedido pelo seu documento no firebase, buscar os itens do pedido
  PurchaseModel.fromDocument(DocumentSnapshot doc) {
    purchaseId = doc.id;
    // acessando doc items lista de prd, definindo como lista dynamic mapeando cada um dos itens
    items = (doc['items'] as List<dynamic>).map((e) {
      // retorna a lista de cartProduct from map e dar um tolist
      return BagProduct.fromMap(e as Map<String, dynamic>);
    }).toList();

    priceTotal = doc['priceTotal'] as num;
    //priceProducts = doc['priceProducts'] as num;
    supplierId = doc['supplier'] as String;
    userId = doc['user'] as String;
    statusPurchase = StatusPurchase.values[doc['statusPurchase'] as int];
    date = doc['date'] as Timestamp;
    paymentMethod = doc['paymentMethod'] as String;
    accountPayId = doc['accountPayId'] as String?;
    installments = doc['installments'] as num?;
  }

  // função que decrementa o estoque após uma venda
  Future<void> _decrementStock() {
    // chamando a função de transação
    return firestore.runTransaction(
      (tx) async {
        // criar lista dos prd para poder decrementar localmente prds atualizados
        final List<Product> productsToUpdate = [];

        // lista de produtos que não possuem estoque
        final List<Product> productsWithoutStock = [];

        // 1. Ler todos os estoques
        // passar por cada item do carrinho, pegando os itens do carrinho e passando por todos eles
        for (final bagProduct in items!) {
          // passando obj product para ter acesso aos prds
          Product product;

          // verificar se o prd já está na lista de produtsToUpdate, any = contem algum elemento/prd cujo id é exatamente o mesmo id do bagProduct.productId
          if (productsToUpdate.any((p) => p.id == bagProduct.productId)) {
            // se sim, pegar o prd da lista e colocar no product
            product = productsToUpdate.firstWhere((p) => p.id == bagProduct.productId);
          } else {
            // acessando o documento referente ao bagProduct via transação.
            final doc = await tx.get(
              // obtendo o prd/estoque mais atualizado, acessando a ref do produto e colocando no doc
              firestore.doc('products/${bagProduct.productId}'),
            );
            // transformando em um obj produto, assim acessando todo o prd, lendo os prd mais atualizados colocando no doc
            product = Product.fromDocument(doc);
          }

          // adicionar o prd atualizado na lista de prds para serem atualizados e mostrar a lista de prds que não possuem estoque
          bagProduct.product = product;

          // obter o obj tamanho correspondente ao tamanho q selecionamos
          final size = product.findSize(bagProduct.size!);

          // 2. Decremento localmente os estoques 2xM
          // verificar se a qtde de itens que estamos solicitando possui estoque, verificar se tem estoque ou não
          if (size!.stock! - bagProduct.quantity! < 0) {
            // preenchendo a lista de produtos sem estoque
            productsWithoutStock.add(product);
          } else {
            // decrementando o estoque
            size.stock = size.stock! - bagProduct.quantity!;
            // adicionando os prds para serem atualizados os seus estoques
            productsToUpdate.add(product);
          }
        }

        // verificar se a lista de prd sem estoque não está vazia, se não estiver retornar um erro
        if (productsWithoutStock.isNotEmpty) {
          // retornar um erro
          return Future.error('${productsWithoutStock.length} produto(s) sem estoque...');
        }

        // 3. Salvar os estoques no firebase 2xM
        // passar por cada prd para atualizar o estoque
        for (final product in productsToUpdate) {
          // atualizar o estoque no firebase via transação
          tx.update(
            // acessando a ref do prd
            firestore.doc('products/${product.id}'),
            // atualizando o estoque - exportSizeList transforma obj em mapa
            {'sizes': product.exportSizeList()},
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
      final initialStock = finalStock + item.quantity!; // calculando para salvar o estoque inicial

      // Caminho para a subcoleção do tamanho dentro do produto
      final movementRef =
          firestore.collection('products').doc(product.id).collection(item.size!); // Nome do tamanho como subcoleção
      // Adicionando a movimentação DE CANCELAMENTO na subcoleção
      await movementRef.add({
        'quantity': item.quantity,
        'date': Timestamp.now(),
        'type': 'purchase',
        'purchaseId': purchaseId,
        'initialStock': initialStock,
        'finalStock': finalStock,
        'status': StatusPurchase.canceled.index,
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

    final finalBalance = initialBalance + priceTotal!;

    // Salvando a movimentação financeira diretamente
    await firestore.collection('movementsFinancial').add({
      'accountPayId': accountPayId,
      'priceTotal': priceTotal,
      'date': Timestamp.now(),
      'status': StatusAccountPay.canceled.index,
      'type': 'accountPay',
      'initialBalance': initialBalance,
      'finalBalance': finalBalance,
    });
  }

  // Função para obter os IDs das duplicatas a pagar para o cancelamento das duplicatas parceladas
  List<DocumentReference> get firestoreRefReceive {
    List<DocumentReference> references = [];
    if (installments! > 0) {
      // Se o pedido tiver parcelas, obtenha o ID com o formato $billsReceiveId-$i para cada parcela
      for (int i = 1; i <= installments!; i++) {
        references.add(firestore.collection('accountpay').doc('$accountPayId-$i'));
      }
    } else {
      // Caso contrário, obtenha o ID padrão
      references.add(firestore.collection('accountpay').doc(accountPayId));
    }
    return references;
  }

  // função para alterar o status para confirmado
  Future<void> confirm() async {
    // Seta o status de confirmado
    statusPurchase = StatusPurchase.confirmed;
    // Atualiza no Firebase
    await firestoreRef.update({'statusPurchase': statusPurchase!.index});
  }

  // função para alterar o status para pendente
  Future<void> pending() async {
    // Seta o status de confirmado
    statusPurchase = StatusPurchase.pending;
    // Atualiza no Firebase
    await firestoreRef.update({'statusPurchase': statusPurchase!.index});
  }

  // função para alterar o status para cancelado
  void cancel(BuildContext context) async {
    // Incrementa o estoque
    await _decrementStock().then((_) async {
      // Seta o status de cancelado
      statusPurchase = StatusPurchase.canceled;
      // Atualiza no Firebase
      await firestoreRef.update({'statusPurchase': statusPurchase!.index});
      // cancelar a duplicata a pagar
      if (accountPayId != null) {
        for (DocumentReference ref in firestoreRefReceive) {
          await ref.update({
            'statusAccountPay': StatusAccountPay.canceled.index,
            'datePay': null,
          });
        }
        debugPrint("Duplicata cancelada com sucesso");
      }

      // Cancela a movimentação financeira relacionada
      await _cancelFinancialMovement();
      // Cancela a movimentação no estoque relacionada à compra
      await _cancelStockMovement();
    }).catchError((e) {
      // Lida com o erro, se houver
      debugPrint('Erro ao incrementar o estoque: $e');
      // Exibe mensagem de sucesso
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
    firestore.collection('purchases').doc(purchaseId).set(
      {
        // transformando a lista de itens em uma lista de map toOrderItemMap criado cartProduct
        'items': items!.map((e) => e.toPurchaseItemMap()).toList(),
        'priceTotal': priceTotal,
        'user': userId,
        'supplier': supplierId,
        'statusPurchase': statusPurchase?.index, // pegando o index do status
        'date': Timestamp.now(), // setando a data atual do pedido
        'paymentMethod': paymentMethod,
        'accountPayId': accountPayId,
        'installments': installments,
      },
    );

    final DateTime now = DateTime.now(); // obtendo a data atual

    // SALVANDO CONTA
    final accountPay = AccountPayModel(
      paymentMethod: paymentMethod,
      purchaseId: purchaseId,
      supplier: supplierId,
      priceTotal: priceTotal,
      installments: installments,
      date: Timestamp.now(),
      dueDate: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59)), // Data de vencimento padrão
      statusAccountPay: StatusAccountPay.pending,
    );

    // Salvando a conta a pagar na coleção 'accountpay'
    await accountPay.save(installments, daysBetweenInstallments);

    // Salvando a movimentação de estoque na coleção 'movements'
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
        'type': 'purchase',
        'purchaseId': purchaseId,
        'initialStock': initialStock,
        'finalStock': finalStock,
        'status': statusPurchase?.index,
      });
    }
  }

  // função para atualizar as modificações no compra do purchaseManager para quando avançar ou voltar o status ou qqer outra coisa que quiser atualizar
  void updateFromDocument(DocumentSnapshot doc) {
    // passando apenas o status pois somente o status q vamos alterar
    statusPurchase = StatusPurchase.values[doc['statusPurchase'] as int];
    // atualizando o accountPayId na compra
    accountPayId = doc['accountPayId'] as String;
  }

  // função que retorna string para converter os status que são int em string, static para acessar de outro local do app sem ter a instancia do pedido
  static String getStatusText(StatusPurchase statusPurchase) {
    // pega todos os status
    switch (statusPurchase) {
      case StatusPurchase.canceled:
        return 'Cancelado';
      case StatusPurchase.pending:
        return 'Pendente';
      case StatusPurchase.confirmed:
        return 'Confirmado';
      case StatusPurchase.selectAll:
        return 'Selecionar Todos';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'PurchaseModel{purchaseId: $purchaseId, price: $priceTotal, userId: $userId, date: $date, items: $items, statusPurchase: $statusPurchase, paymentMethod: $paymentMethod}';
  }
}
