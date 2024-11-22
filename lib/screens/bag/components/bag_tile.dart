import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/bag/bag_product.dart';
import 'package:provider/provider.dart';

class BagTile extends StatelessWidget {
  const BagTile({super.key, required this.bagProduct});

  // Recebendo o bagProduct por parametro para utilizar seus dados
  final BagProduct bagProduct;

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider.value para deixar disponível o bagProduct apenas para bagile e não em todo o app
    // Por isso que cria apenas aqui e não cria tbm no main
    return ChangeNotifierProvider.value(
      value: bagProduct,
      // envolvendo no gestureDetector para clicar no prd e ir para sua tela
      child: GestureDetector(
        onTap: () {
          // Navegando para a tela do prd ProductScreen e passando o obj bagProduct como argumento para rota no main.dart e abrir o prd correspondente
          Navigator.of(context).pushNamed(
            '/product',
            arguments: bagProduct.product,
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: <Widget>[
                // Imagem
                SizedBox(
                  height: 80,
                  width: 80,
                  // Acessando o bagProduct pegando o produto correspondente ao bagProduct acessar as imagens e depois a primeira imagem
                  child: Image.network(bagProduct.product!.images!.first),
                ),
                // Expanded para o conteudo central ocupar o maior espaço possivel jogando os itens da esqueda e direita para o canto
                // Sessão dos textos no card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Nome produto
                        Text(
                          // Pegando o prd do carrinho, pegar o prd correspondente e dps o nome do prd
                          bagProduct.product!.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        // Tamanho
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Tamanho: ${bagProduct.size}',
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        // Consumer para observar as mudanças de stock
                        Consumer<BagProduct>(
                          builder: (_, bagProduct, __) {
                            // Preço
                            return Text(
                              // Pegando preço do tamanho acessando o prd
                              'R\$ ${bagProduct.unitPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Consumer para rebuildar a coluna que contém a qtde e os botões
                Consumer<BagProduct>(
                  builder: (_, bagProduct, __) {
                    // Sessão Quantidade btn +/-
                    return Column(
                      children: <Widget>[
                        // Criando widget icon customizado para conseguir controlar o tamanho do botão e os efeitos
                        // Btn Add
                        CustomIconButton(
                          iconData: Icons.add,
                          color: Theme.of(context).primaryColor,
                          onTap: bagProduct.increment,
                        ),
                        // Texto Quantidade
                        Text(
                          '${bagProduct.quantity}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        // Btn Remove
                        CustomIconButton(
                          iconData: Icons.remove,
                          // Verificando para alterar a cor do remove se a qtde em stock for maior q 1
                          color: bagProduct.quantity! > 1 ? Theme.of(context).primaryColor : Colors.red,
                          onTap: bagProduct.decrement,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
