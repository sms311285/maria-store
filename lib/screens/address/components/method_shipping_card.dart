import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:provider/provider.dart';

class MethodShippingCard extends StatelessWidget {
  const MethodShippingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<CartManager>(
          builder: (_, cartManager, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownSearch<String>(
                  // Customização do campo pesquisa e itens dentro do drop
                  popupProps: PopupProps.menu(
                    // customização dos itens dentro do drop
                    itemBuilder: (context, item, isSelected) {
                      final isCurrentlySelected = cartManager.selectedOptionShipping == item;
                      return ListTile(
                        leading: Icon(
                          item == 'Entrega' ? Icons.local_shipping : Icons.directions_run,
                          color: isCurrentlySelected ? primaryColor : Colors.grey,
                        ),
                        title: Text(item),
                        selected: isCurrentlySelected,
                      );
                    },
                  ),

                  //  Customizando o dropdown após a seleção
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText:
                          cartManager.selectedOptionShipping == null ? 'Selecione a Forma de Envio' : 'Forma de Envio:',
                      labelStyle: TextStyle(
                        color: cartManager.selectedOptionShipping == null ? Colors.grey : primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icon(
                        cartManager.selectedOptionShipping == 'Retirada' ? Icons.directions_run : Icons.local_shipping,
                        size: 25,
                        color: cartManager.selectedOptionShipping == null ? Colors.grey : primaryColor,
                      ),
                      suffixIconColor: cartManager.selectedOptionShipping == null ? Colors.grey : primaryColor,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: cartManager.selectedOptionShipping == null ? Colors.grey : primaryColor,
                        ),
                      ),
                    ),
                  ),
                  items: const ['Entrega', 'Retirada'],
                  itemAsString: (item) => item,
                  selectedItem: cartManager.selectedOptionShipping,
                  onChanged: (value) {
                    if (value != null) {
                      cartManager.setSelectedOptionShipping(value);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
