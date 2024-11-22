import 'package:flutter/material.dart';
import 'package:maria_store/models/category/categories_manager.dart';
import 'package:provider/provider.dart';

class SelectCategoryScreen extends StatelessWidget {
  const SelectCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecionar Categoria',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Cor de fundo da tela
      backgroundColor: Colors.white,
      // Inserindo lista de prdutos
      body: Consumer<CategoriesManager>(
        builder: (_, categoriesManager, __) {
          // retornando lista de produtos
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // qtde de itens, acessando o tamanho da lista
            itemCount: categoriesManager.allCategory.length,
            // retornando os widgets
            itemBuilder: (_, index) {
              // pegando o produto correspondente do index atual que está colocando na lista
              final category = categoriesManager.allCategory[index];
              return ListTile(
                contentPadding: const EdgeInsets.only(top: 8, left: 4),
                // leading, item a esquerda que seria a imagem
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(category.image!),
                ),
                // nome prd
                title: Text(category.name!),

                // ao clicar em agum dos itens Selecionar prd
                onTap: () {
                  // dando um pop no prd especifico
                  Navigator.of(context).pop(category);
                },
              );
            },
          );
        },
      ),
    );
  }
}
