import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/favorites/favorites_product.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';

class FavoritesManager extends ChangeNotifier {
  // Lista de FavoriteProduct para carregar e guardar a lista de itens favoritos
  List<FavoritesProduct> items = [];

  // Para salvar o usuário logado, obtendo seus dados a partir do parametro
  UserApp? userApp;

  // Metodo para atualizar o user logado e carregar seus favoritos
  void updateUser(UserManager userManager) {
    // Usuario sendo modificado
    userApp = userManager.userApp;
    // Apagar itens dos favoritos
    items.clear();

    // Carregar favoritos do user logado
    if (userApp != null) {
      _loadFavoritesItems();
    }
  }

  // Função para acessar o favorito do user e buscar os documentos usando favoritesReference referencia do favorito criado em userApp
  Future<void> _loadFavoritesItems() async {
    // Buscar/carregar todos os documentos do favorito
    final QuerySnapshot favoritesSnap = await userApp!.favoritesReference.get();
    // Pegar cada um dos documentos e mapear em um FavoriteProduct que será criado a partir do documento recuperado
    // addListener, em cada item do favoritos, para obter as atualizaçõs na qtde exemplo se adicionar ou remover itens no favorito
    items = favoritesSnap.docs.map((d) => FavoritesProduct.fromDocument(d)..addListener(_onItemUpdated)).toList();
  }

  // Add produto aos favoritos passando um prd por parametro
  void addToFavorites(Product product) {
    // Verificar se o produto já está na lista de favoritos
    final exists = items.any((p) => p.productId == product.id);
    // final e = items.firstWhere((p) => p.productId == product.id);

    if (!exists) {
      // Criar o FavoriteProduct para pegar produto, transformar em um prd que pode entrar nos favoritos e add aos itens
      final favoriteProduct = FavoritesProduct.fromProduct(product);
      // addListener parte do ChangeNotifier que observa a mudança e passa uma função (_onItemUpdated) por parametro para ser executado
      // adicionado addListener em cada item dos favoritos _loadFavoriteItems
      favoriteProduct.addListener(_onItemUpdated);
      // Adicionando itens
      items.add(favoriteProduct);
      // Salvar favoriteProduct (para adicionar dados no firebase precisa transformar em map) lá no favoritesReference do userApp
      userApp!.favoritesReference.add(favoriteProduct.toFavoriteItemMap()).then((doc) => favoriteProduct.id = doc.id);
      // Chamar _onItemUpdated manualmente para atualizar as mudanças
      _onItemUpdated();
    }
    notifyListeners();
  }

  // Metodo para remover o item dos favoritos
  void removeOfFavorites(FavoritesProduct favoriteProduct) {
    // Procurar pelo item que corresponde o id e remove se o id for igual
    items.removeWhere((p) => p.id == favoriteProduct.id);
    // Remover do favoritesReference do userApp
    userApp?.favoritesReference.doc(favoriteProduct.id).delete();
    // Remover o addListener do favoriteProduct
    favoriteProduct.removeListener(_onItemUpdated);
    notifyListeners();
  }

  // Metodo para ser executado no addlistener (Atualizar dados do item dos favoritos)
  void _onItemUpdated() {
    // Notificando as atualizações
    notifyListeners();
  }

  // Verificar se o produto está nos favoritos
  // recebe um objeto Product como argumento e retorna um valor booleano
  bool isFavorite(Product product) {
    // O método any é uma função de alta ordem que percorre cada elemento na lista items e aplica a função (p) fornecida a cada elemento.
    return items.any((p) => p.productId == product.id);
  }
}
