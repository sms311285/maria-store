import 'package:flutter/material.dart';
import 'package:maria_store/models/home/home_manager.dart';
import 'package:maria_store/models/home/section.dart';
import 'package:maria_store/screens/home/components/add_tile_widget.dart';
import 'package:maria_store/screens/home/components/item_tile.dart';
import 'package:maria_store/screens/home/components/section_header.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class SectionStaggered extends StatelessWidget {
  const SectionStaggered({super.key, required this.section});

  // Obtendo a seção por parametro mandando os dados
  final Section section;

  @override
  Widget build(BuildContext context) {
    // Obtendo o homeManager e seu estado
    final homeManager = context.watch<HomeManager>();

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
              // Retirando a limitaçao d altura para crescer conforme a qtde de conteudo e colocando phisycs para não rolar o stagered
              // height: 300,
              // Package para auxiliar na construção do grid
              child: Consumer<Section>(
                builder: (_, section, __) {
                  return MasonryGridView.count(
                    // Define se o grid deve se ajustar ao tamanho de seu conteúdo.
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    // VER DE SCROLLAR NA VERTICAL OU HORIZONTAL precisa do SizedBox (height: 300,)
                    scrollDirection: Axis.vertical,
                    // Define o número de colunas
                    crossAxisCount: 2,
                    // Espaçamento entre os itens
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    // Inserindo o phisics para não poder/conseguir rolar o stagerred
                    physics: const NeverScrollableScrollPhysics(),
                    // Qtde de itens
                    itemCount: homeManager.editing ? section.items!.length + 1 : section.items!.length,
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
