import 'package:flutter/material.dart';
import 'package:maria_store/models/item_size/item_size.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:provider/provider.dart';

class SizeWidget extends StatelessWidget {
  const SizeWidget({super.key, required this.size});

  // Pegando os dados do tamanho passado por parametro
  final ItemSize size;

  @override
  Widget build(BuildContext context) {
    // Obter o Product passado por parametro que está selecionado
    // watch para rebuildar todo o widget não parte dele como utilizando o consumer
    final product = context.watch<Product>();
    // Verificando se tamanho está selecionado ou não
    final selected = size == product.selectedSize;

    // Verificando as cores (hasStock verifica se tem estoque) quando o tamanho está selecionado, ou não ou sem estoque
    Color color;
    if (!size.hasStock) {
      // Se for admin e o tamanho não tem estoque e estiver selecionado, mostrar vermelho
      color = Colors.red.withAlpha(50);
    } else if (selected) {
      color = Theme.of(context).primaryColor;
    } else {
      color = Colors.grey;
    }

    // Selecionando tamanho
    return GestureDetector(
      onTap: () {
        // Verificar se tem estoque ou se o usuário é admin
        if (size.hasStock) {
          // e selecionar tamanho
          product.selectedSize = size;
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
            // Preços - Verificar se preços dos tamanhos são diferente se sim mostra se não esconde o preço
            // any verifica se há pelo menos um elemento na lista que satisfaça a condição fornecida
            if (product.sizes!.any((s) => s.price != product.sizes![0].price))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'R\$ ${size.price!.toStringAsFixed(2)}',
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
