import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/cart/cart_product.dart';
import 'package:provider/provider.dart';

class CartTile extends StatelessWidget {
  const CartTile({super.key, required this.cartProduct});

  // Recebendo o cartProduct por parametro para utilizar seus dados
  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider.value para deixar disponível o cartProduct apenas para Cartile e não em todo o app
    // Por isso que cria apenas aqui e não cria tbm no main
    return ChangeNotifierProvider.value(
      value: cartProduct,
      // envolvendo no gestureDetector para clicar no prd e ir para sua tela
      child: GestureDetector(
        onTap: () {
          // Navegando para a tela do prd ProductScreen e passando o obj cartProduct como argumento para rota no main.dart e abrir o prd correspondente
          Navigator.of(context).pushNamed(
            '/product',
            arguments: cartProduct.product,
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
                  // Acessando o cartProduct pegando o produto correspondente ao cartProduct acessar as imagens e depois a primeira imagem
                  child: Image.network(cartProduct.product!.images!.first),
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
                          cartProduct.product!.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                          ),
                        ),
                        // Tamanho
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Tamanho: ${cartProduct.size}',
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                        // Consumer para observar as mudanças de stock
                        Consumer<CartProduct>(
                          builder: (_, cartProduct, __) {
                            // Verificar se tem estoque mostrar o preço se não um texto
                            if (cartProduct.hasStock) {
                              // Preço
                              return Text(
                                // Pegando preço do tamanho acessando o prd
                                'R\$ ${cartProduct.unitPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            } else {
                              return const Text(
                                'Sem estoque disponível...',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Consumer para rebuildar a coluna que contém a qtde e os botões
                Consumer<CartProduct>(
                  builder: (_, cartProduct, __) {
                    // Sessão Quantidade btn +/-
                    return Column(
                      children: <Widget>[
                        // Criando widget icon customizado para conseguir controlar o tamanho do botão e os efeitos
                        // Btn Add
                        CustomIconButton(
                          iconData: Icons.add,
                          color: Theme.of(context).primaryColor,
                          onTap: cartProduct.increment,
                        ),
                        // Texto Quantidade
                        Text(
                          '${cartProduct.quantity}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        // Btn Remove
                        CustomIconButton(
                          iconData: Icons.remove,
                          // Verificando para alterar a cor do remove se a qtde em stock for maior q 1
                          color: cartProduct.quantity! > 1 ? Theme.of(context).primaryColor : Colors.red,
                          onTap: cartProduct.decrement,
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
