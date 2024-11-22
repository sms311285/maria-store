import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/stock/stock_model.dart';

class StockMovementTile extends StatelessWidget {
  const StockMovementTile({super.key, required this.movement, required this.product});

  final StockModel movement;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(movement.date!.toDate());

    Icon getIcon(String type, num status) {
      if (status == 1) {
        return Icon(
          type == 'purchase' ? Icons.shopping_bag : Icons.shopping_cart,
          color: Theme.of(context).primaryColor,
          size: 28,
        );
      } else {
        return Icon(
          type == 'purchase' ? Icons.leave_bags_at_home : Icons.remove_shopping_cart_rounded,
          color: Theme.of(context).primaryColor,
          size: 28,
        );
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: ListTile(
          leading: getIcon(movement.type!, movement.status!),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      movement.type == 'purchase'
                          ? Icon(
                              Icons.arrow_circle_right_outlined,
                              size: 15,
                              color: Colors.grey[700],
                            )
                          : Icon(
                              Icons.arrow_circle_left_outlined,
                              size: 15,
                              color: Colors.grey[700],
                            ),
                      const SizedBox(width: 4),
                      Text(
                        movement.type == 'purchase'
                            ? 'Compra: ${movement.purchaseId ?? 'N/A'}'
                            : 'Venda: ${movement.orderId ?? 'N/A'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_month,
                        size: 15,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Data: $dateFormatted',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(),
              const SizedBox(height: 6),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  Icon(
                    Icons.warning_amber,
                    size: 14,
                    color: movement.status != 1 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    movement.status != 1 ? 'Canceldo' : 'Confirmado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.storage,
                    size: 14,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Estoque Atual: ${movement.initialStock}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.production_quantity_limits, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    // Verifica o tipo de movimento e o status para definir o sinal
                    (movement.type == 'purchase' && movement.status != 0) ||
                            (movement.type != 'purchase' && movement.status == 0)
                        ? 'Quantidade: + ${movement.quantity}'
                        : 'Quantidade: - ${movement.quantity}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.inventory, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Estoque após a transação: ${movement.finalStock}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
