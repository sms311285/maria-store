import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/bottom_sheet_whatsapp_phone.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:provider/provider.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Usuários',
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
              Navigator.of(context).pushNamed('/edit_user');
            },
          ),
        ],
      ),
      // Consumer para observar os cadastros de novos users por ex e já carregar os users
      body: Consumer<AdminUsersManager>(
        builder: (_, adminUsersManager, __) {
          // Package para mostrar uma lista e o alfabeto rolagem
          return AlphabetScrollView(
            list: adminUsersManager.names.map((e) => AlphaModel(e)).toList(),
            itemExtent: 60,
            itemBuilder: (_, index, alphaModel) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ListTile(
                  // Icone
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  // Nome
                  title: Text(
                    adminUsersManager.users[index].name!,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  // Email
                  subtitle: Text(
                    adminUsersManager.users[index].phone!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      //_callClient(adminUsersManager.users[index].phone!);
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => BottomSheetWhatsappPhone(
                          phoneNumber: adminUsersManager.users[index].phone!,
                        ),
                      );
                    },
                  ),

                  // tocar no user e ir para os pedidos
                  onTap: () {
                    Navigator.of(context).pushNamed('/edit_user', arguments: adminUsersManager.users[index]);
                  },
                ),
              );
            },
            // Mostra a letra selecionada quando o usuário interage com a barra de índice.
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
            // Estilo de texto selecionado
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
            // Estilo de texto não selecionado
            unselectedTextStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          );
        },
      ),
    );
  }
}
