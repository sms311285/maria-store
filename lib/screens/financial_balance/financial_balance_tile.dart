import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/models/financial_balance/financial_model.dart';

class FinancialBalanceTile extends StatelessWidget {
  const FinancialBalanceTile({super.key, required this.movement});

  final FinancialModel movement;

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(movement.date!.toDate());

    Icon getIcon(String type, num? status) {
      if (status == 0 || status == 2 || status == 3) {
        // Ícones para contas ativas (a pagar ou a receber)
        return Icon(
          type == 'accountPay' ? Icons.remove_circle : Icons.add_circle,
          color: Theme.of(context).primaryColor,
          size: 28,
        );
      } else {
        // Ícones para contas canceladas
        return Icon(
          type == 'accountPay' ? Icons.bookmark_remove : Icons.bookmark_add,
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
          leading: getIcon(movement.type!, movement.status),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      movement.type == 'accountPay'
                          ? Icon(
                              Icons.arrow_circle_down_outlined,
                              size: 15,
                              color: Colors.grey[700],
                            )
                          : Icon(
                              Icons.arrow_circle_up_outlined,
                              size: 15,
                              color: Colors.grey[700],
                            ),
                      const SizedBox(width: 4),
                      Text(
                        movement.type == 'accountPay'
                            ? 'Pagar: ${movement.accountPayId ?? 'N/A'}'
                            : 'Receber: ${movement.accountReceiveId ?? 'N/A'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.warning_amber,
                    size: 14,
                    color: movement.status == 1
                        ? Colors.red
                        : movement.status == 0
                            ? Colors.orange
                            : movement.status == 2
                                ? Colors.purple
                                : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    //movement.status != 0 ? 'Cancelado' : 'Confirmado',
                    movement.status == 1
                        ? 'Cancelado'
                        : movement.status == 0
                            ? 'Pendente'
                            : movement.status == 2
                                ? 'Adiado'
                                : 'Pago',
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
                  Icon(Icons.safety_check, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Saldo Inicial: R\$ ${movement.initialBalance?.toStringAsFixed(2) ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.attach_money, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    movement.type == 'accountPay' && movement.status != 1
                        ? 'Valor Total: R\$ -${movement.priceTotal?.toStringAsFixed(2) ?? 'N/A'}'
                        : movement.type == 'accountPay'
                            ? 'Valor Total: R\$ +${movement.priceTotal?.toStringAsFixed(2) ?? 'N/A'}'
                            : movement.type == 'accountReceive' && movement.status != 1
                                ? 'Valor Total: R\$ +${movement.priceTotal?.toStringAsFixed(2) ?? 'N/A'}'
                                : movement.type == 'accountReceive'
                                    ? 'Valor Total: R\$ -${movement.priceTotal?.toStringAsFixed(2) ?? 'N/A'}'
                                    : 'N/A',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.check_circle, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Saldo após a transação: R\$ ${movement.finalBalance?.toStringAsFixed(2) ?? 'N/A'}',
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
