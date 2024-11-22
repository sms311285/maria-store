import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:provider/provider.dart';

class InstallmentsCard extends StatelessWidget {
  final int installments;
  final num totalPrice;
  final bool isSale; // Parâmetro para identificar se é venda ou compra

  const InstallmentsCard({
    super.key,
    required this.installments,
    required this.totalPrice,
    required this.isSale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Gerando a lista de parcelas
    List<int> installmentOptions = List.generate(installments, (index) => index + 1);

    // Verifica se é venda (CartManager) ou compra (BagManager)
    final selectedInstallment = isSale
        ? context.watch<CartManager>().selectedInstallmentOrder
        : context.watch<BagManager>().selectedInstallmentPurchase;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // DropdownSearch com funcionalidade de pesquisa
            DropdownSearch<int>(
              popupProps: PopupProps.menu(
                // customização dos itens dentro do drop
                itemBuilder: (context, int? installment, isSelected) {
                  final isCurrentlySelected = selectedInstallment == installment;
                  final num installmentValue = totalPrice / installment!;
                  return ListTile(
                    leading: Icon(
                      Icons.schedule_send,
                      color: isCurrentlySelected ? primaryColor : Colors.grey,
                    ),
                    title: Text(
                      '${installment}x R\$ ${installmentValue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    selected: isCurrentlySelected,
                  );
                },
              ),

              // Customizando o dropdown após a seleção
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: selectedInstallment == null ? "Selecione as Parcelas" : "Parcelas:",
                  labelStyle: TextStyle(
                    color: selectedInstallment == null ? Colors.grey : primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: Icon(
                    Icons.schedule_send,
                    size: 25,
                    color: selectedInstallment == null ? Colors.grey : primaryColor,
                  ),
                  suffixIconColor: selectedInstallment == null ? Colors.grey : primaryColor,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: selectedInstallment == null ? Colors.grey : primaryColor,
                    ),
                  ),
                ),
              ),

              // lista de parcelas
              items: installmentOptions,
              // Texto exibido para cada item
              itemAsString: (int installment) {
                final num installmentValue = totalPrice / installment;
                return '${installment}x R\$ ${installmentValue.toStringAsFixed(2)}';
              },
              // Parcela selecionada
              selectedItem: selectedInstallment,
              // Setando o item selecionado
              onChanged: (int? newValue) {
                // Atualizando o valor no CartManager ou BagManager
                if (isSale) {
                  context.read<CartManager>().setSelectedInstallmentOrder(newValue);
                } else {
                  context.read<BagManager>().setSelectedInstallmentPurchase(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
