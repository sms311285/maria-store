import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/product/product.dart';

class FavoritesProduct extends ChangeNotifier {
  // Instancia firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Construtor que recebe um produto e transforma em um produto do favorito
  // Contém as infos básicas do produto/item no favorito
  FavoritesProduct.fromProduct(this.product) {
    productId = product!.id;
  }

  // Sempre converte os dados do firebase em objeto no construtor para ficar mais prático recuperar os dados
  // Construtor para criar/pegar os documentos do firebase já armazenados dos dados do produto no favorito
  FavoritesProduct.fromDocument(DocumentSnapshot document) {
    id = document.id;
    productId = document['pid'] as String;

    // Metodo para buscar os dados do produto, entrando na coleção de produtos e puxando o documento pelo id
    firestore.doc('products/$productId').get().then(
      (doc) {
        // Setando o produto com base no documento que corresponde ao produto do favorito, criando obj
        product = Product.fromDocument(doc);
        // Notificar quando buscar os prd no firebase
        notifyListeners();
      },
    );
  }

  // Método para transformar em map para salvar no Firestore
  Map<String, dynamic> toFavoriteItemMap() {
    return {
      'pid': productId,
    };
  }

  // Instancia para salvar o objeto produto
  Product? product;

  // Campos que serão salvos no firebase
  String? productId;
  // Variavel para guardar o id do item do cariinho
  String? id;
}
