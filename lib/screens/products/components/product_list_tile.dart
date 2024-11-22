import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/favorites/favorites_manager.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:provider/provider.dart';

class ProductListTile extends StatelessWidget {
  const ProductListTile({super.key, required this.product});

  // Passando por parâmetro pegando do obj Product com todos os dados do produto
  final Product product;

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider.value para deixar disp produto apenas ProductScreen e não em todo o app
    // Por isso que cria apenas aqui e não no main
    return ChangeNotifierProvider.value(
      value: product,
      child: GestureDetector(
        onTap: () {
          // Navegando para a tela do prd ProductScreen e passando o obj product como argumento para rota no main.dart
          Navigator.of(context).pushNamed(
            '/product',
            arguments: product,
          );
        },
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                // AspectRatio Deixar aspecto quadrado
                AspectRatio(
                  aspectRatio: 1,
                  // Pegando a imagem do obj product
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.images!.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Expanded para expadir a coluna
                Column(
                  // Alinhando coluna a esquerda
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Espalhando o conteudo na coluna
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // Infomações do card
                  children: <Widget>[
                    // Nome
                    Text(
                      product.name!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    // Texto a partir de: - icone favorito
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Texto a partir de:
                          Text(
                            'A partir de',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
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
                                final isFavorite = favoritesManager.isFavorite(product);
                                // Icone favorito
                                return CustomIconButton(
                                  iconData: isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Theme.of(context).primaryColor,
                                  onTap: () {
                                    // Verificando se o produto é favorito
                                    if (isFavorite) {
                                      final favoriteProduct =
                                          // Encontra o item favorito correspondente ao produto atual na lista de favoritos.
                                          // firstWhere percorre a lista items do favoriteManager e retorna o primeiro item cujo productId corresponde ao id do produto atual.
                                          favoritesManager.items.firstWhere((p) => p.productId == product.id);
                                      // Remove o item encontrado da lista de favoritos.
                                      favoritesManager.removeOfFavorites(favoriteProduct);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Removido dos seus favoritos!'),
                                          backgroundColor: Theme.of(context).primaryColor,
                                        ),
                                      );
                                    } else {
                                      // Adiciona o item na lista de favoritos
                                      favoritesManager.addToFavorites(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Adicionado aos seus favoritos!'),
                                          backgroundColor: Theme.of(context).primaryColor,
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Valor
                    Text(
                      'R\$ ${product.basePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                    // verificando se o prd não possui estoque para mostrar o informativo
                    if (!product.hasStock)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          '- Produto sem Estoque -',
                          style: TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
