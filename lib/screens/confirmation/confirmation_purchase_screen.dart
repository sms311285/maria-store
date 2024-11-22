import 'package:flutter/material.dart';
import 'package:maria_store/common/purchase/purchase_product_tile.dart';
import 'package:maria_store/models/purchase/purchase_model.dart';

class ConfirmationPurchaseScreen extends StatelessWidget {
  const ConfirmationPurchaseScreen({super.key, required this.purchase});

  final PurchaseModel purchase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compra ${purchase.formattedId} Confirmada...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: ListView(
            // para ocupar o maior espaço da tela e a lista não ser infinita
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      purchase.formattedId,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'R\$ ${purchase.priceTotal?.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: purchase.items!.map((e) {
                  return PurchaseProductTile(bagProduct: e);
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
