import 'package:flutter/material.dart';
import 'package:maria_store/models/account_pay/account_pay_manager.dart';

class AccountPaySummary extends StatelessWidget {
  const AccountPaySummary({
    super.key,
    required this.accountPayManager,
  });

  final AccountPayManager accountPayManager;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 16, left: 16, right: 16),
      color: primaryColor.withOpacity(0.9), // Cor com transparência
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Coluna à esquerda
                _buildColumn(
                  [
                    _buildSummaryItem(
                      icon: Icons.attach_money_outlined,
                      label: 'Valor Total',
                      value: accountPayManager
                          .calculateTotalAccountPay(accountPayManager.filteredAccountPay)
                          .toStringAsFixed(2)
                          .replaceAll('.', ','),
                    ),
                  ],
                ),

                // Coluna à direita
                _buildColumn(
                  [
                    _buildSummaryItem(
                      icon: Icons.copy,
                      label: 'Qtde de Duplicatas',
                      value: accountPayManager
                          .calculateQuantityAccountPay(accountPayManager.filteredAccountPay)
                          .toString(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir um item de resumo (ícone e texto)
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  // Método para criar uma coluna de itens
  Widget _buildColumn(List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
