import 'package:flutter/material.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/models/stores/stores_manager.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:maria_store/screens/stores/components/store_card.dart';
import 'package:provider/provider.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Lojas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Consumer<UserManager>(
            builder: (_, userManager, __) {
              if (userManager.adminEnabled) {
                return IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/edit_store');
                  },
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),

      // consumer que obtem a StoresManager, qunado abrir a tela ja vai buscar as lojas
      body: Consumer<StoresManager>(
        builder: (_, storesManager, __) {
          // VERIFICANDO SE A LISTA NÕ ESTÁ VAZIA POR CONTA DO LAZY TRUE
          if (storesManager.stores.isEmpty) {
            // mostrar um carregando se estiver vazio
            return const LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              backgroundColor: Colors.transparent,
            );
          }
          // retornar conteudo
          return ListView.builder(
            // qtde de itens
            itemCount: storesManager.stores.length,
            // itens
            itemBuilder: (_, index) {
              return StoreCard(
                store: storesManager.stores[index],
              );
            },
          );
        },
      ),
    );
  }
}
