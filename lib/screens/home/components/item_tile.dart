import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maria_store/models/home/home_manager.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/product/product_manager.dart';
import 'package:maria_store/models/home/section.dart';
import 'package:maria_store/models/home/section_item.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.item});

  final SectionItem item;

  @override
  Widget build(BuildContext context) {
    // acessando o homemanager (Quando está dentro do build usa o watch)
    final homeManager = context.watch<HomeManager>();

    // Clicar na imagem da home e abrir prd
    return GestureDetector(
      onTap: () {
        // Abrir o prd clicado
        if (item.product != null) {
          // Buscando o prd correspondente pelo id atravez do read onde vem da função findProductById no ProductManager
          final product = context.read<ProductManager>().findProductById(item.product!);
          if (product != null) {
            // Navegando para tela de prdutos passando como argumento para abrir a tela do produto correspondente
            Navigator.of(context).pushNamed('/product', arguments: product);
          }
        }
      },
      // mostrar dialog para excluir, vincular imagem
      onLongPress: homeManager.editing
          ? () {
              showDialog(
                context: context,
                builder: (_) {
                  // obtendo o produto cujo ID é o mesmo Id que está sendo clicado, buscar o produto que está vinculado a imagem
                  final product = context.read<ProductManager>().findProductById(item.product ?? "");

                  return AlertDialog(
                    title: const Text('Editar Item...'),
                    content: product != null
                        // ListTile, lista simples para criar uma lista de itens
                        ? ListTile(
                            // ocupar todo espaço
                            contentPadding: EdgeInsets.zero,
                            // leading, item a esquerda que seria a imagem
                            leading: Image.network(product.images!.first),
                            // nome prd
                            title: Text(product.name!),
                            // preço base do prd
                            subtitle: Text('R\$ ${product.basePrice.toStringAsFixed(2)}'),
                          )
                        : null,
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          // Quando está dentro de uma função utiliza o read (obtendo a função para remover a imagem)
                          context.read<Section>().removeItem(item);
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          // verificar se o prd existe e se está vinculado
                          if (product != null) {
                            // acessar o prd do item (da img) e setando nulo
                            item.product = null;
                          } else {
                            // obtendo o prd e Acessando a tela de selecionar produto, await para esperar a tela abrir para depois fechar a tela do dialogo
                            final Product product = await Navigator.of(context).pushNamed('/select_product') as Product;
                            // colocar o prd no item
                            item.product = product.id;
                          }
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          product != null ? 'Desvincular' : 'Vincular',
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        // Efeito para carregamento de imagem,. verificando se é string ou file
        child: item.image is String
            // Efeito para carregamento de imagem
            ? FadeInImage.memoryNetwork(
                // Package Trasnsparent Image para imagem transparente ao carregar as imagens
                placeholder: kTransparentImage,
                image: item.image as String,
                fit: BoxFit.cover,
              )
            : Image.file(
                item.image as File,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
