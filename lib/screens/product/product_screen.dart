import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
// // Escondendo o CarouselController do pacote carousel_slider para evitar conflito de nomes devido atualização do flutter
import 'package:flutter/material.dart' hide CarouselController;
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/favorites/favorites_manager.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:maria_store/screens/product/components/size_widget.dart';
import 'package:maria_store/screens/product/components/size_widget_purchase.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key, required this.product});

  // Passando product por parametro para pegar os seus dados
  final Product product;

  // usado para controlar a página atual do carrossel usado com dots
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

  // Controller para dots do carousel a troca de img
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    // Instanciando a cor padrão do app
    final primaryColor = Theme.of(context).primaryColor;

    // Limpar o tamanho selecionado quando reconstruir a tela (Sair da tela ou fazer logoff)
    product.selectedSize = null;
    product.selectedSizePurchase = null;

    // ChangeNotifierProvider.value para deixar disponível o produto apenas para ProductScreen e não em todo o app
    // Por isso que cria apenas aqui e não cria tbm no main
    return ChangeNotifierProvider.value(
      // Passa o value para fornecer o objeto, já o create cria um novo objeto
      value: product,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            product.name!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            // Consumer para mostrar o botão de editar quando o admin estiver habilitado
            Consumer<UserManager>(
              builder: (_, userManager, __) {
                // verificando se o adm está habilitado e se o produto não está deletado para exibir o botão de editar
                if (userManager.adminEnabled && !product.deleted!) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Substituir a tela de ProductScreen pelo EditProductScreen passando argumento Produto para ser editado
                      Navigator.of(context).pushNamed('/edit_product', arguments: product);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
        // Fundo branco do scaffold
        backgroundColor: Colors.white,
        // ListView para rolar a tela caso a tela do dispositivo seja pequena
        body: ListView(
          children: <Widget>[
            AspectRatio(
              // Aspecto quadrado
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  // Carrossel de Imagens
                  GestureDetector(
                    onTap: () {
                      product.showImageDialog(
                        context,
                        product.images!,
                      );
                    },
                    child: CarouselSlider(
                      carouselController: _carouselController,
                      // Pegando kda imagem utilizando um map e dá um toList
                      items: product.images?.map((url) {
                        return Image.network(url);
                      }).toList(),
                      options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: true,
                        aspectRatio: 1.0,
                        onPageChanged: (index, reason) {
                          currentPageNotifier.value = index;
                        },
                      ),
                    ),
                  ),

                  // Dots indicator
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    // Atualizar um DotsIndicator com base na página atual do CarouselSlider.
                    child: ValueListenableBuilder<int>(
                      valueListenable: currentPageNotifier,
                      builder: (_, currentPage, __) {
                        return DotsIndicator(
                          dotsCount: product.images?.length ?? 0,
                          position: currentPage,
                          decorator: DotsDecorator(
                            size: const Size.square(9.0),
                            activeSize: const Size(18.0, 9.0),
                            activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          // Tocar nos pontos e rolar a imagem
                          onTap: (page) {
                            _carouselController.animateToPage(page.toInt());
                          },
                        );
                      },
                    ),
                  ),

                  // Botão ampliar imagem carrossel
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CustomIconButton(
                      iconData: Icons.zoom_in_outlined,
                      color: primaryColor,
                      size: 26,
                      onTap: () {
                        product.showImageDialog(
                          context,
                          product.images!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Informações dos produtos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // Esticar todo conteúdo
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Nome produto
                  Text(
                    product.name!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Texto a partir de:
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'A partir de',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // Preço e icone favoritos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Preço
                      Text(
                        'R\$ ${product.basePrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),

                      // Consumer para controlar o estado do icone se tocado
                      Consumer<FavoritesManager>(
                        builder: (_, favoritesManager, __) {
                          if (favoritesManager.userApp == null) {
                            // Se não estiver logado, retorna container vazio
                            return Container();
                          } else {
                            // Pegando o produto favorito O método isFavorite é invocado, passando o objeto product como argumento
                            // verifica se existe algum item na lista items dentro do FavoritesManager cujo productId corresponde ao id do produto fornecido.
                            final isFavorite = favoritesManager.isFavorite(product);
                            // Icone favorito
                            return CustomIconButton(
                              iconData: isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: primaryColor,
                              colorInk: Colors.grey[200],
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
                                      backgroundColor: primaryColor,
                                    ),
                                  );
                                } else {
                                  // Adiciona o item na lista de favoritos
                                  favoritesManager.addToFavorites(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Adicionado aos favoritos!'),
                                      backgroundColor: primaryColor,
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

                  // Descrição
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      'Descrição',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Texto Descrição
                  Text(
                    product.description!,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  // Consumer 2 para observar 2 estados, se o user tá logado e se o item tiver selecionado para manipular btn
                  Consumer2<UserManager, Product>(
                    builder: (_, userManager, product, __) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // verificando se o prd não está deletado para mostrar os tamanhos
                          if (product.deleted!)
                            const Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 8),
                              child: Text(
                                'Este produto não está mais disponível!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          // componente de expansão (para montar lista de widget) para pegar o else para texto tamanhos e o wrap para tamanhos
                          else ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                              child: Text(
                                'Tamanhos:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Componente Wrap para tamanhos, permite que coloque um widgewt ao lado do outro até não caber mais
                            Wrap(
                              // Espaçamento entre widgets
                              spacing: 8.0,
                              // Espaçamento entre linhas
                              runSpacing: 8.0,
                              // Pegar prd e os tamanhos de dar um map
                              children: product.sizes!.map((s) {
                                // Wiget para tamanhos
                                return SizeWidget(size: s);
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Botão "Adicionar ao Carrinho" (somente se o produto tiver estoque)
                          if (product.hasStock)
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                // Verificando se tem algum item selecionado e se o user tá logado para dar ação no btn
                                onPressed: product.selectedSize != null
                                    ? () {
                                        if (userManager.isLoggedIn) {
                                          // Adicionar ao carrinho usando read, pois o prd está disponível apenas neste widget
                                          context.read<CartManager>().addToCart(product);
                                          Navigator.of(context).pushNamed('/cart');
                                        } else {
                                          // Entra para login
                                          Navigator.of(context).pushNamed('/login');
                                        }
                                      }
                                    : null,
                                child: Text(
                                  // verificando se user está logado, para mostrar texto
                                  userManager.isLoggedIn ? 'Adicionar ao Carrinho' : 'Entre para Comprar',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),

                          // Espaço entre os botões
                          const SizedBox(height: 10),

                          // verificando se o prd não está deletado para mostrar os tamanhos
                          if (product.deleted! && userManager.adminEnabled)
                            const Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 8),
                              child: Text(
                                'Este produto não está mais disponível!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          // componente de expansão (para montar lista de widget) para pegar o else para texto tamanhos e o wrap para tamanhos
                          else if (userManager.adminEnabled) ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                              child: Text(
                                'Tamanhos para Compra:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Componente Wrap para tamanhos, permite que coloque um widgewt ao lado do outro até não caber mais
                            Wrap(
                              // Espaçamento entre widgets
                              spacing: 8.0,
                              // Espaçamento entre linhas
                              runSpacing: 8.0,
                              // Pegar prd e os tamanhos de dar um map
                              children: product.sizes!.map((p) {
                                // Wiget para tamanhos
                                return SizeWidgetPurchase(size: p);
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Exibe o botão "Comprar Agora (Admin)" se o usuário for admin, independente de estoque
                          if (userManager.adminEnabled)
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                // Ação para o botão de compra direta
                                onPressed: product.selectedSizePurchase != null
                                    ? () {
                                        // Adicionar ao carrinho usando read, pois o prd está disponível apenas neste widget
                                        context.read<BagManager>().addToBag(product);
                                        Navigator.of(context).pushNamed('/bag');
                                      }
                                    : null,
                                child: const Text(
                                  'Comprar Agora (Admin)',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
