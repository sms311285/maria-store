import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/models/account_receive/account_receive_model.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/screens/account_receive/components/account_receive_information_tile.dart';
import 'package:provider/provider.dart';

class AccountReceiveTile extends StatelessWidget {
  const AccountReceiveTile({
    super.key,
    required this.accountReceiveModel,
    this.showControls = false,
  });

  // obtendo os pedidos
  final AccountReceiveModel accountReceiveModel;

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
                  DateFormat('dd/MM/yyyy ').format(accountReceiveModel.date!.toDate()), //HH:mm
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                // numero do pedido
                Text(
                  accountReceiveModel.formattedId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),

                // valor pedido
                Text(
                  'R\$ ${accountReceiveModel.priceTotal?.toStringAsFixed(2).replaceAll('.', ',')}',
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
              accountReceiveModel.statusText,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                // alterando a cor do texto quando o pedido estiver cancelado
                color: accountReceiveModel.statusAccountReceive == StatusAccountReceive.canceled
                    ? Colors.red
                    : primaryColor,
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
                        builder: (_) => AccountReceiveInformationTile(
                          accountReceiveModel: accountReceiveModel,
                          pageManager: pageManager, // envia o pagManager para o AccountReceiveInformationTile
                        ),
                      );
                    },
                  ),
                  // Outros botões - exibidos apenas se showControls for true, operador de cascata para montar a lista
                  if (showControls && accountReceiveModel.statusAccountReceive != StatusAccountReceive.canceled) ...[
                    const SizedBox(width: 7),
                    // se o status for pago, esconder btn Pagar
                    if (accountReceiveModel.statusAccountReceive != StatusAccountReceive.paid)
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
                        label: const Text('Receber'),
                        onPressed: () {
                          accountReceiveModel.receive(accountReceiveModel.id!);
                        },
                      ),
                    const SizedBox(width: 7),
                    // se o status for pendente, esconder btn Pendente
                    if (accountReceiveModel.statusAccountReceive != StatusAccountReceive.pending &&
                        accountReceiveModel.statusAccountReceive != StatusAccountReceive.postponed)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          // padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(
                          Icons.monetization_on,
                          size: 16,
                        ),
                        label: const Text('Pendente'),
                        onPressed: () {
                          accountReceiveModel.pending(accountReceiveModel.id!);
                        },
                      ),
                    const SizedBox(width: 7),
                    if (accountReceiveModel.statusAccountReceive != StatusAccountReceive.paid)
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
                            initialDate: accountReceiveModel.dueDate!.toDate(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          accountReceiveModel.postponed(pickedDate!, accountReceiveModel.id!);
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
