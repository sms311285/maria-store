import 'package:flutter/material.dart';
import 'package:maria_store/common/purchase/price_purchase_card.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/screens/address/components/installments_card.dart';
import 'package:maria_store/common/commons/list_widget_selection.dart';
import 'package:maria_store/screens/purchases/number_days_card.dart';
import 'package:maria_store/screens/purchases/selected_supplier_card.dart';
import 'package:provider/provider.dart';

class FinishPurchaseScreen extends StatelessWidget {
  const FinishPurchaseScreen({super.key, required this.isSale});

  final bool isSale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finalizar Compra',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // rolar a tela
      body: Consumer2<BagManager, PaymentMethodManager>(
        builder: (_, bagManager, paymentMethodManager, __) {
          final paymentMethod = paymentMethodManager.allPaymentMethod;
          return ListView(
            children: <Widget>[
              const SelectedSupplierCard(),
              if (bagManager.selectedSupplier != null)
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
                        isSelected: paymentMethods == bagManager.selectedPaymentMethod,
                        isSale: false,
                        onPressed: () {
                          bagManager.togglePaymentMethodPurchase(paymentMethods);
                        },
                      );
                    },
                  ),
                ),

              // verificar se parcela está selecionada
              if (bagManager.selectedPaymentMethodInstallments != null &&
                  bagManager.selectedPaymentMethodInstallments! > 0)
                InstallmentsCard(
                  installments: bagManager.selectedPaymentMethodInstallments!,
                  totalPrice: bagManager.totalPrice,
                  isSale: false,
                ),

              if (bagManager.selectedInstallmentPurchase != null && bagManager.selectedInstallmentPurchase != 0)
                const NumberDaysCard(
                  isSale: false,
                ),

              // resumo da compra
              PricePurchaseCard(
                buttonText: 'Continuar para Pagamento',
                // verificando se o card é valido e se o forma de envio está selecionada e se alguma forma de pgto está selecionada para habilitar o botão
                onPressed: (bagManager.selectedPaymentMethod != null &&
                            bagManager.selectedSupplier != null &&
                            bagManager.selectedDays != null &&
                            (bagManager.selectedPaymentMethod!.installmentsPurchase == 0 ||
                                bagManager.selectedInstallmentPurchase != null)) ||
                        (bagManager.selectedPaymentMethod != null &&
                            (bagManager.selectedPaymentMethod!.installmentsPurchase == 0 ||
                                bagManager.selectedInstallmentPurchase != null && bagManager.selectedDays != null))
                    ? () {
                        Navigator.of(context).pushNamed('/checkout_purchase');
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
