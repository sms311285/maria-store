import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/item_size/item_size.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/stock/stock_manager.dart';
import 'package:provider/provider.dart';

class EditItemSize extends StatelessWidget {
  const EditItemSize({
    super.key, // Usando a superKey no (SizesForm) para controlar quando move o tamanho pra cima ou pra baixo
    required this.size,
    required this.product,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  // Obtendo o item size passado pelo construtor e passando para o widget de textformfield
  final ItemSize size;

  final Product product;

  // Passando o onRemove por parametro para usar la na SizesForm
  final VoidCallback onRemove;

  // Passando as funções para mover o tamanho para cima e para baixo
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Colocando num expanded para especificar o tamanho do textforfield dentro da row neste caso
        // Nome
        Expanded(
          // tamanho do espaço a ser ocupado em porcentagem em relação aos outros campos na row
          flex: 30,
          child: TextFormField(
            initialValue: size.name,
            decoration: const InputDecoration(
              labelText: 'Título',
              isDense: true,
            ),
            // Validador
            validator: (name) {
              if (name == null || name.isEmpty) {
                return 'Inválido...';
              }
              return null;
            },
            // sempre que modificar o nome, armanezar o novo valor no size/tamanho
            onChanged: (name) => size.name = name,
          ),
        ),
        const SizedBox(width: 4),

        // Qtde stock
        Expanded(
          // tamanho do espaço a ser ocupado em porcentagem em relação aos outros campos na row
          flex: 30,
          child: TextFormField(
            initialValue: size.stock?.toString(),
            decoration: const InputDecoration(
              labelText: 'Estoque',
              isDense: true,
            ),
            // Validador se for número inteiro
            validator: (stock) {
              // pegar o texto e tenta transformar num inteiro
              if (int.tryParse(stock!) == null) {
                return 'Inválido...';
              }
              return null;
            },
            // sempre que modificar o stcok, armanezar o novo valor no size/tamanho
            onChanged: (stock) => size.stock = int.tryParse(stock) ?? 0,
            // Aparecer o teclado numerico
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 4),

        // Preço Venda
        Expanded(
          // tamanho do espaço a ser ocupado em porcentagem em relação aos outros campos na row
          flex: 40,
          child: TextFormField(
            initialValue: size.price?.toStringAsFixed(2),
            decoration: const InputDecoration(
              labelText: 'Venda',
              isDense: true,
              // prefixText para informar o tipo de valor no inicio do campo suffix no final do campo
              //prefixText: 'R\$ ',
            ),

            // Validador numero tipo double
            validator: (price) {
              // transformar numero em double
              if (double.tryParse(price!) == null) {
                return 'Inválido...';
              }
              return null;
            },

            // sempre que modificar o preco, armanezar o novo valor no size/tamanho
            onChanged: (price) => size.price = num.tryParse(price) ?? 0.0,
            // Aparecer o teclado numerico
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),

        const SizedBox(width: 4),

        // Preço Compra
        Expanded(
          // tamanho do espaço a ser ocupado em porcentagem em relação aos outros campos na row
          flex: 40,
          child: TextFormField(
            initialValue: size.purchasePrice?.toStringAsFixed(2),
            decoration: const InputDecoration(
              labelText: 'Compra',
              isDense: true,
              // prefixText para informar o tipo de valor no inicio do campo suffix no final do campo
              //prefixText: 'R\$ ',
            ),

            // Validador numero tipo double
            validator: (purchasePrice) {
              // transformar numero em double
              if (double.tryParse(purchasePrice!) == null) {
                return 'Inválido...';
              }
              return null;
            },

            // sempre que modificar o preco, armanezar o novo valor no size/tamanho
            onChanged: (purchasePrice) => size.purchasePrice = num.tryParse(purchasePrice) ?? 0.0,
            // Aparecer o teclado numerico
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),

        // Ícones para remover, mover para cima e para baixo
        // CustomIconButton para ver a movimentação do produto
        CustomIconButton(
          iconData: Icons.sync,
          color: Colors.black,
          // chamando a função passada por parametro para remover lá no SizesForm
          onTap: () async {
            final stockManager = context.read<StockManager>();
            // Limpa as movimentações e datas antes de navegar para o novo tamanho
            stockManager.clearMovements();
            // // Chame o método com o ID do produto e o nome do tamanho
            // await stockManager.fetchMovements(product.id!, size.name!);
            // Navegar para a tela de movimentações passando produto e NOME DO tamanho como argumentos
            Navigator.of(context).pushNamed(
              '/stock_movements',
              arguments: {
                'product': product,
                'sizeName': size.name,
              },
            );
          },
        ),

        // CustomIconButton para remover o tamanho
        CustomIconButton(
          iconData: Icons.remove,
          color: Colors.red,
          // chamando a função passada por parametro para remover lá no SizesForm
          onTap: onRemove,
        ),

        // CustomIconButton para mover para cima o tamanho
        CustomIconButton(
          iconData: Icons.arrow_drop_up,
          color: Colors.black,
          onTap: onMoveUp,
        ),

        // CustomIconButton para mover para baixo o tamanho
        CustomIconButton(
          iconData: Icons.arrow_drop_down,
          color: Colors.black,
          onTap: onMoveDown,
        ),
      ],
    );
  }
}
