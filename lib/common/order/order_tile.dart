import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/common/order/export_address_dialog.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/common/order/order_information_tile.dart';
import 'package:maria_store/common/order/order_product_tile.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:provider/provider.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.order,
    // se não passar nenhum parametro recece false
    this.showControls = false,
  });

  // obtendo os pedidos
  final OrderModel order;

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
                  DateFormat('dd/MM/yyyy ').format(order.date!.toDate()), //HH:mm
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                // numero do pedido
                Text(
                  order.formattedId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),

                // valor pedido
                Text(
                  'R\$ ${order.priceProducts?.toStringAsFixed(2).replaceAll('.', ',')}',
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
              order.statusText,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                // alterando a cor do texto quando o pedido estiver cancelado
                color: order.statusOrder == StatusOrder.canceled ? Colors.red : primaryColor,
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
                children: order.items!.map(
                  (e) {
                    return OrderProductTile(
                      cartProduct: e,
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
                            builder: (_) => OrderInformationTile(
                              order: order,
                              pageManager: pageManager,
                            ),
                          );
                        },
                      ),

                      // Outros botões - exibidos apenas se showControls for true, operador de cascata para montar a lista
                      if (showControls && order.statusOrder != StatusOrder.canceled) ...[
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
                                  title: 'Cancelar o pedido "${order.formattedId}"...',
                                  content: Text('Deseja realmente cancelar o pedido "${order.formattedId}"?'),
                                  confirmText: 'Cancelar',
                                  cancelText: 'Fechar',
                                  onConfirm: () {
                                    order.cancel(context);
                                    Navigator.of(context).pop();
                                  },
                                  onCancel: () => Navigator.of(context).pop(),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(width: 7),

                        // btn recuar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: primaryColor.withAlpha(100),
                            // padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 16,
                          ),
                          label: const Text('Voltar'),
                          onPressed: order.back,
                        ),

                        const SizedBox(width: 7),

                        // btn avançar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: primaryColor.withAlpha(100),
                            //padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 16,
                          ),
                          label: const Text('Avançar'),
                          onPressed: order.advance,
                        ),

                        const SizedBox(width: 7),

                        // verificando que se o pedido for retirada, ocultar o botão endereço
                        if (order.isDelivery != false)
                          // btn endereço
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              // padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(
                              Icons.location_on,
                              size: 16,
                            ),
                            label: const Text('Endereço'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ExportAddressDialog(
                                  address: order.address!,
                                  orderModel: order,
                                ),
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