import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';
import 'package:maria_store/screens/financial_balance/financial_balance_tile.dart';
import 'package:provider/provider.dart';

class FinancialBalanceScreen extends StatelessWidget {
  const FinancialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financialManager = context.watch<FinancialManager>();

    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saldo Financeiro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              // Reseta as datas e chama o notifyListeners
              financialManager.clearMovementsFinancial();
              // chama todos lançamentos
              //financialManager.fetchMovements(product.id!, sizeName);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Exibe o saldo atual
          Card(
            margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.attach_money,
                        color: Colors.green[200],
                        size: 25,
                      ),
                      Text(
                        'Total Receber: R\$ ${financialManager.calculateBalanceTotal()['totalReceive']!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.attach_money,
                        color: Colors.red[200],
                        size: 25,
                      ),
                      Text(
                        'Total Pagar: R\$ ${financialManager.calculateBalanceTotal()['totalPay']!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.attach_money,
                        color: financialManager.calculateBalanceTotal()['balanceFinal']! >= 0
                            ? Colors.green[200]
                            : Colors.red[200],
                        size: 25,
                      ),
                      Text(
                        'Saldo Atual: R\$ ${financialManager.calculateBalanceTotal()['balanceFinal']!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Filtros de Data
          Card(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            // Exibe o DatePicker quando o campo for clicado
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: financialManager.startDate ?? DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2035),
                            );

                            if (pickedDate != null) {
                              // Atualiza a data selecionada no estado
                              financialManager.setStartDate(pickedDate);
                              // Chama o método para buscar as movimentações com as novas datas
                              if (financialManager.endDate != null) {
                                await financialManager.fetchMovementsFinancial();
                              }
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
                                  labelText: 'Data Início',
                                  labelStyle: TextStyle(
                                    color: financialManager.startDate != null ? primaryColor : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                    color: financialManager.startDate != null ? primaryColor : Colors.grey,
                                  ),
                                  suffixIconColor: financialManager.startDate != null ? primaryColor : Colors.grey,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: financialManager.startDate != null ? primaryColor : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              selectedItem: financialManager.startDate,
                              itemAsString: (DateTime? item) =>
                                  item != null ? "${item.day}/${item.month}/${item.year.toString().substring(2)}" : '',
                              onChanged: (DateTime? selectedDate) {
                                // Atualiza a data selecionada
                                financialManager.setStartDate(selectedDate);
                              },
                            ),
                          ),
                        ),
                      ),

                      // espaço
                      const SizedBox(width: 10),

                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            // Exibe o DatePicker quando o campo for clicado
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: financialManager.endDate ?? DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2035),
                            );

                            if (pickedDate != null) {
                              // Atualiza a data selecionada no estado
                              financialManager.setEndDate(pickedDate);

                              // Chama o método para buscar as movimentações com as novas datas
                              if (financialManager.startDate != null) {
                                await financialManager.fetchMovementsFinancial();
                              }
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
                                  labelText: 'Data Fim',
                                  labelStyle: TextStyle(
                                    color: financialManager.endDate != null ? primaryColor : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                    color: financialManager.endDate != null ? primaryColor : Colors.grey,
                                  ),
                                  suffixIconColor: financialManager.endDate != null ? primaryColor : Colors.grey,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: financialManager.endDate != null ? primaryColor : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              selectedItem: financialManager.endDate,
                              itemAsString: (DateTime? item) =>
                                  item != null ? "${item.day}/${item.month}/${item.year.toString().substring(2)}" : '',
                              onChanged: (DateTime? selectedDate) {
                                financialManager.setEndDate(selectedDate);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lista de Movimentações
          financialManager.financialMovements.isEmpty
              ? const EmptyCard(
                  iconData: Icons.money_off_csred_outlined,
                  title: 'Nenhuma movimentação financeira para a data informada!',
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: financialManager.financialMovements.length,
                    itemBuilder: (_, index) {
                      final movement = financialManager.financialMovements[index];
                      return FinancialBalanceTile(movement: movement);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
