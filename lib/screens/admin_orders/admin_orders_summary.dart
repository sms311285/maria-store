import 'package:flutter/material.dart';
import 'package:maria_store/models/admin_orders/admin_orders_manager.dart';

class AdminOrdersSummary extends StatelessWidget {
  const AdminOrdersSummary({
    super.key,
    required this.adminOrdersManager,
  });

  final AdminOrdersManager adminOrdersManager;

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
                      icon: Icons.production_quantity_limits,
                      label: 'Total Produtos',
                      value: adminOrdersManager
                          .calculateTotalProducts(adminOrdersManager.filteredOrders)
                          .toStringAsFixed(2)
                          .replaceAll('.', ','),
                    ),
                    _buildSummaryItem(
                      icon: Icons.local_shipping_outlined,
                      label: 'Total Fretes',
                      value: adminOrdersManager
                          .calculateTotalDelivery(adminOrdersManager.filteredOrders)
                          .toStringAsFixed(2)
                          .replaceAll('.', ','),
                    ),
                    _buildSummaryItem(
                      icon: Icons.attach_money_outlined,
                      label: 'Total Pedidos',
                      value: adminOrdersManager
                          .calculateTotalOrder(adminOrdersManager.filteredOrders)
                          .toStringAsFixed(2)
                          .replaceAll('.', ','),
                    ),
                  ],
                ),

                // Coluna à direita
                _buildColumn(
                  [
                    _buildSummaryItem(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Qtde Produtos',
                      value: adminOrdersManager.calculateQuantityProducts(adminOrdersManager.filteredOrders).toString(),
                    ),
                    _buildSummaryItem(
                      icon: Icons.list_outlined,
                      label: 'Qtde Itens',
                      value: adminOrdersManager
                          .calculateQuantityItems(
                            adminOrdersManager.filteredOrders,
                          )
                          .toString(),
                    ),
                    _buildSummaryItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Qtde Pedidos',
                      value: adminOrdersManager.calculateQuantityOrders(adminOrdersManager.filteredOrders).toString(),
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