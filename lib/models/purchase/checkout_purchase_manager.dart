import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/purchase/purchase_model.dart';

class CheckoutPurchaseManager extends ChangeNotifier {
  // Criando oo cartManager local para acessar os dados do carrinho
  BagManager? bagManager;

  // instanciando o firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // indicador de carregamento
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // criando uodatecart para atualizar o cartManager
  void updateBag(BagManager bagManager) {
    // setando o cartManager
    this.bagManager = bagManager;
  }

  // função de checkout utilizando tecnica de callback passando as funções por parametro
  Future<void> checkoutPurchase({required Function onSuccess}) async {
    loading = true;
    try {
      // incrementando estoque
      await _incrementStock();
    } catch (e) {
      loading = false;
      return;
    }

    // PROCESSAR PGTO

    // obter gerar numero do pedido
    final purchaseId = await _getPurchaseId();

    // gerar objeto do pedido, que e será o que vai enviar para o firebase
    final purchase = PurchaseModel.fromBagManager(bagManager!);

    // salvar o orderId na order, salvando como string pois o ID no firebase é string
    purchase.purchaseId = purchaseId.toString();

    // salvar pedido no firebase
    await purchase.save();

    // chamando a função para limpar o carrinho
    bagManager?.clear();

    // Limpar os campos de seleção da tela de entrega AddresScreen
    bagManager?.clearSelectedOptions();

    // chamando a função onSuccess e passando o obj order como parametro para tela de confirmation receber os dados do pedido
    onSuccess(purchase);

    loading = false;
  }

  // função para obter e incrementar o id do pedido
  Future<int> _getPurchaseId() async {
    // pegando o id do pedido do contador, criando uma referencia
    final ref = firestore.doc('aux/purchasecounter');

    try {
      // executando uma transação, passando uma função
      final result = await firestore.runTransaction((tx) async {
        // ler o documento e passa a referencia do id
        final doc = await tx.get(ref);

        // obter a contagem atual do id
        final purchaseId = doc['current'] as int;

        // incrementar/atualizar o id
        tx.update(ref, {'current': purchaseId + 1});

        // retornar um map do id incrementado
        return {'purchaseId': purchaseId};
      });
      // retornar o id o result criado na transação
      return result['purchaseId'] as int;
    } catch (e) {
      return Future.error('Falha ao gerar número do compra $e');
    }
  }

  // incrementar estoque ao cancelar ou efetuar uma compra
  Future<void> _incrementStock() {
    return firestore.runTransaction(
      (tx) async {
        final List<Product> productsToUpdate = [];

        // Percorre todos os itens do pedido
        for (final bagProduct in bagManager!.items) {
          Product product;

          // Verifica se o produto já está na lista de produtos a serem atualizados
          if (productsToUpdate.any((p) => p.id == bagProduct.productId)) {
            product = productsToUpdate.firstWhere((p) => p.id == bagProduct.productId);
          } else {
            final doc = await tx.get(
              firestore.doc('products/${bagProduct.productId}'),
            );
            product = Product.fromDocument(doc);
          }

          bagProduct.product = product;

          final size = product.findSize(bagProduct.size!);

          // Incrementa o estoque
          size!.stock = size.stock! + bagProduct.quantity!;
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
}
