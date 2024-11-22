// Classe referente a um item/objeto no carrinho

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/item_size/item_size.dart';
import 'package:maria_store/models/product/product.dart';

class BagProduct extends ChangeNotifier {
  // Instancia firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Construtor que recebe um produto e transforma em um produto do carrinho
  // Contém as infos básicas do produto/item no carrinho
  BagProduct.fromProduct(this._product) {
    productId = product!.id;
    quantity = 1;
    size = product!.selectedSizePurchase!.name;
  }

  // Sempre converte os dados do firebase em objeto no construtor para ficar mais prático recuperar os dados
  // Construtor para criar/pegar os documentos do firebase dos dados do produto no carrinho
  BagProduct.fromDocument(DocumentSnapshot document) {
    id = document.id;
    productId = document['pid'] as String;
    quantity = document['quantity'] as int;
    size = document['size'] as String;

    // Metodo - chamdada adicional para buscar os dados completos do produto, coleção produtos e pegando o documento pelo id
    firestore.doc('products/$productId').get().then(
      (doc) {
        // Setando o produto com base no documento que corresponde ao produto do carrinho
        product = Product.fromDocument(doc);
      },
    );
  }

  // Construtor para criar/pegar os dados do firebase dos dados do carrinho, transformando os itens do carrinho em objetos BagProduct
  BagProduct.fromMap(Map<String, dynamic> map) {
    // id do prd
    productId = map['pid'] as String;
    quantity = map['quantity'] as int;
    size = map['size'] as String;
    fixedPrice = map['fixedPrice'] as num;

    // Metodo - chamdada adicional para buscar os dados completos do produto, coleção produtos e pegando o documento pelo id
    firestore.doc('products/$productId').get().then(
      (doc) {
        // Setando o produto com base no documento que corresponde ao produto do carrinho
        product = Product.fromDocument(doc);
      },
    );
  }

  // Campos que serão salvos no firebase
  String? productId;
  int? quantity;
  String? size;
  // Variavel para guardar o id do item do cariinho
  String? id;

  // Instancia para salvar o objeto produto - definindo de forma privada para facilitar refazer a tela
  Product? _product;

  // variavel para fixar o preço na venda caso o prd altere o preço
  num? fixedPrice;

  // atualizar o produto refazer a tela para quando prd não tiver estoque
  // expondo a variavel product
  Product? get product => _product;
  // set para setar o prd no carrinho
  set product(Product? value) {
    // setando o prd
    _product = value;
    // notificando a alteração
    notifyListeners();
  }

  // get para pegar o preço do tamanho pelo nome produto
  ItemSize? get itemSize {
    // Tratando caso pedirmos o itemSize e o produto seja nulo caso o Product demore a carregar
    if (product == null) return null;
    return product!.findSize(size!);
  }

  // get para buscar o preço do tamanho
  num get unitPrice {
    // Tratando caso pedirmos o itemSize e o produto seja nulo caso o Product demore a carregar
    if (product == null) return 0;
    // Caso seja nulo retornar 0 no final
    return itemSize?.purchasePrice ?? 0;
  }

  // get para buscar o total do carrinho
  num get totalPrice => unitPrice * quantity!;

  // Metodo para slavar os dados (itens do carrinho no user), transaformando em map pois é a forma adotada no projeto para salvar (Chama lá no BagManager)
  Map<String, dynamic> toBagItemMap() {
    return {
      'pid': productId,
      'quantity': quantity,
      'size': size,
    };
  }

  // criado o mapa de itens para pedido, separado do toBagItemMap por conta do preço fixo
  Map<String, dynamic> toPurchaseItemMap() {
    return {
      'pid': productId,
      'quantity': quantity,
      'size': size,
      // se não tiver preço setar o valor, senao setar o valor unitPrice
      'fixedPrice': fixedPrice ?? unitPrice,
    };
  }

  // Empilhar itens, caso adiciona mais de um item igual empilhar e add a qtde
  bool stackable(Product product) {
    // Verificando se for o mesmo prd e o mesmo tamanho, juntar os itens
    return product.id == productId && product.selectedSizePurchase!.name == size;
  }

  // Metodos para add a qtde no carrinho
  void increment() {
    quantity = quantity! + 1;
    // Notificando as mudanças lá no BagTile
    notifyListeners();
  }

  // Metodos para decrementar a qtde no carrinho
  void decrement() {
    quantity = quantity! - 1;
    notifyListeners();
  }
}
