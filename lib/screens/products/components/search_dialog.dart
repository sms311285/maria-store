import 'package:flutter/material.dart';

class SearchDialog extends StatelessWidget {
  // Passando inicialText para o construtor
  const SearchDialog({super.key, required this.initialText});

  // passando como parametro uma string inicial para quando tiver pesquisando prd trazer o texto que já havia digitado
  final String initialText;

  @override
  Widget build(BuildContext context) {
    // Informando que o campo ficará alinhado ao topo, stack para alinhar e posicionar itens livremente
    return Stack(
      children: <Widget>[
        Positioned(
          top: 2,
          left: 4,
          right: 4,
          child: Card(
            child: TextFormField(
              // Inserindo o valor inicial no campo de pesquisa
              initialValue: initialText,
              // Inserindo no teclado do dipositivo a lupa de pesquisa
              textInputAction: TextInputAction.search,
              // Focando o campo para tbm já abrir o teclado
              autofocus: true,
              decoration: InputDecoration(
                // Sem borda
                border: InputBorder.none,
                // Padding dentro do conteúdo
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                // Icon para fechar o campo de pesquisa
                prefixIcon: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              // onFieldSubmitted - Quando o campo de pesquisa for pressionado passando o texto digitado no pop
              onFieldSubmitted: (text) {
                Navigator.of(context).pop(text);
              },
            ),
          ),
        )
      ],
    );
  }
}
