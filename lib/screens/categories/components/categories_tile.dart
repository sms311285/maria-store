import 'package:flutter/material.dart';
import 'package:maria_store/models/category/categories.dart';
import 'package:provider/provider.dart';

class CategoriesTile extends StatelessWidget {
  const CategoriesTile({super.key, required this.categories});

  final Categories categories;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: categories,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/edit_categories', arguments: categories);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${categories.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                // recuperar Icone
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.network(
                    categories.image!,
                    fit: BoxFit.cover,
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
