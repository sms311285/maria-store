import 'package:flutter/material.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/common/empty_screen/login_card.dart';
import 'package:maria_store/common/order/price_card.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/screens/cart/components/cart_tile.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carrinho',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Consumer para rebuildar a tela e alterar a ação do botão ativar ou desativar e a lista de itens
      body: Consumer<CartManager>(
        builder: (_, cartManager, __) {
          // verificando se tem algum user logado para mostrar os itens do carrinho se não mostrar o loginCard
          if (cartManager.userApp == null) {
            return const LoginCard();
          }

          // Verificando tbm que se o carrinho estiver vazio mostrar o emptyCard
          if (cartManager.items.isEmpty) {
            return const EmptyCard(
              iconData: Icons.remove_shopping_cart,
              title: 'Nenhum produto no carrinho :(',
            );
          }

          // caso tenha user logado e tenha itens no carrinho mostrar os itens normalmente
          return ListView(
            children: <Widget>[
              Column(
                // retornar a lista de items de carrinho
                children: cartManager.items.map((cartProduct) => CartTile(cartProduct: cartProduct)).toList(),
              ),
              // Card de preço do carrinho
              PriceCard(
                // passando por parametro o texto e o botão para PriceCard e manipular a ação
                buttonText: 'Continuar para Entrega',
                onPressed: cartManager.isCartValid
                    ? () {
                        // navegando para tela do endereço
                        Navigator.of(context).pushNamed('/address');
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
