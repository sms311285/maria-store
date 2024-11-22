import 'package:flutter/material.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer_header.dart';
import 'package:maria_store/common/custom_drawer/drawer_tile.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Stack para colocar uma coisa em cima de outra
      child: Stack(
        children: <Widget>[
          // Fundo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 203, 236, 241),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListView(
            children: <Widget>[
              // Chamando o CustomDrawerHeader
              const CustomDrawerHeader(),
              const Divider(),
              const DrawerTile(
                iconData: Icons.home,
                title: 'Inicio',
                page: 0,
              ),

              const DrawerTile(
                iconData: Icons.list,
                title: 'Produtos',
                page: 1,
              ),

              const DrawerTile(
                iconData: Icons.playlist_add_check,
                title: 'Meus Pedidos',
                page: 2,
              ),

              const DrawerTile(
                iconData: Icons.favorite,
                title: 'Favoritos',
                page: 3,
              ),

              const DrawerTile(
                iconData: Icons.location_on,
                title: 'Lojas',
                page: 4,
              ),
              // Consumer para habilitar os comandos caso o user seja o admin
              Consumer<UserManager>(
                builder: (_, userManager, __) {
                  if (userManager.adminEnabled) {
                    return Column(
                      children: <Widget>[
                        const Divider(),
                        // cadastros
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5, right: 16, left: 16),
                          child: ExpansionTile(
                            title: const Row(
                              children: <Widget>[
                                Icon(Icons.post_add, size: 32),
                                SizedBox(width: 30),
                                Text(
                                  'Cadastros',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            // Remove as linhas do ExpansionTile (borders) ao expandir/colapsar o tile
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            textColor: Theme.of(context).primaryColor,
                            children: const <Widget>[
                              DrawerTile(
                                iconData: Icons.person,
                                title: 'Usuários',
                                page: 5,
                              ),
                              DrawerTile(
                                iconData: Icons.business,
                                title: 'Fornecedores',
                                page: 6,
                              ),
                              DrawerTile(
                                iconData: Icons.admin_panel_settings,
                                title: 'Administradores',
                                page: 7,
                              ),
                              DrawerTile(
                                iconData: Icons.category,
                                title: 'Categorias',
                                page: 8,
                              ),
                              DrawerTile(
                                iconData: Icons.payment,
                                title: 'Forma de Pagamento',
                                page: 9,
                              ),
                              DrawerTile(
                                iconData: Icons.local_shipping,
                                title: 'Delivery',
                                page: 10,
                              ),
                              // admins
                            ],
                          ),
                        ),

                        // MOVIMENTAÇÕES
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5, right: 16, left: 16),
                          child: ExpansionTile(
                            title: const Row(
                              children: <Widget>[
                                Icon(Icons.sync, size: 32),
                                SizedBox(width: 30),
                                Text(
                                  'Movimentações',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            // Remove as linhas do ExpansionTile (borders) ao expandir/colapsar o tile
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            textColor: Theme.of(context).primaryColor,
                            children: const <Widget>[
                              // Todos os pedidos
                              DrawerTile(
                                iconData: Icons.shopping_cart,
                                title: 'Pedidos',
                                page: 11,
                              ),
                              // Todos os pedidos
                              DrawerTile(
                                iconData: Icons.shopping_bag,
                                title: 'Compras',
                                page: 12,
                              ),
                            ],
                          ),
                        ),

                        // Financeiro
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5, right: 16, left: 16),
                          child: ExpansionTile(
                            title: const Row(
                              children: <Widget>[
                                Icon(Icons.attach_money, size: 32),
                                SizedBox(width: 30),
                                Text(
                                  'Financeiro',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            // Remove as linhas do ExpansionTile (borders) ao expandir/colapsar o tile
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            textColor: Theme.of(context).primaryColor,
                            children: const <Widget>[
                              DrawerTile(
                                iconData: Icons.remove,
                                title: 'Contas à Pagar',
                                page: 13,
                              ),
                              DrawerTile(
                                iconData: Icons.add,
                                title: 'Contas à Receber',
                                page: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
