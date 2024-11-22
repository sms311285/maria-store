import 'package:flutter/material.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/common/empty_screen/login_card.dart';
import 'package:maria_store/models/favorites/favorites_manager.dart';
import 'package:maria_store/screens/favorites/components/favorites_tile.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<FavoritesManager>(
        builder: (_, favoritesManager, __) {
          // Se não houver nenhum user logado mostrar o LoginCard customizado
          if (favoritesManager.userApp == null) {
            return const LoginCard();
          }

          // Se não houver nenhum favorito mostrar o emptyCard customizado
          if (favoritesManager.items.isEmpty) {
            return const EmptyCard(
              iconData: Icons.heart_broken_rounded,
              title: 'Nenhum produto nos favoritos!',
            );
          }

          return ListView(
            children: <Widget>[
              Column(
                // retornar a lista de items de favoritos
                children: favoritesManager.items
                    .map((favoritesProduct) => FavoritesTile(favoritesProduct: favoritesProduct))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
