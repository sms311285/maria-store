import 'package:flutter/material.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:provider/provider.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({super.key, required this.paymentMethodModel});

  final PaymentMethodModel paymentMethodModel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: paymentMethodModel,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/edit_payment_method', arguments: paymentMethodModel);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${paymentMethodModel.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                // recuperar Icone
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.network(
                    paymentMethodModel.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
