import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/admin_purchases/admin_purchases_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/item_size/item_size_manager.dart';
import 'package:maria_store/models/product/product_manager.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';
import 'package:provider/provider.dart';

class AdminFilterPurchases extends StatelessWidget {
  const AdminFilterPurchases({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchMethodPaymentController = TextEditingController();
    TextEditingController searchPurchaseIdController = TextEditingController();
    TextEditingController searchSizeController = TextEditingController();
    TextEditingController searchSupplierController = TextEditingController();
    TextEditingController searchProductController = TextEditingController();

    return Consumer<AdminPurchasesManager>(
      builder: (_, adminPurchasesManager, __) {
        final Color primaryColor = Theme.of(context).primaryColor;

        final paymentMethodList = context.watch<PaymentMethodManager>().allPaymentMethod;
        final sizeList = context.watch<ItemSizeManager>().sizes;
        final productList = context.watch<ProductManager>().allProducts;
        final supplierList = context.watch<AdminSuppliersManager>().suppliers;

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  // data inicial
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Exibe o DatePicker quando o campo for clicado
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: adminPurchasesManager.startDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          adminPurchasesManager.setStartDate(pickedDate);
                        }
                      },
                      // Evita que o DropdownSearch abra o dropdown quando o campo for clicado
                      child: AbsorbPointer(
                        child: DropdownSearch<DateTime>(
                          popupProps: const PopupProps.menu(
                            showSearchBox: false, // Desabilita a caixa de pesquisa
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Data Inicial',
                              labelStyle: TextStyle(
                                color: adminPurchasesManager.startDate != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: adminPurchasesManager.startDate != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: adminPurchasesManager.startDate != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: adminPurchasesManager.startDate != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: adminPurchasesManager.startDate,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            adminPurchasesManager.setStartDate(selectedDate);
                          },
                        ),
                      ),
                    ),
                  ),

                  // espaço horizontal entre os campos
                  const SizedBox(width: 20),

                  // data final
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Exibe o DatePicker quando o campo for clicado
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: adminPurchasesManager.endDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          adminPurchasesManager.setEndDate(pickedDate);
                        }
                      },
                      // Evita que o DropdownSearch abra o dropdown quando o campo for clicado
                      child: AbsorbPointer(
                        child: DropdownSearch<DateTime>(
                          popupProps: const PopupProps.menu(
                            showSearchBox: false, // Desabilita a caixa de pesquisa
                          ),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Data Final',
                              labelStyle: TextStyle(
                                color: adminPurchasesManager.endDate != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: adminPurchasesManager.endDate != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: adminPurchasesManager.endDate != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: adminPurchasesManager.endDate != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: adminPurchasesManager.endDate,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            adminPurchasesManager.setEndDate(selectedDate);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // forma de pgto
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: DropdownSearch<PaymentMethodModel>(
                      popupProps: PopupProps.menu(
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          controller: searchMethodPaymentController,
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
                                searchMethodPaymentController.clear();
                                adminPurchasesManager.setPaymentMethodFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminPurchasesManager.paymentMethodFilter == item;
                          return ListTile(
                            leading: Icon(
                              Icons.attach_money_outlined,
                              color: isCurrentlySelected ? primaryColor : Colors.grey,
                            ),
                            title: Text(item.name!),
                            selected: isCurrentlySelected,
                          );
                        },
                      ),

                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Forma de Pagamento',
                          labelStyle: TextStyle(
                            color: adminPurchasesManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            size: 20,
                            color: adminPurchasesManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIconColor:
                              adminPurchasesManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminPurchasesManager.paymentMethodFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      items: paymentMethodList, // Lista de métodos de pagamento
                      itemAsString: (PaymentMethodModel? method) => method?.name ?? '',
                      compareFn: (PaymentMethodModel a, PaymentMethodModel b) => a.id == b.id, // Função de comparação
                      selectedItem: adminPurchasesManager.paymentMethodFilter, // Forma de pagamento selecionada
                      onChanged: (PaymentMethodModel? selectedMethod) {
                        adminPurchasesManager.setPaymentMethodFilter(selectedMethod);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // id da conta
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          controller: searchPurchaseIdController,
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
                                searchPurchaseIdController.clear();
                                adminPurchasesManager.setPurchaseIdFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminPurchasesManager.purchaseIdFilter == item;
                          return ListTile(
                            leading: Icon(
                              Icons.numbers,
                              color: isCurrentlySelected ? primaryColor : Colors.grey,
                            ),
                            title: Text(item), // Exibe o ID da duplicata
                            selected: isCurrentlySelected,
                          );
                        },
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'ID da Compra',
                          labelStyle: TextStyle(
                            color: adminPurchasesManager.purchaseIdFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.numbers,
                            size: 20,
                            color: adminPurchasesManager.purchaseIdFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIcon: const Icon(
                            Icons.numbers,
                          ),
                          suffixIconColor: adminPurchasesManager.purchaseIdFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminPurchasesManager.purchaseIdFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Converter IDs para lista de String
                      items: adminPurchasesManager.filterPurchases.map((e) => e.purchaseId!).toList(),
                      selectedItem: adminPurchasesManager.purchaseIdFilter, // Selecionar o item atual
                      onChanged: (String? selectedAccount) {
                        if (selectedAccount != null) {
                          adminPurchasesManager.setPurchaseIdFilter(selectedAccount);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // forma de envio e tamanho
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          controller: searchSizeController,
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
                                searchSizeController.clear();
                                adminPurchasesManager.setSizeFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminPurchasesManager.sizeFilter == item;
                          return ListTile(
                            leading: Icon(
                              Icons.format_size,
                              color: isCurrentlySelected ? primaryColor : Colors.grey,
                            ),
                            title: Text(item),
                            selected: isCurrentlySelected,
                          );
                        },
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Tamanho',
                          labelStyle: TextStyle(
                            color: adminPurchasesManager.sizeFilter != null ? primaryColor : Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.format_size,
                            size: 20,
                            color: adminPurchasesManager.sizeFilter != null ? primaryColor : Colors.grey,
                          ),
                          suffixIconColor: adminPurchasesManager.sizeFilter != null ? primaryColor : Colors.grey,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminPurchasesManager.sizeFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // transformando o objeto sizeList em string
                      items: sizeList.map((s) => s.name!).toList(),
                      selectedItem: adminPurchasesManager.sizeFilter, // Tamanho selecionado atualmente
                      onChanged: (String? selectedSize) {
                        if (selectedSize != null) {
                          // Atualizar o filtro de tamanho
                          adminPurchasesManager.setSizeFilter(selectedSize);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Fornecedor
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownSearch<SupplierApp>(
                        popupProps: PopupProps.menu(
                          showSelectedItems: true,
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            controller: searchSupplierController,
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
                                  searchSupplierController.clear();
                                  adminPurchasesManager.setSupplierFilter(null);
                                },
                              ),
                            ),
                          ),
                          itemBuilder: (context, item, isSelected) {
                            final isCurrentlySelected = adminPurchasesManager.supplierFilter == item;
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
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Fornecedor',
                            labelStyle: TextStyle(
                              color: adminPurchasesManager.supplierFilter != null ? primaryColor : Colors.grey,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.business,
                              size: 20,
                              color: adminPurchasesManager.supplierFilter != null ? primaryColor : Colors.grey,
                            ),
                            suffixIconColor: adminPurchasesManager.supplierFilter != null ? primaryColor : Colors.grey,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: adminPurchasesManager.supplierFilter != null ? primaryColor : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        items: supplierList,
                        itemAsString: (SupplierApp supplier) => supplier.name!,
                        compareFn: (SupplierApp a, SupplierApp b) => a.id == b.id,
                        selectedItem: adminPurchasesManager.supplierFilter,
                        onChanged: (SupplierApp? selectedSupplier) {
                          if (selectedSupplier != null) {
                            adminPurchasesManager.setSupplierFilter(selectedSupplier);
                          }
                        }),
                  ),
                ],
              ),
            ),

            // produto
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          controller: searchProductController,
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
                                searchProductController.clear();
                                adminPurchasesManager.setProductFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminPurchasesManager.productFilter == item;
                          return ListTile(
                            leading: Icon(
                              Icons.inventory,
                              color: isCurrentlySelected ? primaryColor : Colors.grey,
                            ),
                            title: Text(item),
                            selected: isCurrentlySelected,
                          );
                        },
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Produto',
                          labelStyle: TextStyle(
                            color: adminPurchasesManager.productFilter != null ? primaryColor : Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.inventory,
                            size: 20,
                            color: adminPurchasesManager.productFilter != null ? primaryColor : Colors.grey,
                          ),
                          suffixIconColor: adminPurchasesManager.productFilter != null ? primaryColor : Colors.grey,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminPurchasesManager.productFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      items: productList.map((product) => product.name!).toList(),
                      selectedItem: adminPurchasesManager.productFilter,
                      onChanged: (value) {
                        adminPurchasesManager.setProductFilter(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
