import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/models/account_pay/account_pay_model.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/screens/account_pay/components/account_pay_information_tile.dart';
import 'package:provider/provider.dart';

class AccountPayTile extends StatelessWidget {
  const AccountPayTile({
    super.key,
    required this.accountPayModel,
    this.showControls = false,
  });

  // obtendo os pedidos
  final AccountPayModel accountPayModel;

  // variavel para controlar a exibição dos botões coontroladores de status
  final bool showControls;

  @override
  Widget build(BuildContext context) {
    // obtendo a cor padrão
    final primaryColor = Theme.of(context).primaryColor;

    // obtendo o PageManager para conseguir clicar na conta e ir para tela compra especifica dentro de uma dialog
    final pageManager = context.read<PageManager>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        // Remove as linhas do ExpansionTile (borders) ao expandir/colapsar o tile
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // data do pedido
                Text(
                  DateFormat('dd/MM/yyyy ').format(accountPayModel.date!.toDate()), //HH:mm
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                // numero do pedido
                Text(
                  accountPayModel.formattedId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),

                // valor pedido
                Text(
                  'R\$ ${accountPayModel.priceTotal?.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // status
            Text(
              accountPayModel.statusText,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                // alterando a cor do texto quando o pedido estiver cancelado
                color: accountPayModel.statusAccountPay == StatusAccountPay.canceled ? Colors.red : primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),

        // itens do pedido
        children: <Widget>[
          SizedBox(
            height: 45, // 50 oroginal
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  // btn resumo
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      // padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(
                      Icons.receipt_long,
                      size: 16,
                    ),
                    label: const Text('Resumo'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AccountPayInformationTile(
                          accountPayModel: accountPayModel,
                          pageManager: pageManager, // envia o pagManager para o AccountPayInformationTile
                        ),
                      );
                    },
                  ),
                  // Outros botões - exibidos apenas se showControls for true, operador de cascata para montar a lista
                  if (showControls && accountPayModel.statusAccountPay != StatusAccountPay.canceled) ...[
                    const SizedBox(width: 7),
                    // se o status for pago, esconder btn Pagar
                    if (accountPayModel.statusAccountPay != StatusAccountPay.paid)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          // padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(
                          Icons.monetization_on,
                          size: 16,
                        ),
                        label: const Text('Pagar'),
                        onPressed: () async {
                          accountPayModel.pay(accountPayModel.id!);
                        },
                      ),
                    const SizedBox(width: 7),
                    // se o status for pendente, esconder btn Pendente
                    if (accountPayModel.statusAccountPay != StatusAccountPay.pending &&
                        accountPayModel.statusAccountPay != StatusAccountPay.postponed)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          // padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(
                          Icons.pending_actions,
                          size: 16,
                        ),
                        label: const Text('Pendente'),
                        onPressed: () async {
                          accountPayModel.pending(accountPayModel.id!);
                        },
                      ),
                    const SizedBox(width: 7),
                    if (accountPayModel.statusAccountPay != StatusAccountPay.paid)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          // padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(
                          Icons.arrow_circle_right,
                          size: 16,
                        ),
                        label: const Text('Adiar'),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: accountPayModel.dueDate!.toDate(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          accountPayModel.postponed(pickedDate!, accountPayModel.id!);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
