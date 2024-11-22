import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/favorites/favorites_manager.dart';
import 'package:maria_store/models/favorites/favorites_product.dart';
import 'package:provider/provider.dart';

class FavoritesTile extends StatelessWidget {
  const FavoritesTile({super.key, required this.favoritesProduct});

  // Recebendo o FavoritesProduct por parametro para utilizar seus dados
  final FavoritesProduct favoritesProduct;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: favoritesProduct,
      // Quando tocar, abrir o produto correspondente
      child: GestureDetector(
        onTap: () {
          // Navegando para a tela do prd ProductScreen e passando o obj cartProduct como argumento para rota no main.dart e abrir o prd correspondente
          Navigator.of(context).pushNamed(
            '/product',
            arguments: favoritesProduct.product,
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: 80,
                  width: 80,
                  // Acessando o cartProduct pegando o produto correspondente ao cartProduct acessar as imagens e depois a primeira imagem
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      favoritesProduct.product!.images!.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Expanded para o conteudo central ocupar o maior espaço possivel jogando os itens da esqueda e direita para o canto
                // Sessão dos textos no card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Nome produto
                        Text(
                          // Pegando o prd do favorito, pegar o prd correspondente e dps o nome do prd
                          favoritesProduct.product!.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),

                        // exibindo container vazio quando está sem estoque e/ou deletado
                        if (!favoritesProduct.product!.hasStock)
                          Container()
                        else
                          // Texto a partir de:
                          Text(
                            'A partir de',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),

                        // Preço
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // exibindo informação quando está sem estoque e/ou deletado
                            if (!favoritesProduct.product!.hasStock)
                              const Text(
                                '- Produto sem Estoque -',
                                style: TextStyle(color: Colors.red, fontSize: 10),
                              )
                            else
                              Text(
                                // Pegando preço do tamanho acessando o prd
                                'R\$ ${favoritesProduct.product!.basePrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                            // Consumer para controlar o estado do icone favorito
                            Consumer<FavoritesManager>(
                              builder: (_, favoritesManager, __) {
                                // Verifica se o usuário está logado
                                if (favoritesManager.userApp == null) {
                                  // Se não estiver logado, retorna o widget de login ou outro widget apropriado
                                  return Container();
                                } else {
                                  // Pegando o produto favorito
                                  final isFavorite = favoritesManager.isFavorite(favoritesProduct.product!);
                                  // Icone favorito
                                  return CustomIconButton(
                                    iconData: Icons.favorite,
                                    color: Theme.of(context).primaryColor,
                                    onTap: () {
                                      // Dialog de confimração para remoção do item nos favoritos
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return CustomDialog(
                                            title: 'Remover Favoritos...',
                                            content: Text(
                                              'Deseja realmente remover "${favoritesProduct.product!.name}" de sua lista de favoritos?',
                                            ),
                                            confirmText: 'Remover',
                                            onConfirm: () {
                                              if (isFavorite) {
                                                final favoriteProduct =
                                                    // Encontra o item favorito correspondente ao produto atual na lista de favoritos.
                                                    // firstWhere percorre a lista items do favoriteManager e retorna o primeiro item cujo productId corresponde ao id do produto atual.
                                                    favoritesManager.items
                                                        .firstWhere((p) => p.productId == favoritesProduct.product!.id);
                                                // Remove o item encontrado da lista de favoritos.
                                                favoritesManager.removeOfFavorites(favoriteProduct);
                                              } else {
                                                // Adiciona o item na lista de favoritos
                                                favoritesManager.addToFavorites(favoritesProduct.product!);
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            onCancel: () => Navigator.of(context).pop(),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
