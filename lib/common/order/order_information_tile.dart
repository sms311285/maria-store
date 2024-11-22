import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/bottom_sheet_whatsapp_phone.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/account_receive/account_receive_manager.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/stores/stores_manager.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';

class OrderInformationTile extends StatelessWidget {
  const OrderInformationTile({
    super.key,
    required this.order,
    required this.pageManager,
  });

  // recebendo os objetos do order
  final OrderModel order;

  // recebendo o pageManager para poder navegar para tela de compra
  final PageManager pageManager;

  @override
  Widget build(BuildContext context) {
    // obtendo os dados do user atraves do userId que está no order passando por parametro
    final user = context.watch<AdminUsersManager>().findUserById(order.userId ?? "");

    final paymentMethod = context.watch<PaymentMethodManager>().findPaymentMethodById(order.paymentMethod ?? "");

    final store = context.watch<StoresManager>().findStoreById(order.storePickup ?? "");

    // função para mostrar uma mensagem de erro
    void showError() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta função não está disponível neste dispositivo'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // abrir o mapa
    Future<void> openMap() async {
      // exceção pois isso pode aprsentar erros
      try {
        // obter os mapas instalados no dispositivo
        final availableMaps = await MapLauncher.installedMaps;

        showModalBottomSheet(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (_) {
            // safe area para ajustar card de abrir o mapa no rodapé
            return SafeArea(
              child: Column(
                // ocupar o minimo tamanho possivel
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // verificando passando por cada item da lista  e exibir os mapas disponíveis
                  for (final map in availableMaps)
                    ListTile(
                      onTap: () {
                        // passando as coordenadas, nome e endereço da loja para o maps ou waze
                        map.showMarker(
                          coords: Coords(store!.address!.lat!, store.address!.long!),
                          title: store.name!,
                          description: store.addressText,
                        );
                        Navigator.of(context).pop();
                      },
                      // nome do app waze o google maps
                      title: Text(map.mapName),
                      // inserindo uma borda com ClipRRect
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                    )
                ],
              ),
            );
          },
        );
      } catch (e) {
        showError();
      }
    }

    return CustomDialog(
      title: 'Resumo do Pedido ${order.formattedId}...',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Emissão:',
              value: DateFormat('dd/MM/yyyy').format(order.date!.toDate()),
            ),

            // somente admin ve essas infos
            Consumer<UserManager>(
              builder: (_, userManager, __) {
                if (userManager.adminEnabled) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => BottomSheetWhatsappPhone(
                              phoneNumber: user?.phone ?? '',
                            ),
                          );
                        },
                        child: _buildInfoRow(
                          context,
                          icon: Icons.person,
                          label: 'Cliente:',
                          value: '${user?.name}',
                          trailingIcon: Icons.phone,
                        ),
                      ),

                      // Duplicata
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // primeiro fechar a dialog para depois navegar
                          Navigator.of(context).pop();
                          context.read<AccountReceiveManager>().setAccountReceiveIdFilter(order.accountReceiveId);
                          // pegando o pegaManager e passando a pagina
                          pageManager.setPage(14);
                        },
                        child: _buildInfoRow(
                          context,
                          icon: Icons.receipt,
                          label: 'Duplicata à Receber:',
                          value: '${order.accountReceiveId}',
                          trailingIcon: Icons.visibility,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
            _buildInfoRow(
              context,
              icon: Icons.warning,
              label: 'Status:',
              value: order.statusText,
            ),

            // Valor dos produtos
            _buildInfoRow(
              context,
              icon: Icons.attach_money,
              label: 'Valor dos Produtos:',
              value: 'R\$ ${order.priceProducts?.toStringAsFixed(2).replaceAll('.', ',')}',
            ),

            // Forma de envio
            _buildInfoRow(
              context,
              icon: Icons.local_shipping,
              label: 'Forma de Envio:',
              value: order.isDelivery! ? 'Entrega' : 'Retirar na Loja',
            ),
            // Valor da entrega ou local da retirada
            if (order.isDelivery!)
              _buildInfoRow(
                context,
                icon: Icons.attach_money,
                label: 'Valor da Entrega:',
                value: 'R\$ ${order.priceDelivery?.toStringAsFixed(2).replaceAll('.', ',')}',
              )
            else
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: openMap,
                child: _buildInfoRow(
                  context,
                  icon: Icons.store,
                  label: 'Local de Retirada:',
                  value: store?.name ?? 'Loja não especificada',
                  trailingIcon: Icons.location_on,
                ),
              ),

            if (order.isDelivery!)
              _buildInfoRow(
                context,
                icon: Icons.location_on,
                label: 'Endereço:',
                value:
                    '${order.address!.street}, ${order.address!.number}, ${order.address!.district}, ${order.address!.city}-${order.address!.state}',
              ),

            // Valor dos produtos
            _buildInfoRow(
              context,
              icon: Icons.attach_money,
              label: 'Valor Total:',
              value: 'R\$ ${order.priceTotal?.toStringAsFixed(2).replaceAll('.', ',')}',
            ),

            // Forma de pagamento
            _buildInfoRow(
              context,
              icon: Icons.payment,
              label: 'Forma de Pagamento:',
              value: paymentMethod!.name!,
            ),

            // parcelas
            if (order.installments != null)
              _buildInfoRow(
                context,
                icon: Icons.format_list_numbered,
                label: 'Parcelas:',
                value:
                    '${order.installments}x de R\$ ${(order.priceTotal! / order.installments!).toStringAsFixed(2).replaceAll('.', ',')}',
              )
            else
              Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    IconData? trailingIcon, // Novo parâmetro opcional para o ícone adicional
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8), // Espaço entre o texto e o ícone
            Icon(
              trailingIcon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
