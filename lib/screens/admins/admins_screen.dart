import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/models/admins/admins_manager.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:provider/provider.dart';

class AdminsScreen extends StatelessWidget {
  const AdminsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchUserController = TextEditingController();
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Administradores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Consumer<AdminsManager>(
            builder: (_, adminsManager, __) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Mostrar o dropdown para selecionar o usuário
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Selecionar o usuário...'),
                        content: DropdownSearch<UserApp>(
                          popupProps: PopupProps.menu(
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
                                  },
                                ),
                              ),
                            ),
                            itemBuilder: (context, user, isSelected) {
                              return ListTile(
                                leading: Icon(Icons.person,
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                                title: Text(user.name!),
                                selected: isSelected,
                              );
                            },
                          ),
                          items: adminsManager.userList, // Lista de usuários disponíveis
                          itemAsString: (UserApp? user) => user?.name ?? '',
                          onChanged: (UserApp? user) {
                            if (user != null) {
                              // Adicionar o usuário como administrador diretamente
                              adminsManager.saveAdmin(user.id!, user.name!);
                              // Fechar o diálogo
                              Navigator.of(context).pop();
                            }
                          },
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Escolha a opção...',
                              labelStyle: TextStyle(
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AdminsManager>(
        builder: (_, adminsManager, __) {
          if (adminsManager.adminsUsers.isEmpty) {
            return const EmptyCard(
              iconData: Icons.admin_panel_settings,
              title: 'Nenhum administrador!',
            );
          }
          return AlphabetScrollView(
            list: adminsManager.names.map((e) => AlphaModel(e)).toList(),
            itemExtent: 60,
            itemBuilder: (_, index, alphaModel) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    adminsManager.adminsUsers[index].name!,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  subtitle: Text(
                    adminsManager.adminsUsers[index].id!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return CustomDialog(
                          title: 'Remover Admin...',
                          content: Text(
                              'Deseja realmente remover ${adminsManager.adminsUsers[index].name} como administrador?'),
                          confirmText: 'Remover',
                          cancelText: 'Cancelar',
                          onConfirm: () {
                            adminsManager.removeAdmin(adminsManager.adminsUsers[index]);
                            Navigator.of(context).pop();
                          },
                          onCancel: () => Navigator.of(context).pop(),
                        );
                      },
                    );
                  },
                ),
              );
            },
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
          );
        },
      ),
    );
  }
}
