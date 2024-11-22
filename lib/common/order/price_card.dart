// Classe para mostrar o resumo do pedido
import 'package:flutter/material.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:provider/provider.dart';

class PriceCard extends StatelessWidget {
  const PriceCard({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  // Passando por parametro o texto e o botão para recebe-los na CartScreen e manipular a ação
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Passando o watch ao inves de consumer pq vou precisar rebuildar todo o widget por completo
    final cartManager = context.watch<CartManager>();

    // Pegando o preço dos produtos
    final productsPrice = cartManager.productsPrice;

    // pegando o preço da entrega
    final deliveryPrice = cartManager.deliveryPrice;

    // obtendo o preço total do pedido
    final totalPrice = cartManager.totalPrice;

    final selectedInstallment = cartManager.selectedInstallmentOrder ?? 1;

    final installmentsValue = totalPrice / selectedInstallment;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          // stretch para ocupar a largura máqxima
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Texto resumo
            const Text(
              'Resumo do Pedido',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            // Texto subtotal
            Row(
              // spaceBetween - maior espaço entre eles, um fica na direita outro na esquerda
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Subtotal'),
                // Passando preços dos produtos
                Text('R\$ ${productsPrice.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),

            // verificando se o preço da entrega é != nulo para mostrar o preço da entrega
            if (deliveryPrice != null)
              // expansor para colocar uma lista dentro de outra lista, se não houver preço de entrega, esconder
              ...[
              // Texto entrega
              Row(
                // spaceBetween - maior espaço entre eles, um fica na direita outro na esquerda
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Entrega'),
                  // Passando preços dos produtos
                  Text('R\$ ${deliveryPrice.toStringAsFixed(2)}'),

                  // opção de quando for frete gratis seleção entega e valor zero aparecer texto entrega gratis
                  //  Text(deliveryPrice == 0.0 && cartManager.selectedOptionShipping == 'Entrega'
                  //     ? 'Entrega Grátis'
                  //     : 'R\$ ${deliveryPrice.toStringAsFixed(2)}'),
                ],
              ),
              const Divider(),
            ],

            // verificando se alguma parcela está selecioanda para mostrar a info no resumo
            if (cartManager.selectedInstallmentOrder != null &&
                cartManager.selectedInstallmentOrder! >= 1 &&
                cartManager.selectedPaymentMethod?.installmentsOrder != 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Parcelado'),
                  Text(
                    '${cartManager.selectedInstallmentOrder}x R\$ ${installmentsValue.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const Divider(),
            ],

            const SizedBox(height: 12),

            // Texto Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'R\$ ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Btn Continuar para endereço
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
              ),
              // Recebendo por parametro o texto e o botão da CartScreen
              onPressed: onPressed,
              child: Text(buttonText),
            )
          ],
        ),
      ),
    );
  }
}
