import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/account_receive/account_receive_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:provider/provider.dart';

class AccountReceiveFilters extends StatelessWidget {
  const AccountReceiveFilters({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchMethodPaymentController = TextEditingController();
    TextEditingController searchAccountPayController = TextEditingController();
    TextEditingController searchUserController = TextEditingController();

    // obtendo as instancias
    final paymentMethodList = context.watch<PaymentMethodManager>().allPaymentMethod;

    final userList = context.watch<AdminUsersManager>().users;

    return Consumer<AccountReceiveManager>(
      builder: (_, accountReceiveManager, __) {
        final Color primaryColor = Theme.of(context).primaryColor;

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
                          initialDate: accountReceiveManager.startDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountReceiveManager.setStartDate(pickedDate);
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
                                color: accountReceiveManager.startDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountReceiveManager.startDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor:
                                  accountReceiveManager.startDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountReceiveManager.startDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountReceiveManager.startDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountReceiveManager.setStartDate(selectedDate);
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
                          initialDate: accountReceiveManager.endDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountReceiveManager.setEndDate(pickedDate);
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
                                color: accountReceiveManager.endDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountReceiveManager.endDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: accountReceiveManager.endDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountReceiveManager.endDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountReceiveManager.endDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountReceiveManager.setEndDate(selectedDate);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                          initialDate: accountReceiveManager.startDueDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2040),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountReceiveManager.setStartDueDate(pickedDate);
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
                              labelText: 'Venc. Inicial',
                              labelStyle: TextStyle(
                                color: accountReceiveManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountReceiveManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor:
                                  accountReceiveManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountReceiveManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountReceiveManager.startDueDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountReceiveManager.setStartDueDate(selectedDate);
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
                          initialDate: accountReceiveManager.endDueDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2040),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountReceiveManager.setEndDueDate(pickedDate);
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
                              labelText: 'Venc. Final',
                              labelStyle: TextStyle(
                                color: accountReceiveManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountReceiveManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor:
                                  accountReceiveManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountReceiveManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountReceiveManager.endDueDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountReceiveManager.setEndDueDate(selectedDate);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                          initialDate: accountReceiveManager.startDateReceiveFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2040),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountReceiveManager.setStartDateReceive(pickedDate);
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
                              labelText: 'Rec. Inicial',
                              labelStyle: TextStyle(
                                color:
                                    accountReceiveManager.startDateReceiveFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color:
                                    accountReceiveManager.startDateReceiveFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor:
                                  accountReceiveManager.startDateReceiveFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      accountReceiveManager.startDateReceiveFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountReceiveManager.startDateReceiveFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountReceiveManager.setStartDateReceive(selectedDate);
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
                          initialDate: accountReceiveManager.endDateReceiveFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountReceiveManager.setEndDateReceive(pickedDate);
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
                              labelText: 'Rec. Final',
                              labelStyle: TextStyle(
                                color: accountReceiveManager.endDateReceiveFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountReceiveManager.endDateReceiveFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor:
                                  accountReceiveManager.endDateReceiveFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      accountReceiveManager.endDateReceiveFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountReceiveManager.endDateReceiveFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountReceiveManager.setEndDateReceive(selectedDate);
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
                                accountReceiveManager.setPaymentMethodFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = accountReceiveManager.paymentMethodFilter == item;
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
                            color: accountReceiveManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            size: 20,
                            color: accountReceiveManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIconColor:
                              accountReceiveManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: accountReceiveManager.paymentMethodFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      items: paymentMethodList, // Lista de métodos de pagamento
                      itemAsString: (PaymentMethodModel? method) => method?.name ?? '',
                      compareFn: (PaymentMethodModel a, PaymentMethodModel b) => a.id == b.id, // Função de comparação
                      selectedItem: accountReceiveManager.paymentMethodFilter, // Forma de pagamento selecionada
                      onChanged: (PaymentMethodModel? selectedMethod) {
                        accountReceiveManager.setPaymentMethodFilter(selectedMethod);
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
                          controller: searchAccountPayController,
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
                                searchAccountPayController.clear();
                                accountReceiveManager.setAccountReceiveIdFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = accountReceiveManager.accountReceiveIdFilter == item;
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
                          labelText: 'ID da Conta',
                          labelStyle: TextStyle(
                            color: accountReceiveManager.accountReceiveIdFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.numbers,
                            size: 20,
                            color: accountReceiveManager.accountReceiveIdFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIconColor:
                              accountReceiveManager.accountReceiveIdFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: accountReceiveManager.accountReceiveIdFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Converter IDs para lista de String
                      items: accountReceiveManager.filterAccountReceives.map((e) => e.id!).toList(),
                      selectedItem: accountReceiveManager.accountReceiveIdFilter, // Selecionar o item atual
                      onChanged: (String? selectedAccount) {
                        if (selectedAccount != null) {
                          accountReceiveManager.setAccountReceiveIdFilter(selectedAccount);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // CLIENTE
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
                                accountReceiveManager.setUserFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = accountReceiveManager.userFilter == item;
                          return ListTile(
                            leading: Icon(
                              Icons.person,
                              color: isCurrentlySelected ? primaryColor : Colors.grey,
                            ),
                            title: Text(item.name!), // Exibe o nome do fornecedor
                            selected: isCurrentlySelected,
                          );
                        },
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Clientes',
                          labelStyle: TextStyle(
                            color: accountReceiveManager.userFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            size: 20,
                            color: accountReceiveManager.userFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIconColor: accountReceiveManager.userFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: accountReceiveManager.userFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      items: userList,
                      selectedItem: accountReceiveManager.userFilter,
                      itemAsString: (UserApp? user) => user?.name ?? '',
                      compareFn: (UserApp a, UserApp b) => a.id == b.id,
                      onChanged: (UserApp? selectedUser) {
                        if (selectedUser != null) {
                          accountReceiveManager.setUserFilter(selectedUser);
                        }
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
