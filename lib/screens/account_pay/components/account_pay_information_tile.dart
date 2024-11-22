import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/bottom_sheet_whatsapp_phone.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/account_pay/account_pay_model.dart';
import 'package:maria_store/models/admin_purchases/admin_purchases_manager.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:provider/provider.dart';

class AccountPayInformationTile extends StatelessWidget {
  const AccountPayInformationTile({
    super.key,
    required this.accountPayModel,
    required this.pageManager,
  });

  // recebendo os objetos do order
  final AccountPayModel accountPayModel;

  // recebendo o pageManager para poder navegar para tela de compra
  final PageManager pageManager;

  @override
  Widget build(BuildContext context) {
    // obtendo os dados do user atraves do userId que está no order passando por parametro
    final supplier = context.watch<AdminSuppliersManager>().findSupplierById(accountPayModel.supplier ?? "");

    final paymentMethod =
        context.watch<PaymentMethodManager>().findPaymentMethodById(accountPayModel.paymentMethod ?? "");

    return CustomDialog(
      title: 'Resumo da Conta ${accountPayModel.formattedId}...',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Emissão:',
              value: DateFormat('dd/MM/yyyy').format(accountPayModel.date!.toDate()),
            ),

            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => BottomSheetWhatsappPhone(
                    phoneNumber: supplier?.phone ?? '',
                  ),
                );
              },
              child: _buildInfoRow(
                context,
                icon: Icons.business,
                label: 'Fornecedor:',
                value: '${supplier?.name}',
                trailingIcon: Icons.phone,
              ),
            ),

            // Duplicata
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AdminPurchasesManager>().setPurchaseIdFilter(accountPayModel.purchaseId);
                // pegando o pegaManager e passando a pagina
                pageManager.setPage(12);
              },
              child: _buildInfoRow(
                context,
                icon: Icons.receipt,
                label: 'Compra:',
                value: '${accountPayModel.purchaseId}',
                trailingIcon: Icons.visibility,
              ),
            ),

            _buildInfoRow(
              context,
              icon: Icons.warning,
              label: 'Status:',
              value: accountPayModel.statusAccountPay == StatusAccountPay.paid
                  ? 'Pago'
                  : accountPayModel.statusAccountPay == StatusAccountPay.canceled
                      ? 'Cancelado'
                      : accountPayModel.dueDate!.toDate().isAfter(DateTime.now())
                          ? 'Dentro do Vencimento'
                          : 'Vencido',
            ),

            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Vencimento:',
              value: DateFormat('dd/MM/yyyy').format(accountPayModel.dueDate!.toDate()),
            ),

            // Valor dos produtos
            _buildInfoRow(
              context,
              icon: Icons.shopping_bag,
              label: 'Valor Total:',
              value: 'R\$ ${accountPayModel.priceTotal?.toStringAsFixed(2).replaceAll('.', ',')}',
            ),

            // Forma de pagamento
            _buildInfoRow(
              context,
              icon: Icons.payment,
              label: 'Forma de Pagamento:',
              value: paymentMethod!.name!,
            ),

            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Pagamento:',
              // verificando pois a data de pagamento pode ser nula
              value: accountPayModel.datePay != null
                  ? DateFormat('dd/MM/yyyy').format(accountPayModel.datePay!.toDate())
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
