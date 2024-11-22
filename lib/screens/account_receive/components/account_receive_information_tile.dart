import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/bottom_sheet_whatsapp_phone.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/account_receive/account_receive_model.dart';
import 'package:maria_store/models/admin_orders/admin_orders_manager.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:provider/provider.dart';

class AccountReceiveInformationTile extends StatelessWidget {
  const AccountReceiveInformationTile({
    super.key,
    required this.accountReceiveModel,
    required this.pageManager,
  });

  // recebendo os objetos do order
  final AccountReceiveModel accountReceiveModel;

  // recebendo o pageManager para poder navegar para tela de compra
  final PageManager pageManager;

  @override
  Widget build(BuildContext context) {
    // obtendo os dados do user atraves do userId que está no order passando por parametro
    final user = context.watch<AdminUsersManager>().findUserById(accountReceiveModel.user ?? "");

    final paymentMethod =
        context.watch<PaymentMethodManager>().findPaymentMethodById(accountReceiveModel.paymentMethod ?? "");

    return CustomDialog(
      title: 'Resumo da Conta ${accountReceiveModel.formattedId}...',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Emissão:',
              value: DateFormat('dd/MM/yyyy').format(accountReceiveModel.date!.toDate()),
            ),
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
                icon: Icons.business,
                label: 'Cliente:',
                value: '${user?.name}',
                trailingIcon: Icons.phone,
              ),
            ),

            // Duplicata
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AdminOrdersManager>().setOrderIdFilter(accountReceiveModel.orderId);
                // pegando o pegaManager e passando a pagina
                pageManager.setPage(11);
              },
              child: _buildInfoRow(
                context,
                icon: Icons.receipt,
                label: 'Venda:',
                value: '${accountReceiveModel.orderId}',
                trailingIcon: Icons.visibility,
              ),
            ),

            _buildInfoRow(
              context,
              icon: Icons.warning,
              label: 'Status:',
              value: accountReceiveModel.statusAccountReceive == StatusAccountReceive.paid
                  ? 'Pago'
                  : accountReceiveModel.statusAccountReceive == StatusAccountReceive.canceled
                      ? 'Cancelado'
                      : accountReceiveModel.dueDate!.toDate().isAfter(DateTime.now())
                          ? 'Dentro do Vencimento'
                          : 'Vencido',
            ),

            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Vencimento:',
              value: DateFormat('dd/MM/yyyy').format(accountReceiveModel.dueDate!.toDate()),
            ),

            // Valor dos produtos
            _buildInfoRow(
              context,
              icon: Icons.shopping_bag,
              label: 'Valor Total:',
              value: 'R\$ ${accountReceiveModel.priceTotal?.toStringAsFixed(2).replaceAll('.', ',')}',
            ),

            // Forma de pagamento
            _buildInfoRow(
              context,
              icon: Icons.payment,
              label: 'Forma de Recebimento:',
              value: paymentMethod!.name!,
            ),

            // parcelas
            if (accountReceiveModel.installments != null)
              _buildInfoRow(
                context,
                icon: Icons.format_list_numbered,
                label: 'Parcelas:',
                value:
                    '${accountReceiveModel.installments}x de R\$ ${(accountReceiveModel.priceTotal! / accountReceiveModel.installments!).toStringAsFixed(2).replaceAll('.', ',')}',
              )
            else
              Container(),

            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Recebimento:',
              // verificando pois a data de pagamento pode ser nula
              value: accountReceiveModel.dateReceive != null
                  ? DateFormat('dd/MM/yyyy').format(accountReceiveModel.dateReceive!.toDate())
                  : 'N/A',
            ),
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
