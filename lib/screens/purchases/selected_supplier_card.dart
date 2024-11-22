import 'package:flutter/material.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';

class SelectedSupplierCard extends StatelessWidget {
  const SelectedSupplierCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Pegando a lista de fornecedores do AdminSuppliersManager
    final supplierList = context.watch<AdminSuppliersManager>().suppliers;

    // Controlador para a pesquisa de fornecedores
    TextEditingController searchSupplierController = TextEditingController();

    // cor padrão
    final Color primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<BagManager>(
          builder: (_, bagManager, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      // DropdownSearch com funcionalidade de pesquisa
                      child: DropdownSearch<SupplierApp>(
                        // Customização do campo pesquisa e itens dentro do drop
                        popupProps: PopupProps.menu(
                          showSelectedItems: true, // Mostrar itens selecionados
                          showSearchBox: true, // Exibir caixa de pesquisa
                          // Customização do campo pesquisa dentro do drop
                          searchFieldProps: TextFieldProps(
                            controller: searchSupplierController, // Controlador de pesquisa
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              labelText: "Pesquisar...",
                              hintText: "Digite para pesquisar...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchSupplierController.clear(); // Limpar o campo de pesquisa
                                },
                              ),
                            ),
                          ),

                          // customização dos itens dentro do drop
                          itemBuilder: (context, item, isSelected) {
                            final isCurrentlySelected = bagManager.selectedSupplier == item;
                            return ListTile(
                              leading: Icon(
                                Icons.business,
                                color: isCurrentlySelected ? primaryColor : Colors.grey,
                              ),
                              title: Text(item.name!),
                              selected: isCurrentlySelected,
                            );
                          },
                        ),

                        // Customizando o dropdown após a seleção
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: bagManager.selectedSupplier == null ? "Selecione o Fornecedor" : "Fornecedor:",
                            labelStyle: TextStyle(
                              color: bagManager.selectedSupplier == null ? Colors.grey : primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: Icon(
                              Icons.business,
                              size: 25,
                              color: bagManager.selectedSupplier == null ? Colors.grey : primaryColor,
                            ),
                            suffixIconColor: bagManager.selectedSupplier == null ? Colors.grey : primaryColor,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: bagManager.selectedSupplier == null ? Colors.grey : primaryColor,
                              ),
                            ),
                          ),
                        ),

                        // Lista de fornecedores
                        items: supplierList,
                        // Texto exibido para cada item
                        itemAsString: (SupplierApp supplier) => supplier.name ?? '',
                        // Função de comparação
                        compareFn: (SupplierApp a, SupplierApp b) => a.id == b.id,
                        // Fornecedor selecionado
                        selectedItem: bagManager.selectedSupplier,
                        // Setando o item selecionado
                        onChanged: (SupplierApp? selectedSupplier) => bagManager.setSelectedSupplier(selectedSupplier),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
