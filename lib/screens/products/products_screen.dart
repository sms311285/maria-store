import 'package:flutter/material.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/category/categories_manager.dart';
import 'package:maria_store/models/product/product_manager.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:maria_store/common/commons/list_widget_selection.dart';
import 'package:maria_store/screens/products/components/product_list_tile.dart';
import 'package:maria_store/screens/products/components/search_dialog.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        // Titulo da página na appBar
        // Consumer para qdo estiver pesquisando trocar o titulo da pagina pelo nome do prd que está pesquisando
        title: Consumer<ProductManager>(
          builder: (_, productManager, __) {
            if (productManager.search.isEmpty) {
              return const Text(
                'Produtos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              // Layout builder para o gesturedetector ocupar o maior espaço possível
              return LayoutBuilder(
                builder: (_, constraints) {
                  return GestureDetector(
                    // No ontap faço a mesma coisa que ali em baixo mostro o serach para digitar novamente a pesquisa quando tocado na área do titulo da pagina
                    onTap: () async {
                      final search = await showDialog<String>(
                        context: context,
                        // Recebendo o initialText do SearchDialog como parametro para trazer para o campo o que já digitou
                        builder: (_) => SearchDialog(initialText: productManager.search),
                      );
                      if (search != null) {
                        // Enviar a pesquisa para ProductManager
                        productManager.search = search;
                      }
                    },
                    child: SizedBox(
                      // Maximo da largura na horizontal do dispositivo
                      width: constraints.biggest.width,
                      child: Text(
                        productManager.search,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),

        centerTitle: true,
        actions: <Widget>[
          // Icones da appBar
          // Consumer para trocar o icone de pesquisando por um X quando tiver pesquisando
          Consumer<ProductManager>(
            builder: (_, productManager, __) {
              // Se não estiver pesquisando exibe o icone de pesquisa
              if (productManager.search.isEmpty) {
                return IconButton(
                  onPressed: () async {
                    // showDialog para mostrar o SearchDialog campo de pesquisa cobrir a tela
                    // showDialog<String> = pq o search é dinamico então avisando que vai retornar uma String
                    // Criando o search para retornar o resultado da pesquisa clicando em qqer icone
                    final search = await showDialog<String>(
                      context: context,
                      // Recebendo o initialText do SearchDialog como parametro
                      builder: (_) => SearchDialog(initialText: productManager.search),
                    );
                    if (search != null) {
                      // Enviar a pesquisa para ProductManager
                      productManager.search = search;
                    }
                  },
                  icon: const Icon(Icons.search),
                );
                // se estiver pesquisando exibe o icone de X
              } else {
                return IconButton(
                  onPressed: () async {
                    productManager.search = '';
                  },
                  icon: const Icon(Icons.close),
                );
              }
            },
          ),
          // Icone sacola de compras
          Consumer2<UserManager, BagManager>(
            builder: (_, userManager, bagManager, __) {
              if (userManager.adminEnabled) {
                return Badge(
                  backgroundColor: Colors.white,
                  offset: const Offset(-5, 5),
                  textColor: const Color.fromARGB(255, 5, 138, 98),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  label: Text(
                    '${bagManager.items.length}',
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pushNamed('/bag'),
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 25,
                    ),
                    color: Colors.white,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          // Icone add produto
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              if (userManager.adminEnabled) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // pushNamed para abrir a tela de criar/editar para qdo voltar ir para tela que estava antes
                    // Pode tbm Passar o argumento para o EditProductScreen arguments: product
                    Navigator.of(context).pushNamed('/edit_product');
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      // Corpo
      body: Column(
        children: <Widget>[
          // Categorias
          Consumer2<CategoriesManager, ProductManager>(
            builder: (_, categoriesManager, productManager, __) {
              // Acessa a lista de categorias
              final categories = categoriesManager.allCategory;
              return Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final category = categories[index];
                    return ListWidgetSelection(
                      image: category.image,
                      category: category.name!,
                      isSelected: category.id == productManager.selectedCategory,
                      onPressed: () {
                        productManager.toggleCategory(category.id!);
                      },
                    );
                  },
                ),
              );
            },
          ),
          // Expandend para expandir os itens e não dar overflow
          Expanded(
            // Consumer para observar as mudanças na tela de produtos e rebuildar
            child: Consumer<ProductManager>(
              builder: (_, productManager, __) {
                // Criando a variavel para não ficar chamando toda vez o filtro do produto
                final filteredProducts = productManager.filteredProducts;
                // GridView.builder caso tenha vários itens, ele vai construindo os produtos conforme rola a tela
                return GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Quantidade de colunas na grid
                    mainAxisSpacing: 1, // Espaçamento entre os itens na vertical
                    crossAxisSpacing: 1, // Espaçamento entre os itens na horizontal
                    childAspectRatio: 9 / 15, // Aspect ratio dos itens (largura / altura)
                  ),
                  // Pegando o tamanho da lista
                  itemCount: filteredProducts?.length,
                  // itemBuilder para construir os produtos pegando o index do produto
                  itemBuilder: (_, index) {
                    // ListTile dos Produtos customizado passando para o parametro product que passei na ProductListTile todos os prd
                    return ProductListTile(product: filteredProducts![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Botão do carrinho
      floatingActionButton: Consumer<CartManager>(
        builder: (_, cartManager, __) {
          // Badge para mostrar o contador de itens no carrinho
          return Badge(
            backgroundColor: Theme.of(context).primaryColor,
            offset: const Offset(-19, 6),
            textColor: Colors.white,
            label: Text(
              '${cartManager.items.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
              child: const Icon(
                Icons.shopping_cart,
                size: 35,
              ),
            ),
          );
        },
      ),
    );
  }
}
