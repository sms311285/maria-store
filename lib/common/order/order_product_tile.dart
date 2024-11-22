import 'package:flutter/material.dart';
import 'package:maria_store/models/cart/cart_product.dart';

class OrderProductTile extends StatelessWidget {
  const OrderProductTile({super.key, required this.cartProduct});

  // recebendo os objetos do cart
  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegando para tela do prduto passando como argumento para abrir a tela do produtos correspondente
        Navigator.of(context).pushNamed('/product', arguments: cartProduct.product);
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
                // pegando o cartProduct pegando o prd correspondente ao cartProduct dps a imagem do prd
                child: Image.network(cartProduct.product!.images!.first),
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
                    cartProduct.product!.name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                  // tamanho
                  Text(
                    'Tamanho: ${cartProduct.size}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  // preço
                  Text(
                    'R\$ ${(cartProduct.fixedPrice ?? cartProduct.unitPrice).toStringAsFixed(2).replaceAll('.', ',')}',
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
              '${cartProduct.quantity}',
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
