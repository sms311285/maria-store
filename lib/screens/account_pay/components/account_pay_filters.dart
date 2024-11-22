import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/account_pay/account_pay_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';
import 'package:provider/provider.dart';

class AccountPayFilters extends StatelessWidget {
  const AccountPayFilters({super.key});

  @override
  Widget build(BuildContext context) {
    // Controlador para a pesquisas do dropdown
    TextEditingController searchMethodPaymentController = TextEditingController();
    TextEditingController searchAccountPayController = TextEditingController();
    TextEditingController searchSupplierController = TextEditingController();

    // obtendo as instancias
    final paymentMethodList = context.watch<PaymentMethodManager>().allPaymentMethod;

    final supplierList = context.watch<AdminSuppliersManager>().suppliers;

    return Consumer<AccountPayManager>(
      builder: (_, accountPayManager, __) {
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
                          initialDate: accountPayManager.startDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountPayManager.setStartDate(pickedDate);
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
                                color: accountPayManager.startDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountPayManager.startDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: accountPayManager.startDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountPayManager.startDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountPayManager.startDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountPayManager.setStartDate(selectedDate);
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
                          initialDate: accountPayManager.endDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountPayManager.setEndDate(pickedDate);
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
                                color: accountPayManager.endDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountPayManager.endDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: accountPayManager.endDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountPayManager.endDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountPayManager.endDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountPayManager.setEndDate(selectedDate);
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
                          initialDate: accountPayManager.startDueDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2040),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountPayManager.setStartDueDate(pickedDate);
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
                                color: accountPayManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountPayManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor:
                                  accountPayManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountPayManager.startDueDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountPayManager.startDueDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountPayManager.setStartDueDate(selectedDate);
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
                          initialDate: accountPayManager.endDueDateFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2040),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountPayManager.setEndDueDate(pickedDate);
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
                                color: accountPayManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountPayManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: accountPayManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountPayManager.endDueDateFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountPayManager.endDueDateFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountPayManager.setEndDueDate(selectedDate);
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
                          initialDate: accountPayManager.startDatePayFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2040),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountPayManager.setStartDatePay(pickedDate);
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
                              labelText: 'Pgto. Inicial',
                              labelStyle: TextStyle(
                                color: accountPayManager.startDatePayFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountPayManager.startDatePayFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor:
                                  accountPayManager.startDatePayFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountPayManager.startDatePayFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountPayManager.startDatePayFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountPayManager.setStartDatePay(selectedDate);
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
                          initialDate: accountPayManager.endDatePayFilter ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          // Atualiza a data selecionada no estado
                          accountPayManager.setEndDatePay(pickedDate);
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
                              labelText: 'Pgto. Final',
                              labelStyle: TextStyle(
                                color: accountPayManager.endDatePayFilter != null ? primaryColor : Colors.grey,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                size: 20,
                                color: accountPayManager.endDatePayFilter != null ? primaryColor : Colors.grey,
                              ),
                              suffixIconColor: accountPayManager.endDatePayFilter != null ? primaryColor : Colors.grey,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accountPayManager.endDatePayFilter != null ? primaryColor : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          selectedItem: accountPayManager.endDatePayFilter,
                          itemAsString: (DateTime? item) =>
                              item != null ? "${item.day}/${item.month}/${item.year}" : '',
                          onChanged: (DateTime? selectedDate) {
                            // Atualiza a data selecionada
                            accountPayManager.setEndDatePay(selectedDate);
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
                                accountPayManager.setPaymentMethodFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = accountPayManager.paymentMethodFilter == item;
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
                            color: accountPayManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.attach_money_outlined,
                            size: 20,
                            color: accountPayManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIconColor: accountPayManager.paymentMethodFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: accountPayManager.paymentMethodFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      items: paymentMethodList, // Lista de métodos de pagamento
                      itemAsString: (PaymentMethodModel? method) => method?.name ?? '',
                      compareFn: (PaymentMethodModel a, PaymentMethodModel b) => a.id == b.id, // Função de comparação
                      selectedItem: accountPayManager.paymentMethodFilter, // Forma de pagamento selecionada
                      onChanged: (PaymentMethodModel? selectedMethod) {
                        accountPayManager.setPaymentMethodFilter(selectedMethod);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Contas
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
                                accountPayManager.setAccountPayIdFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = accountPayManager.accountPayIdFilter == item;
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
                            color: accountPayManager.accountPayIdFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.numbers,
                            size: 20,
                            color: accountPayManager.accountPayIdFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIcon: const Icon(
                            Icons.numbers,
                          ),
                          suffixIconColor: accountPayManager.accountPayIdFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: accountPayManager.accountPayIdFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Converter IDs para lista de String
                      items: accountPayManager.filterAccountPays.map((e) => e.id!).toList(),
                      selectedItem: accountPayManager.accountPayIdFilter, // Selecionar o item atual
                      onChanged: (String? selectedAccount) {
                        if (selectedAccount != null) {
                          accountPayManager.setAccountPayIdFilter(selectedAccount);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Fornecedores
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
                                accountPayManager.setSupplierFilter(null);
                              },
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final isCurrentlySelected = accountPayManager.supplierFilter == item;
                          return ListTile(
                            leading: Icon(
                              Icons.business,
                              color: isCurrentlySelected ? primaryColor : Colors.grey,
                            ),
                            title: Text(item.name!), // Exibe o nome do fornecedor
                            selected: isCurrentlySelected,
                          );
                        },
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Fornecedores',
                          labelStyle: TextStyle(
                            color: accountPayManager.supplierFilter == null ? Colors.grey : primaryColor,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.business,
                            size: 20,
                            color: accountPayManager.supplierFilter == null ? Colors.grey : primaryColor,
                          ),
                          suffixIcon: const Icon(
                            Icons.business,
                          ),
                          suffixIconColor: accountPayManager.supplierFilter == null ? Colors.grey : primaryColor,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: accountPayManager.supplierFilter != null ? primaryColor : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      items: supplierList,
                      selectedItem: accountPayManager.supplierFilter,
                      itemAsString: (SupplierApp? supplier) => supplier?.name ?? '',
                      compareFn: (SupplierApp a, SupplierApp b) => a.id == b.id,
                      onChanged: (SupplierApp? selectedSupplier) {
                        if (selectedSupplier != null) {
                          accountPayManager.setSupplierFilter(selectedSupplier);
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
