import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/stock/stock_manager.dart';
import 'package:maria_store/models/stock/stock_model.dart';
import 'package:maria_store/screens/stock/stock_movement_tile.dart';
import 'package:provider/provider.dart';

class StockMovementScreen extends StatelessWidget {
  const StockMovementScreen({
    super.key,
    required this.product,
    required this.sizeName,
  });

  final Product product;
  final String sizeName;

  @override
  Widget build(BuildContext context) {
    // Obtendo a instância do gerenciador de estoque
    final stockManager = context.watch<StockManager>();

    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movimentações do Produto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              // Reseta as datas e chama o notifyListeners
              stockManager.clearMovements();
              //stockManager.fetchMovements(product.id!, sizeName);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Card(
            margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.manage_search,
                    color: Colors.grey[600],
                    size: 25,
                  ),
                  Text(
                    ' ${product.name} | $sizeName',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Card para selecionar as datas
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
                              initialDate: stockManager.startDate ?? DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Atualiza a data selecionada no estado
                              stockManager.setStartDate(pickedDate);
                              // Chama o método para buscar as movimentações com as novas datas
                              if (stockManager.endDate != null) {
                                await stockManager.fetchMovements(product.id!, sizeName);
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
                                    color: stockManager.startDate != null ? primaryColor : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                    color: stockManager.startDate != null ? primaryColor : Colors.grey,
                                  ),
                                  suffixIconColor: stockManager.startDate != null ? primaryColor : Colors.grey,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: stockManager.startDate != null ? primaryColor : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              selectedItem: stockManager.startDate,
                              itemAsString: (DateTime? item) =>
                                  item != null ? "${item.day}/${item.month}/${item.year.toString().substring(2)}" : '',
                              onChanged: (DateTime? selectedDate) {
                                // Atualiza a data selecionada
                                stockManager.setStartDate(selectedDate);
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
                              initialDate: stockManager.endDate ?? DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              // Atualiza a data selecionada no estado
                              stockManager.setEndDate(pickedDate);

                              // Chama o método para buscar as movimentações com as novas datas
                              if (stockManager.startDate != null) {
                                await stockManager.fetchMovements(product.id!, sizeName);
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
                                    color: stockManager.endDate != null ? primaryColor : Colors.grey,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    size: 20,
                                    color: stockManager.endDate != null ? primaryColor : Colors.grey,
                                  ),
                                  suffixIconColor: stockManager.endDate != null ? primaryColor : Colors.grey,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: stockManager.endDate != null ? primaryColor : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              selectedItem: stockManager.endDate,
                              itemAsString: (DateTime? item) =>
                                  item != null ? "${item.day}/${item.month}/${item.year.toString().substring(2)}" : '',
                              onChanged: (DateTime? selectedDate) {
                                stockManager.setEndDate(selectedDate);
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
          // Lista de movimentações
          stockManager.stockMovements.isEmpty
              ? const EmptyCard(iconData: Icons.list, title: 'Nenhuma movimentação de estoque para a data informada!')
              : Expanded(
                  child: ListView.builder(
                    itemCount: stockManager.stockMovements.length,
                    itemBuilder: (context, index) {
                      final StockModel movement = stockManager.stockMovements[index]; // Acessar a movimentação
                      return StockMovementTile(
                        movement: movement,
                        product: product,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
