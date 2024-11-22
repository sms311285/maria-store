import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maria_store/models/bag/bag_manager.dart'; // Importando BagManager

class NumberDaysCard extends StatelessWidget {
  const NumberDaysCard({
    super.key,
    required this.isSale,
  });

  final bool isSale; // Parâmetro para identificar se é venda ou compra

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final bagManager = context.watch<BagManager>(); // Obtendo BagManager
    TextEditingController searchDaysController = TextEditingController();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownSearch<int>(
              popupProps: PopupProps.menu(
                showSelectedItems: true, // Mostrar itens selecionados
                showSearchBox: true, // Exibir caixa de pesquisa
                // Customização do campo pesquisa dentro do drop
                searchFieldProps: TextFieldProps(
                  controller: searchDaysController, // Controlador de pesquisa
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
                        searchDaysController.clear(); // Limpar o campo de pesquisa
                      },
                    ),
                  ),
                ),
                // customização dos itens dentro do drop
                itemBuilder: (context, item, isSelected) {
                  final isCurrentlySelected = isSelected;
                  return ListTile(
                    leading: Icon(
                      Icons.calendar_month,
                      color: isCurrentlySelected ? primaryColor : Colors.grey,
                    ),
                    title: Text(item.toString()),
                    selected: isCurrentlySelected,
                  );
                },
              ),

              //
              //  Customizando o dropdown após a seleção
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: bagManager.selectedDays == null ? 'Selecione o Número de Dias' : 'Número de dias:',
                  labelStyle: TextStyle(
                    color: bagManager.selectedDays != null ? primaryColor : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_month,
                    size: 25,
                    color: bagManager.selectedDays != null ? primaryColor : Colors.grey,
                  ),
                  suffixIconColor: bagManager.selectedDays == null ? Colors.grey : primaryColor,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: bagManager.selectedDays == null ? Colors.grey : primaryColor,
                    ),
                  ),
                ),
              ),

              //items: List.generate(60, (index) => index + 1), // Gera a lista de 1 a 30
              items: List<int>.generate(60, (i) => i + 1),
              itemAsString: (int item) => item.toString(),
              compareFn: (int item1, int item2) => item1 == item2,
              selectedItem: bagManager.selectedDays,
              onChanged: (int? selectedDay) {
                if (selectedDay != null) {
                  bagManager.setSelectedDays(selectedDay); // Atualiza a seleção de dias
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
