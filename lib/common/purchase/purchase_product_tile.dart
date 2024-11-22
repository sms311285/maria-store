import 'package:flutter/material.dart';
import 'package:maria_store/models/bag/bag_product.dart';

// tela para todas as compras
class PurchaseProductTile extends StatelessWidget {
  const PurchaseProductTile({super.key, required this.bagProduct});

  // recebendo os objetos do bag
  final BagProduct bagProduct;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegando para tela do prduto passando como argumento para abrir a tela do produtos correspondente
        Navigator.of(context).pushNamed('/product', arguments: bagProduct.product);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            // imagem do item
            SizedBox(
              height: 60,
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // pegando o bagProduct pegando o prd correspondente ao bagProduct dps a imagem do prd
                child: Image.network(bagProduct.product!.images!.first),
              ),
            ),

            const SizedBox(width: 8),

            // textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // nome do prd
                  Text(
                    bagProduct.product!.name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  // tamanho
                  Text(
                    'Tamanho: ${bagProduct.size}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  // preço
                  Text(
                    'R\$ ${(bagProduct.fixedPrice ?? bagProduct.unitPrice).toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            //qtde
            Text(
              '${bagProduct.quantity}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
