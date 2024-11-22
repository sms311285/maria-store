// widget seprado para facilitar as edições que a home vai conter
import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/home/home_manager.dart';
import 'package:maria_store/models/home/section.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, this.onMoveUp, this.onMoveDown});

  // Passando as funções para mover o tamanho para cima e para baixo
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    // acessando o home manager
    final homeManager = context.watch<HomeManager>();

    // obtendo as seções e seu estado para ser rebuildado todo o widget
    final section = context.watch<Section>();

    // Controlando o modo de edição
    if (homeManager.editing) {
      return Column(
        // Alinhando os componentes da coluna
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  initialValue: section.name,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Título',
                    hintStyle: TextStyle(color: Colors.white),
                    // isDense para ter uma altura mais reduzida para não ficar muito alto
                    isDense: true,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),

                  // Quando o campo for alterado
                  onChanged: (text) => section.name = text,
                ),
              ),
              // Botão remover
              CustomIconButton(
                iconData: Icons.remove,
                color: Colors.white,
                onTap: () {
                  // Removendo a seção
                  homeManager.removeSection(section);
                },
              ),

              CustomIconButton(
                iconData: Icons.arrow_drop_up,
                color: Colors.black,
                onTap: onMoveUp,
              ),

              CustomIconButton(
                iconData: Icons.arrow_drop_down,
                color: Colors.black,
                onTap: onMoveDown,
              ),
            ],
          ),
          // Mostrando a mensagem de erro de validação abaixo do campo Título
          if (section.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                section.error!,
                style: const TextStyle(color: Colors.red),
              ),
            )
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        // Nome da seção
        child: Text(
          section.name ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      );
    }
  }
}
