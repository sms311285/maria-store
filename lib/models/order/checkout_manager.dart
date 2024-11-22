import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/models/product/product.dart';

class CheckoutManager extends ChangeNotifier {
  // Criando oo cartManager local para acessar os dados do carrinho
  CartManager? cartManager;

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
  void updateCart(CartManager cartManager) {
    // setando o cartManager
    this.cartManager = cartManager;
  }

  // função de checkout utilizando tecnica de callback passando as funções por parametro
  Future<void> checkout({required Function onStockFail, required Function onSuccess}) async {
    loading = true;
    try {
      // decrementando estoque
      await _decrementStock();
    } catch (e) {
      // chamando onstock fail para indicar que o prd sem estoque
      onStockFail(e);
      loading = false;
      return;
    }

    // PROCESSAR PGTO

    // obter gerar numero do pedido
    final orderId = await _getOrderId();

    // gerar objeto do pedido, que e será o que vai enviar para o firebase
    final order = OrderModel.fromCartManager(cartManager!);

    // salvar o orderId na order, salvando como string pois o ID no firebase é string
    order.orderId = orderId.toString();

    // salvar pedido no firebase
    await order.save();

    // chamando a função para limpar o carrinho
    cartManager?.clear();

    // Limpar os campos de seleção da tela de entrega AddresScreen
    cartManager?.clearSelectedOptions();

    // chamando a função onSuccess e passando o obj order como parametro para tela de confirmation receber os dados do pedido
    onSuccess(order);

    loading = false;
  }

  // função para obter e incrementar o id do pedido
  Future<int> _getOrderId() async {
    // pegando o id do pedido do contador, criando uma referencia
    final ref = firestore.doc('aux/ordercounter');

    try {
      // executando uma transação, passando uma função
      final result = await firestore.runTransaction((tx) async {
        // ler o documento e passa a referencia do id
        final doc = await tx.get(ref);

        // obter a contagem atual do id
        final orderId = doc['current'] as int;

        // incrementar/atualizar o id
        tx.update(ref, {'current': orderId + 1});

        // retornar um map do id incrementado
        return {'orderId': orderId};
      });
      // retornar o id o result criado na transação
      return result['orderId'] as int;
    } catch (e) {
      return Future.error('Falha ao gerar número do pedido $e');
    }
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
        for (final cartProduct in cartManager!.items) {
          // passando obj product para ter acesso aos prds
          Product product;

          // verificar se o prd já está na lista de produtsToUpdate, any = contem algum elemento/prd cujo id é exatamente o mesmo id do cartProduct.productId
          if (productsToUpdate.any((p) => p.id == cartProduct.productId)) {
            // se sim, pegar o prd da lista e colocar no product
            product = productsToUpdate.firstWhere((p) => p.id == cartProduct.productId);
          } else {
            // acessando o documento referente ao cartProduct via transação.
            final doc = await tx.get(
              // obtendo o prd/estoque mais atualizado, acessando a ref do produto e colocando no doc
              firestore.doc('products/${cartProduct.productId}'),
            );
            // transformando em um obj produto, assim acessando todo o prd, lendo os prd mais atualizados colocando no doc
            product = Product.fromDocument(doc);
          }

          // adicionar o prd atualizado na lista de prds para serem atualizados e mostrar a lista de prds que não possuem estoque
          cartProduct.product = product;

          // obter o obj tamanho correspondente ao tamanho q selecionamos
          final size = product.findSize(cartProduct.size!);

          // 2. Decremento localmente os estoques 2xM
          // verificar se a qtde de itens que estamos solicitando possui estoque, verificar se tem estoque ou não
          if (size!.stock! - cartProduct.quantity! < 0) {
            // preenchendo a lista de produtos sem estoque
            productsWithoutStock.add(product);
          } else {
            // decrementando o estoque
            size.stock = size.stock! - cartProduct.quantity!;
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
}
