import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/item_size/item_size.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/screens/edit_product/components/edit_item_size.dart';

class SizesForm extends StatelessWidget {
  const SizesForm({super.key, required this.product});

  // Passando product por parametro para tela para pegar os tamanhos
  final Product product;

  @override
  Widget build(BuildContext context) {
    return FormField<List<ItemSize>>(
      // Antes Criando uma nova lista igual feito lá em ImagesForm e não dar exceções
      // Agora não precisa clonar mais pois está clonando direto lá em Product
      initialValue: product.sizes, // List.from(product.sizes ?? []), (product.sizes as Iterable) ou (product.sizes!)

      // Validador para ver se tem pelo menos um tamanho
      validator: (sizes) {
        if (sizes!.isEmpty) {
          return 'Adicione pelo menos um tamanho...';
        }
        return null;
      },

      // builder (para refazer os tamanhos) com o estado da tela/campo da lista de tamanhos
      builder: (state) {
        return Column(
          children: <Widget>[
            // Linha do texto tamanhos e icone add
            Row(
              children: <Widget>[
                // Colocando num expanded para que o texto ocupe o maior espaço possivel e com isso jogue o icone de add para o canto direito
                const Expanded(
                  // Texto tamanhos
                  child: Text(
                    'Tamanhos:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Icone add
                CustomIconButton(
                  iconData: Icons.add,
                  color: Colors.black,
                  onTap: () {
                    // Adicionando um novo tamanho pelo construtor vazio criado em ItemSize
                    state.value?.add(ItemSize());
                    // Atualizar com o novo tamanho
                    state.didChange(state.value);
                  },
                )
              ],
            ),
            Column(
              // pegar o estado do campo e mapear para Widget para cada tamanho retornar os tamanhos e aceitar a lista do widget para add o tamanho
              children: state.value!.map((size) {
                // Lista/Widget dos tamanhos passando o size como parametro para o EditItemSize, retornando cada tamanho
                return EditItemSize(
                  // Criando a chave para saber o que fazer com os itens ao mover pra cima ou pra baixo, vinculando ao obj size
                  key: ObjectKey(size),
                  // Objeto tamanho do ItemSize passando por parametro para EditItemSize
                  size: size,
                  // Objeto de produto passando por parametro para EditItemSize
                  product: product,
                  // Passando a função onRemove passada por parametro na EditItemSize
                  onRemove: () {
                    // Remover o tamanho da lista
                    state.value?.remove(size);
                    // Atualizando a lista
                    state.didChange(state.value);
                  },
                  // Passando a função onMoveUp passada por parametro para EditItemSize para mover os tamanhos
                  // Se o tamanho for o primeiro, não pode mover mais pra cima desativar btn
                  onMoveUp: size != state.value?.first
                      ? () {
                          final index = state.value?.indexOf(size);
                          // Remove o tamanho da lista atual
                          state.value?.remove(size);
                          // Insere o tamanho para cima
                          state.value?.insert(index! - 1, size);
                          // Atualizando a lista
                          state.didChange(state.value);
                        }
                      : null,
                  // Passando a função e onMoveDown passada por parametro para EditItemSize para mover os tamanhos
                  // Se o tamanho for o último, não pode mover mais pra baixo desativar btn
                  onMoveDown: size != state.value?.last
                      ? () {
                          final index = state.value?.indexOf(size);
                          // Remove o tamanho da lista atual
                          state.value?.remove(size);
                          // Insere o tamanho para cima
                          state.value?.insert(index! + 1, size);
                          // Atualizando a lista
                          state.didChange(state.value);
                        }
                      : null,
                );
              }).toList(),
            ),
            // Validando se tem pelo menos um tamanho igual fez no imagesForm
            if (state.hasError)
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
