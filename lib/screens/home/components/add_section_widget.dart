import 'package:flutter/material.dart';
import 'package:maria_store/models/home/home_manager.dart';
import 'package:maria_store/models/home/section.dart';

class AddSectionWidget extends StatelessWidget {
  const AddSectionWidget({super.key, required this.homeManager});

  final HomeManager homeManager;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // 2 expanded para cada um ocupar a metade da tela, ambos o mesmo tamanho
        Expanded(
          child: TextButton(
            child: const Text(
              'Adicionar Lista',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              // Adicionando a lista e passando seu tipo
              homeManager.addSection(Section(type: 'List'));
            },
          ),
        ),
        Expanded(
          child: TextButton(
            child: const Text(
              'Adicionar Grade',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              // Adicionando a lista e passando seu tipo
              homeManager.addSection(Section(type: 'Staggered'));
            },
          ),
        ),
      ],
    );
  }
}
