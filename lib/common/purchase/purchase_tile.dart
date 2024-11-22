import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/common/purchase/purchase_information_tile.dart';
import 'package:maria_store/common/purchase/purchase_product_tile.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/models/purchase/purchase_model.dart';
import 'package:provider/provider.dart';

class PurchaseTile extends StatelessWidget {
  const PurchaseTile({
    super.key,
    required this.purchase,
    // se não passar nenhum parametro recece false
    this.showControls = false,
  });

  // obtendo os pedidos
  final PurchaseModel purchase;

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
                  DateFormat('dd/MM/yyyy ').format(purchase.date!.toDate()), //HH:mm
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                // numero do pedido
                Text(
                  purchase.formattedId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),

                // valor pedido
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

            // status
            Text(
              purchase.statusText,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                // alterando a cor do texto quando o pedido estiver cancelado
                color: purchase.statusPurchase == StatusPurchase.canceled ? Colors.red : primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),

        // itens do pedido
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                // cada um dos itens do pedido e mapeando cada item em um widget
                children: purchase.items!.map(
                  (e) {
                    return PurchaseProductTile(
                      bagProduct: e,
                    );
                  },
                ).toList(),
              ),

              // botões controladores de pedido
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
                            builder: (_) => PurchaseInformationTile(
                              purchase: purchase,
                              pageManager: pageManager,
                            ),
                          );
                        },
                      ),

                      // Outros botões - exibidos apenas se showControls for true, operador de cascata para montar a lista
                      if (showControls && purchase.statusPurchase != StatusPurchase.canceled) ...[
                        const SizedBox(width: 7),
                        if (purchase.statusPurchase != StatusPurchase.confirmed)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              // padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(
                              Icons.check,
                              size: 16,
                            ),
                            label: const Text('Confirmar'),
                            onPressed: () async {
                              purchase.confirm();
                            },
                          ),

                        const SizedBox(width: 7),

                        if (purchase.statusPurchase != StatusPurchase.pending)
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
                              purchase.pending();
                            },
                          ),

                        const SizedBox(width: 7),
                        // btn cancelar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            // padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(
                            Icons.cancel,
                            size: 16,
                          ),
                          label: const Text('Cancelar'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return CustomDialog(
                                  title: 'Cancelar a compra "${purchase.formattedId}"...',
                                  content: Text('Deseja realmente cancelar a compra "${purchase.formattedId}"?'),
                                  confirmText: 'Cancelar',
                                  cancelText: 'Fechar',
                                  onConfirm: () {
                                    purchase.cancel(context);
                                    Navigator.of(context).pop();
                                  },
                                  onCancel: () => Navigator.of(context).pop(),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
