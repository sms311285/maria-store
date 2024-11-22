import 'package:flutter/material.dart';
import 'package:maria_store/common/order/price_card.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/screens/address/components/address_card.dart';
import 'package:maria_store/screens/address/components/installments_card.dart';
import 'package:maria_store/screens/address/components/method_shipping_card.dart';
import 'package:maria_store/screens/address/components/store_pickup_card.dart';
import 'package:maria_store/common/commons/list_widget_selection.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Entrega',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // rolar a tela
      body: Consumer2<CartManager, PaymentMethodManager>(
        builder: (_, cartManager, paymentMethodManager, __) {
          final paymentMethod = paymentMethodManager.allPaymentMethod;
          return ListView(
            children: <Widget>[
              // card forma de envio
              const MethodShippingCard(),
              // verifica se é entrega
              if (cartManager.selectedOptionShipping == 'Entrega')
                // mostra card de endereço
                const AddressCard()
              else if (cartManager.selectedOptionShipping == 'Retirada')
                // mostra card de selecionar local de retirada
                const StorePickupCard(),

              if (cartManager.selectedOptionShipping == 'Entrega' || cartManager.selectedStore != null)
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, index) => const SizedBox(width: 10),
                    itemCount: paymentMethod.length,
                    itemBuilder: (_, index) {
                      final paymentMethods = paymentMethod[index];
                      return ListWidgetSelection(
                        image: paymentMethods.image,
                        category: paymentMethods.name!,
                        isSelected: paymentMethods == cartManager.selectedPaymentMethod,
                        isSale: true,
                        onPressed: () {
                          cartManager.togglePaymentMethodOrder(paymentMethods);
                        },
                      );
                    },
                  ),
                ),

              // Exibe o card de parcelas se houver opções de parcelas disponíveis em alguma forma de pagamento
              if (cartManager.selectedPaymentMethodInstallments != null &&
                  cartManager.selectedPaymentMethodInstallments! > 1)
                InstallmentsCard(
                  installments: cartManager.selectedPaymentMethodInstallments!,
                  totalPrice: cartManager.totalPrice,
                  isSale: true,
                ),

              PriceCard(
                buttonText: 'Continuar para Pagamento',
                // verificando se a forma de envio e pagamento estão selecionadas e se há parcelas, quando necessário
                onPressed: (cartManager.selectedOptionShipping == 'Entrega' &&
                            cartManager.isAddressValid &&
                            cartManager.selectedPaymentMethod != null &&
                            // Se a forma de pagamento tiver parcelas, verificar se alguma parcela foi selecionada
                            (cartManager.selectedPaymentMethod!.installmentsOrder == 0 ||
                                cartManager.selectedInstallmentOrder != null)) ||
                        (cartManager.selectedStore != null &&
                            cartManager.selectedPaymentMethod != null &&
                            (cartManager.selectedPaymentMethod!.installmentsOrder == 0 ||
                                cartManager.selectedInstallmentOrder != null))
                    ? () {
                        Navigator.of(context).pushNamed('/checkout');
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
