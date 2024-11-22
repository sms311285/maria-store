// Classe para mostrar o resumo do pedido
import 'package:flutter/material.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:provider/provider.dart';

class PricePurchaseCard extends StatelessWidget {
  const PricePurchaseCard({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  // Passando por parametro o texto e o botão para recebe-los na bagScreen e manipular a ação
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Passando o watch ao inves de consumer pq vou precisar rebuildar todo o widget por completo
    final bagManager = context.watch<BagManager>();

    // Pegando o preço dos produtos
    final productsPrice = bagManager.productsPrice;

    // obtendo o preço total do pedido
    final totalPrice = bagManager.totalPrice;

    final selectedInstallment = bagManager.selectedInstallmentPurchase ?? 1;

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
              'Resumo da compra',
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

            // verificando se alguma parcela está selecioanda para mostrar a info no resumo
            if (bagManager.selectedInstallmentPurchase != null &&
                bagManager.selectedInstallmentPurchase! >= 1 &&
                bagManager.selectedPaymentMethod?.installmentsPurchase != 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Parcelado'),
                  Text(
                    '${bagManager.selectedInstallmentPurchase}x R\$ ${installmentsValue.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const Divider(),
            ],

            // verificando se alguma parcela está selecioanda para mostrar a info no resumo
            if (bagManager.selectedInstallmentPurchase != null &&
                bagManager.selectedInstallmentPurchase! >= 1 &&
                bagManager.selectedPaymentMethod?.installmentsPurchase != 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Dias entre parcelas'),
                  Text(
                    '${bagManager.selectedDays} dias',
                  ),
                ],
              ),
              const Divider(),
            ],

            // verificando se o preço da entrega é != nulo para mostrar o preço da entrega
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
              // Recebendo por parametro o texto e o botão da bagScreen
              onPressed: onPressed,
              child: Text(buttonText),
            )
          ],
        ),
      ),
    );
  }
}
