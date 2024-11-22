import 'package:flutter/material.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/models/category/categories.dart';
import 'package:maria_store/models/category/categories_manager.dart';
import 'package:maria_store/screens/categories/components/categories_tile.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Categorias',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/edit_categories', arguments: Categories());
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Consumer<CategoriesManager>(
        builder: (_, categoriesManager, __) {
          return ListView(
            children: <Widget>[
              Column(
                // Acessa a lista de todas as categorias
                children: categoriesManager.allCategory
                    // Itera sobre cada categoria na lista allCategory.
                    .map(
                      // Para cada categoria, cria um widget CategoriesTile, passando a categoria atual como parâmetro para o construtor de CategoriesTile.
                      (categories) => CategoriesTile(categories: categories),
                    )
                    // Converte o iterador retornado pelo método map em uma lista de widgets.
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
