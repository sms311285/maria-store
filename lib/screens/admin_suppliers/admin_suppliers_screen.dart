import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/bottom_sheet_whatsapp_phone.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:provider/provider.dart';

class AdminSuppliersScreen extends StatelessWidget {
  const AdminSuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Fornecedores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Indo para tela de edição
              Navigator.of(context).pushNamed('/edit_supplier');
            },
          ),
        ],
      ),
      body: Consumer<AdminSuppliersManager>(
        builder: (_, adminSuppliersManager, __) {
          // Se não houver nenhum favorito mostrar o emptyCard customizado
          if (adminSuppliersManager.suppliers.isEmpty) {
            return const EmptyCard(
              iconData: Icons.border_clear,
              title: 'Nenhum fornecedor cadastrado!',
            );
          }
          return AlphabetScrollView(
            list: adminSuppliersManager.names.map((e) => AlphaModel(e!)).toList(),
            itemExtent: 60,
            overlayWidget: (value) => Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              alignment: Alignment.center,
              child: Text(
                value.toUpperCase(),
                style: TextStyle(
                  fontSize: 35,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
            unselectedTextStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
            itemBuilder: (_, index, alphaModel) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ListTile(
                  title: Text(
                    adminSuppliersManager.suppliers[index].name!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    adminSuppliersManager.suppliers[index].phone!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                    ),
                  ),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => BottomSheetWhatsappPhone(
                          phoneNumber: adminSuppliersManager.suppliers[index].phone!,
                        ),
                      );
                    },
                  ),
                  //onTap: () {},
                  onLongPress: () {},
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/edit_supplier', arguments: adminSuppliersManager.suppliers[index]);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
