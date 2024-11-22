import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/admin_orders/admin_orders_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/item_size/item_size_manager.dart';
import 'package:maria_store/models/product/product_manager.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:provider/provider.dart';

class AdminFilterOrders extends StatelessWidget {
  const AdminFilterOrders({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchMethodPaymentController = TextEditingController();
    TextEditingController searchOrderIdController = TextEditingController();
    TextEditingController searchSizeController = TextEditingController();
    TextEditingController searchUserController = TextEditingController();
    TextEditingController searchProductController = TextEditingController();

    return Consumer<AdminOrdersManager>(
      builder: (_, adminOrdersManager, __) {
        final Color primaryColor = Theme.of(context).primaryColor;

        final sizeList = context.watch<ItemSizeManager>().sizes;
        final userList = context.watch<AdminUsersManager>().users;
        final productList = context.watch<ProductManager>().allProducts;
        final paymentMethodList = context.watch<PaymentMethodManager>().allPaymentMethod;

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  // data emissão inicial
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Exibe o DatePicker quando o campo for clicado
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: adminOrdersManager.startDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          adminOrdersManager.setStartDate(pickedDate);
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
                                color: adminOrdersManager.startDate != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: adminOrdersManager.startDate != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: adminOrdersManager.startDate != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: adminOrdersManager.startDate != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: adminOrdersManager.startDate,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            adminOrdersManager.setStartDate(selectedDate);
                          },
                        ),
                      ),
                    ),
                  ),

                  // espaço horizontal entre os campos
                  const SizedBox(width: 20),

                  // data final emissão
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Exibe o DatePicker quando o campo for clicado
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: adminOrdersManager.endDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          adminOrdersManager.setEndDate(pickedDate);
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
                                color: adminOrdersManager.endDate != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: adminOrdersManager.endDate != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: adminOrdersManager.endDate != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: adminOrdersManager.endDate != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: adminOrdersManager.endDate,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            adminOrdersManager.setEndDate(selectedDate);
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
                                adminOrdersManager.setPaymentMethodFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminOrdersManager.paymentMethodFilter == item;
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
                            color: adminOrdersManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            size: 20,
                            color: adminOrdersManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIconColor: adminOrdersManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminOrdersManager.paymentMethodFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      items: paymentMethodList, // Lista de métodos de pagamento
                      itemAsString: (PaymentMethodModel? method) => method?.name ?? '',
                      compareFn: (PaymentMethodModel a, PaymentMethodModel b) => a.id == b.id, // Função de comparação
                      selectedItem: adminOrdersManager.paymentMethodFilter, // Forma de pagamento selecionada
                      onChanged: (PaymentMethodModel? selectedMethod) {
                        adminOrdersManager.setPaymentMethodFilter(selectedMethod);
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
                          controller: searchOrderIdController,
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
                                searchOrderIdController.clear();
                                adminOrdersManager.setOrderIdFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminOrdersManager.orderIdFilter == item;
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
                          labelText: 'ID do Pedido',
                          labelStyle: TextStyle(
                            color: adminOrdersManager.orderIdFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.numbers,
                            size: 20,
                            color: adminOrdersManager.orderIdFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIcon: const Icon(
                            Icons.numbers,
                          ),
                          suffixIconColor: adminOrdersManager.orderIdFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminOrdersManager.orderIdFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Converter IDs para lista de String
                      items: adminOrdersManager.filterOrders.map((e) => e.orderId!).toList(),
                      selectedItem: adminOrdersManager.orderIdFilter, // Selecionar o item atual
                      onChanged: (String? selectedAccount) {
                        if (selectedAccount != null) {
                          adminOrdersManager.setOrderIdFilter(selectedAccount);
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
                    child: DropdownSearch<bool>(
                      // Customização do campo pesquisa e itens dentro do drop
                      popupProps: PopupProps.menu(
                        // customização dos itens dentro do drop
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminOrdersManager.isDeliveryFilter == item;
                          return ListTile(
                            leading: Icon(
                              item ? Icons.local_shipping : Icons.directions_run,
                              color: isCurrentlySelected ? primaryColor : Colors.grey,
                            ),
                            title: Text(
                              item ? 'Entrega' : 'Retirada',
                              style: TextStyle(
                                color: isCurrentlySelected ? primaryColor : Colors.black,
                              ),
                            ),
                            selected: isCurrentlySelected,
                          );
                        },
                      ),

                      //  Customizando o dropdown após a seleção
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Envio',
                          labelStyle: TextStyle(
                            color: adminOrdersManager.isDeliveryFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            adminOrdersManager.isDeliveryFilter == null
                                ? Icons.local_shipping
                                : adminOrdersManager.isDeliveryFilter!
                                    ? Icons.local_shipping
                                    : Icons.directions_run,
                            size: 20,
                            color: adminOrdersManager.isDeliveryFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIconColor: adminOrdersManager.isDeliveryFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminOrdersManager.isDeliveryFilter == null ? Colors.grey : primaryColor,
                            ),
                          ),
                        ),
                      ),
                      items: const [true, false],
                      itemAsString: (item) => item ? 'Entrega' : 'Retirada',
                      selectedItem: adminOrdersManager.isDeliveryFilter,
                      onChanged: (bool? isDelivery) {
                        if (isDelivery != null) {
                          // Atualizar o filtro booleano
                          adminOrdersManager.setIsDeliveryFilter(isDelivery);
                        }
                      },
                    ),
                  ),

                  // espaço horizontal ente os campos
                  const SizedBox(width: 20),

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
                                adminOrdersManager.setSizeFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminOrdersManager.sizeFilter == item;
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
                            color: adminOrdersManager.sizeFilter != null ? primaryColor : Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.format_size,
                            size: 20,
                            color: adminOrdersManager.sizeFilter != null ? primaryColor : Colors.grey,
                          ),
                          suffixIconColor: adminOrdersManager.sizeFilter != null ? primaryColor : Colors.grey,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminOrdersManager.sizeFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // transformando o objeto sizeList em string
                      items: sizeList.map((s) => s.name!).toList(),
                      selectedItem: adminOrdersManager.sizeFilter, // Tamanho selecionado atualmente
                      onChanged: (String? selectedSize) {
                        if (selectedSize != null) {
                          // Atualizar o filtro de tamanho
                          adminOrdersManager.setSizeFilter(selectedSize);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Cliente
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownSearch<UserApp>(
                        popupProps: PopupProps.menu(
                          showSelectedItems: true,
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            controller: searchUserController,
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
                                  searchUserController.clear();
                                  adminOrdersManager.setUserFilter(null);
                                },
                              ),
                            ),
                          ),
                          itemBuilder: (context, item, isSelected) {
                            final isCurrentlySelected = adminOrdersManager.userFilter == item;
                            return ListTile(
                              leading: Icon(
                                Icons.person,
                                color: isCurrentlySelected ? primaryColor : Colors.grey,
                              ),
                              title: Text(item.name!),
                              selected: isCurrentlySelected,
                            );
                          },
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Cliente',
                            labelStyle: TextStyle(
                              color: adminOrdersManager.userFilter != null ? primaryColor : Colors.grey,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              size: 20,
                              color: adminOrdersManager.userFilter != null ? primaryColor : Colors.grey,
                            ),
                            suffixIconColor: adminOrdersManager.userFilter != null ? primaryColor : Colors.grey,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: adminOrdersManager.userFilter != null ? primaryColor : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        items: userList,
                        itemAsString: (UserApp user) => user.name!,
                        compareFn: (UserApp a, UserApp b) => a.id == b.id,
                        selectedItem: adminOrdersManager.userFilter,
                        onChanged: (UserApp? selectedUser) {
                          if (selectedUser != null) {
                            adminOrdersManager.setUserFilter(selectedUser);
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
                                adminOrdersManager.setProductFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = adminOrdersManager.productFilter == item;
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
                            color: adminOrdersManager.productFilter != null ? primaryColor : Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.inventory,
                            size: 20,
                            color: adminOrdersManager.productFilter != null ? primaryColor : Colors.grey,
                          ),
                          suffixIconColor: adminOrdersManager.productFilter != null ? primaryColor : Colors.grey,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: adminOrdersManager.productFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      items: productList.map((product) => product.name!).toList(),
                      selectedItem: adminOrdersManager.productFilter,
                      onChanged: (value) {
                        adminOrdersManager.setProductFilter(value);
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
