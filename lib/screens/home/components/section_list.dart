import 'package:flutter/material.dart';
import 'package:maria_store/models/home/home_manager.dart';
import 'package:maria_store/models/home/section.dart';
import 'package:maria_store/screens/home/components/add_tile_widget.dart';
import 'package:maria_store/screens/home/components/item_tile.dart';
import 'package:maria_store/screens/home/components/section_header.dart';
import 'package:provider/provider.dart';

class SectionList extends StatelessWidget {
  const SectionList({super.key, required this.section});

  // Obtendo a seção por parametro mandando os dados
  final Section section;

  @override
  Widget build(BuildContext context) {
    // Obtendo o homeManager e seu estado
    final homeManager = context.watch<HomeManager>();

    // Change para observar as mudanças e edições na home
    return ChangeNotifierProvider.value(
      value: section,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Separando o widget para facilitar a edição da home
            SectionHeader(
              key: ObjectKey(section),
              onMoveUp: section != homeManager.sections.first
                  ? () {
                      homeManager.moveUp(section);
                    }
                  : null,
              onMoveDown: section != homeManager.sections.last
                  ? () {
                      homeManager.moveDown(section);
                    }
                  : null,
            ),
            SizedBox(
              height: 150,
              // Consumer para refazer o listView quando houver alguma alteração
              child: Consumer<Section>(
                builder: (_, section, __) {
                  // ListView.separated para ter um espaço em cada um dos itens
                  return ListView.separated(
                    // Crescimento/Rolagem horizontal
                    scrollDirection: Axis.horizontal,
                    // Item builder para mostrar as imagens
                    itemBuilder: (_, index) {
                      // Verificando se a lista é menor que o total de widgets se não mostrar o botão para adicionar mais uma imagem
                      if (index < section.items!.length) {
                        // Chamado o widget ItemTile para mostrar os itens passando item section.items![index] as informações correspondentes
                        return ItemTile(item: section.items![index]);
                      } else {
                        // Passando a sectin por parametro
                        return const AddTileWidget();
                      }
                    },
                    // Espaço entre os itens
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                    // Contador de itens, verificando que se estiver etiando retornar a lista de widget +1, se não retornar a lista normal/original.
                    itemCount: homeManager.editing ? section.items!.length + 1 : section.items!.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
