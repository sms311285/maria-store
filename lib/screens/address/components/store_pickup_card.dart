import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/stores/stores_manager.dart';
import 'package:maria_store/models/stores/stores_model.dart';
import 'package:provider/provider.dart';

class StorePickupCard extends StatefulWidget {
  const StorePickupCard({super.key});

  @override
  State<StorePickupCard> createState() => _StorePickupCardState();
}

class _StorePickupCardState extends State<StorePickupCard> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    final stores = context.watch<StoresManager>().stores;

    return Consumer<CartManager>(
      builder: (_, cartManager, __) {
        if (cartManager.selectedStore != null && !isEditing) {
          // Exibe a loja selecionada com endereço e botão para editar
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Local de Retirada:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${cartManager.selectedStore!.name}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CustomIconButton(
                        iconData: Icons.edit,
                        color: primaryColor,
                        size: 25,
                        onTap: () {
                          setState(() {
                            isEditing = true;
                            cartManager.setSelectedStore(null);
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    cartManager.selectedStore!.addressText,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Exibe o widget para selecionar a loja
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Dropdown para selecionar a loja
                  DropdownSearch<StoresModel>(
                    popupProps: PopupProps.menu(
                      itemBuilder: (context, item, isSelected) {
                        final isCurrentlySelected = cartManager.selectedStore == item;
                        return ListTile(
                          leading: Icon(
                            Icons.store,
                            color: primaryColor,
                          ),
                          title: Text(item.name!),
                          selected: isCurrentlySelected,
                        );
                      },
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: cartManager.selectedStore == null ? "Selecione a Loja" : "Loja:",
                        labelStyle: TextStyle(
                          color: cartManager.selectedStore == null ? Colors.grey : primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        prefixIcon: Icon(
                          Icons.store,
                          size: 25,
                          color: cartManager.selectedStore == null ? Colors.grey : primaryColor,
                        ),
                        suffixIconColor: cartManager.selectedStore == null ? Colors.grey : primaryColor,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: cartManager.selectedStore == null ? Colors.grey : primaryColor,
                          ),
                        ),
                      ),
                    ),
                    items: stores,
                    itemAsString: (StoresModel stores) => stores.name ?? '',
                    compareFn: (StoresModel a, StoresModel b) => a.id == b.id, // Função de comparação
                    selectedItem: cartManager.selectedStore,
                    onChanged: (StoresModel? store) {
                      cartManager.setSelectedStore(store);
                      setState(() {
                        isEditing = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
