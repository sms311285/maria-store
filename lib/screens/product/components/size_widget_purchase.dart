import 'package:flutter/material.dart';
import 'package:maria_store/models/item_size/item_size.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:provider/provider.dart';

class SizeWidgetPurchase extends StatelessWidget {
  const SizeWidgetPurchase({super.key, required this.size});

  // Pegando os dados do tamanho passado por parametro
  final ItemSize size;

  @override
  Widget build(BuildContext context) {
    // Obter o Product passado por parametro que está selecionado
    // watch para rebuildar todo o widget não parte dele como utilizando o consumer
    final product = context.watch<Product>();
    // Verificando se tamanho está selecionado ou não
    final selectedPurchase = size == product.selectedSizePurchase;
    // Obter o estado de UserManager para verificar se é admin
    final userManager = context.watch<UserManager>();

    // Verificando as cores (hasStock verifica se tem estoque) quando o tamanho está selecionado, ou não ou sem estoque
    Color color;
    if (!size.hasStock) {
      // Se for admin e o tamanho não tem estoque e estiver selecionado, mostrar vermelho
      color = userManager.adminEnabled && selectedPurchase ? Colors.red : Colors.red.withAlpha(50);
    } else if (selectedPurchase) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Colors.grey;
    }

    // Selecionando tamanho
    return GestureDetector(
      onTap: () {
        // Verificar se tem estoque ou se o usuário é admin
        if (userManager.adminEnabled) {
          // e selecionar tamanho
          product.selectedSizePurchase = size;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          // Ocupar minima largura possível
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Tamanhos
            Container(
              color: color,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                size.name!,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            // widget preços compra
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'R\$ ${size.purchasePrice!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
