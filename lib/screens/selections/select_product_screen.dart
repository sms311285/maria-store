import 'package:flutter/material.dart';
import 'package:maria_store/models/product/product_manager.dart';
import 'package:provider/provider.dart';

class SelectProductScreen extends StatelessWidget {
  const SelectProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecionar Produto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Cor de fundo da tela
      backgroundColor: Colors.white,
      // Inserindo lista de prdutos
      body: Consumer<ProductManager>(
        builder: (_, productManager, __) {
          // retornando lista de produtos
          return Column(
            children: <Widget>[
              // campo de pesquisa
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: productManager.searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    suffixIcon: productManager.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              productManager.updateSearchProduct('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (product) {
                    productManager.updateSearchProduct(product);
                  },
                ),
              ),
              // retornando lista de produtos
              Expanded(
                child: ListView.builder(
                  // qtde de itens, acessando o tamanho da lista
                  itemCount: productManager.filterProducts.length,
                  // retornando os widgets
                  itemBuilder: (_, index) {
                    // pegando o produto correspondente do index atual que está colocando na lista
                    final product = productManager.filterProducts[index];
                    return ListTile(
                      // leading, item a esquerda que seria a imagem
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(product.images!.first),
                      ),
                      // nome prd
                      title: Text(product.name!),
                      // preço base do prd
                      subtitle: Text('R\$ ${product.basePrice.toStringAsFixed(2)}'),
                      // ao clicar em agum dos itens Selecionar prd
                      onTap: () {
                        // dando um pop no prd especifico
                        Navigator.of(context).pop(product);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
