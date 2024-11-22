import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/bottom_sheet_whatsapp_phone.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/account_pay/account_pay_manager.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/purchase/purchase_model.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:provider/provider.dart';

class PurchaseInformationTile extends StatelessWidget {
  const PurchaseInformationTile({
    super.key,
    required this.purchase,
    required this.pageManager,
  });

  // recebendo os objetos do order
  final PurchaseModel purchase;

  // recebendo o pageManager para poder navegar para tela de compra
  final PageManager pageManager;

  @override
  Widget build(BuildContext context) {
    // obtendo os dados do user atraves do userId que está no order passando por parametro
    final supplier = context.watch<AdminSuppliersManager>().findSupplierById(purchase.supplierId ?? "");

    final user = context.watch<AdminUsersManager>().findUserById(purchase.userId ?? "");

    final paymentMethod = context.watch<PaymentMethodManager>().findPaymentMethodById(purchase.paymentMethod ?? "");

    return CustomDialog(
      title: 'Resumo da Compra... ${purchase.formattedId}',
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            _buildInfoRow(
              context,
              icon: Icons.calendar_month,
              label: 'Data Emissão:',
              value: DateFormat('dd/MM/yyyy').format(purchase.date!.toDate()),
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
                icon: Icons.person,
                label: 'Fornecedor:',
                value: '${supplier?.name}',
                trailingIcon: Icons.phone,
              ),
            ),

            // Duplicata
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // primeiro fechar a dialog para depois navegar
                Navigator.of(context).pop();
                context.read<AccountPayManager>().setAccountPayIdFilter(purchase.accountPayId);
                // pegando o pegaManager e passando a pagina
                pageManager.setPage(13);
              },
              child: _buildInfoRow(
                context,
                icon: Icons.receipt,
                label: 'Duplicata à Pagar:',
                value: '${purchase.accountPayId}',
                trailingIcon: Icons.visibility,
              ),
            ),

            _buildInfoRow(
              context,
              icon: Icons.warning,
              label: 'Status:',
              value: purchase.statusText,
            ),

            // Valor dos produtos
            _buildInfoRow(
              context,
              icon: Icons.shopping_bag,
              label: 'Valor Total:',
              value: 'R\$ ${purchase.priceTotal?.toStringAsFixed(2).replaceAll('.', ',')}',
            ),

            // Forma de pagamento
            _buildInfoRow(
              context,
              icon: Icons.payment,
              label: 'Forma de Pagamento:',
              value: paymentMethod!.name!,
            ),

            // parcelas
            if (purchase.installments != null)
              _buildInfoRow(
                context,
                icon: Icons.format_list_numbered,
                label: 'Parcelas:',
                value:
                    '${purchase.installments}x de R\$ ${(purchase.priceTotal! / purchase.installments!).toStringAsFixed(2).replaceAll('.', ',')}',
              )
            else
              Container(),

            // Forma de pagamento
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: 'Admin:',
              value: user!.name!,
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
