import 'package:flutter/material.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/screens/payment_mehod/components/payment_method_tile.dart';
import 'package:provider/provider.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Forma de Pagamento',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/edit_payment_method', arguments: PaymentMethodModel());
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Consumer<PaymentMethodManager>(
        builder: (_, paymentMethodManager, __) {
          return ListView(
            children: <Widget>[
              Column(
                // Acessa a lista de todas as foam pgtos
                children: paymentMethodManager.allPaymentMethod
                    // Itera sobre cada foam pgto na lista allPaymentMethod.
                    .map(
                      // Para cada foam pgto, cria um widget PaymentMethodTile, passando a foam pgto atual como parâmetro para o construtor de PaymentMethodTile.
                      (paymentMethodModel) => PaymentMethodTile(
                        paymentMethodModel: paymentMethodModel,
                      ),
                    )
                    // Converte o iterador retornado pelo método map em uma lista de widgets.
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
