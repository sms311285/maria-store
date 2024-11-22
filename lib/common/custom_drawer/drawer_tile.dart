import 'package:flutter/material.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:provider/provider.dart';

// Criando objeto DrawerTile para o CustomDrawer (Cores icones paginas selecionadas)
class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.iconData,
    required this.title,
    required this.page,
  });

  // Definindo os icones e os titulos padrões para o CustomDrawer
  final IconData iconData;
  final String title;
  final int page;

  @override
  Widget build(BuildContext context) {
    // Utilizar watch sempre (dentro do build) que quiser modificar o estado conforme valor interno
    // Obtendo a página atual
    final int currentPage = context.watch<PageManager>().page;

    // Obtendo a cor padrão do app definido no main
    final Color primaryColor = Theme.of(context).primaryColor;

    // ClipRRect para arredondar o efeito de toque no btn
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      // Material para o inkwell funcionar espalahr uma tinta no toque do btn
      child: Material(
        color: Colors.transparent,
        // InkWell para ter uma animação no toque detectar toque e alternar as paginas
        child: InkWell(
          onTap: () {
            // Alternando as paginas passando o page para o PageManager
            // (Utilizar read quando for buscar objeto dentro de uma função)
            context.read<PageManager>().setPage(page);
          },
          child: SizedBox(
            // Espaço horizontal entre os icones e os titulos
            height: 60,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Icon(
                    iconData,
                    size: 32,
                    color: currentPage == page ? primaryColor : Colors.grey[700],
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: currentPage == page ? primaryColor : Colors.grey[700],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
