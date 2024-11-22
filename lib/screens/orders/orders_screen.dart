import 'package:flutter/material.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/common/empty_screen/login_card.dart';
import 'package:maria_store/models/order/orders_manager.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/order/order_tile.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Meus pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<OrdersManager>(
        builder: (_, ordersManager, __) {
          // verificando se o user logado existe
          if (ordersManager.userApp == null) {
            return const LoginCard();
          }

          // verificar se tem nenhum pedido
          if (ordersManager.orders.isEmpty) {
            return const EmptyCard(
              title: 'Nenhum pedido foi realizado ainda!',
              iconData: Icons.border_clear,
            );
          }

          // se as duas condições forem atendidas, retornar a lista de pedidos
          return ListView.builder(
            // qtde de itens na lista
            itemCount: ordersManager.orders.length,
            itemBuilder: (_, index) {
              return OrderTile(
                // passando o pedido a partir do index, passando o parametro orders, invertendo a ordem da lista
                order: ordersManager.orders.reversed.toList()[index],
              );
            },
          );
        },
      ),
    );
  }
}
