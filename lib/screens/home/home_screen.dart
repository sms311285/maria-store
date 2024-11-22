import 'package:flutter/material.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/home/home_manager.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:maria_store/screens/home/components/add_section_widget.dart';
import 'package:maria_store/screens/home/components/section_list.dart';
import 'package:maria_store/screens/home/components/section_staggered.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: <Widget>[
          // Container para configurar o gradiente da pag
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 5, 138, 98),
                  Color.fromARGB(255, 127, 182, 168),
                ],
                begin: AlignmentDirectional.topCenter,
                end: AlignmentDirectional.bottomCenter,
              ),
            ),
          ),
          // AppBar flutuante CustomScrollView permite vários efeitos
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                // Efeitos
                snap: true,
                floating: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                // Espaço que a app bar vai ocupar
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text(
                    'Loja Maria Luiza',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
                // Botoes da app bar
                actions: <Widget>[
                  // Consumer para observar se a qtde do carrinho alterou e atualizar a tela
                  Consumer<CartManager>(
                    builder: (_, cartManager, __) {
                      // Botão carrinho e contador de itens
                      return Badge(
                        backgroundColor: Colors.white,
                        offset: const Offset(-15, 5),
                        textColor: const Color.fromARGB(255, 5, 138, 98),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        label: Text(
                          '${cartManager.items.length}',
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pushNamed('/cart'),
                          icon: const Icon(
                            Icons.shopping_cart,
                            size: 25,
                          ),
                          color: Colors.white,
                        ),
                      );
                    },
                  ),

                  // Botão de edição - Consumer 2 para trocar a tela quando entrar no modo de edição
                  Consumer2<UserManager, HomeManager>(
                    builder: (_, userManager, homeManager, __) {
                      // Verificando se é um adm para mostrar o botão de edição
                      if (userManager.adminEnabled && !homeManager.loading) {
                        if (homeManager.editing) {
                          // Menu de 3 pontinhos que abre uma janelinha
                          return PopupMenuButton(
                            // ações das opções do menu
                            onSelected: (e) {
                              if (e == 'Salvar') {
                                homeManager.saveEditing();
                              } else {
                                homeManager.discardEditing();
                              }
                            },
                            // Retornar as opções do Menu
                            itemBuilder: (_) {
                              // Textos do menu, mapeia em um widget (PopupMenuItem) dando o toList no final
                              return ['Salvar', 'Descartar'].map((e) {
                                // Retornar os itens do menu
                                return PopupMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList();
                            },
                          );
                        } else {
                          return IconButton(
                            // Entrar modo de edição
                            onPressed: homeManager.enterEditing,
                            icon: const Icon(Icons.edit),
                          );
                        }
                      } else {
                        // Como tem um builder precisa retornar um widget de qqer forma então retorna container vazio
                        return Container();
                      }
                    },
                  ),
                ],
              ),
              // Ocupar todo espaco restante para rolar a pag.
              // Carregar as seções e deixar disponível para o consumer
              Consumer<HomeManager>(
                builder: (_, homeManager, __) {
                  // Verificando se esta carregando
                  if (homeManager.loading) {
                    // SliverToBoxAdapter precisa passar por conta de estar usando slivers
                    return const SliverToBoxAdapter(
                      // Adicionar progresso para indicar que esta carregando no topo da tela
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: Colors.transparent,
                      ),
                    );
                  }
                  // Pegar todas as seções e transformar em widget mapeando todas eles passando a section por parametro
                  final List<Widget> children = homeManager.sections.map<Widget>((section) {
                    // Verificando o tipo da seção
                    switch (section.type) {
                      case 'List':
                        // Recebendo o section por parametro enviado do SectionList
                        return SectionList(section: section);
                      case 'Staggered':
                        return SectionStaggered(section: section);
                      default:
                        return Container();
                    }
                  }).toList();

                  // Adiiconar Lista ou grade, antes verifica se esta editando
                  if (homeManager.editing) {
                    // Adicionando novo widget
                    children.add(
                      AddSectionWidget(homeManager: homeManager),
                    );
                  }

                  // Lista Seções
                  return SliverList(
                    // passando o children onde obteve as seções para mostrar o tipo de seção
                    delegate: SliverChildListDelegate(children),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
