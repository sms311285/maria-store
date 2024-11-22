import 'package:flutter/material.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/common/purchase/price_purchase_card.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/screens/bag/components/bag_tile.dart';
import 'package:provider/provider.dart';

class BagScreen extends StatelessWidget {
  const BagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sacola de Compras',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Consumer para rebuildar a tela e alterar a ação do botão ativar ou desativar e a lista de itens
      body: Consumer<BagManager>(
        builder: (_, bagManager, __) {
          // Verificando tbm que se o carrinho estiver vazio mostrar o emptyCard
          if (bagManager.items.isEmpty) {
            return const EmptyCard(
              iconData: Icons.leave_bags_at_home,
              title: 'Nenhum produto na sacola :(',
            );
          }

          // caso tenha user logado e tenha itens no carrinho mostrar os itens normalmente
          return ListView(
            children: <Widget>[
              Column(
                // retornar a lista de items de carrinho
                children: bagManager.items.map((bagProduct) => BagTile(bagProduct: bagProduct)).toList(),
              ),
              // Card de preço do carrinho
              PricePurchaseCard(
                // passando por parametro o texto e o botão para PricePurchaseCard e manipular a ação
                buttonText: 'Continuar para Compra',
                onPressed: () {
                  // navegando para tela do endereço
                  Navigator.of(context).pushNamed('/close_purchase');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
