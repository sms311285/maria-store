import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/common/commons/image_source_sheet.dart';

class ImagesForm extends StatelessWidget {
  // Passando parametro no construtor para receber os dados do prd
  const ImagesForm({super.key, required this.product});

  // Passando product por parametro para pegar os seus dados
  final Product product;

  @override
  Widget build(BuildContext context) {
    // FormField para validar os campos e especificar o tipo de dado List<dynamic> para imagem se for arquivo ou imagem url string varios tipos
    return FormField<List<dynamic>>(
      // Criando uma nova lista (clonando) passando uma cópia para ao selecionar a imagem ou excluir não perder a referencia da lista antiga
      // Alem de clonar aqui tbm é clonando direto lá em Product igual no sizesForm
      initialValue: List.from(product.images!), // ou usar (product.images as as Iterable) ou (product.images ?? [])
      // validador da imagem
      validator: (images) {
        if (images!.isEmpty) return 'Adicione ao menos uma imagem...';
        return null;
      },
      // Salvando as imagens, pegando o new image que foi uma variavel que criei em Prduct para salvar tanto file como string
      onSaved: (images) => product.newImages = images,
      // Builder state para pegar o estado do campo
      builder: (state) {
        // Função para receber a imagem selecionada que foi enviada por paramtro do ImageSourceSheet
        void onImageSelected(File file) {
          // Acessando a lista de imagem iicial e add o file a lista
          state.value?.add(file);
          // Atualizar com a imagem selecionada
          state.didChange(state.value);
          // fehchando o dialog de imagem
          Navigator.of(context).pop();
        }

        return Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: CarouselSlider(
                // Pegando o valor do state ou seja o estado que está a pagina e mapear / <Widget> para aceitar a lista do widget para add imagem
                items: state.value!.map<Widget>((image) {
                  return Stack(
                    // Ocupar todo espaço disponível
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Verificando se a imagem é url ou arquivo por isso o <List<dynamic> lem cima
                      if (image is String)
                        // Imagens URL
                        Image.network(
                          image,
                          // Ocupar o espaço disponivel
                          fit: BoxFit.cover,
                        )
                      else
                        // Imagem Arquivo
                        Image.file(
                          // Convertendo para File indicando que é arquivo
                          image as File,
                          // Ocupar o espaço disponivel
                          fit: BoxFit.cover,
                        ),
                      // Icone de remover imagem
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.red,
                          onPressed: () {
                            // Acessando a lista de imagem e dando um remove
                            state.value?.remove(image);
                            // Alterando o estado
                            state.didChange(state.value);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList()
                  // Adicionando operador de cascata para retornar widget para add imagem // Material para o efeito de toque
                  ..add(Material(
                    color: Colors.grey[300],
                    child: Padding(
                      padding: const EdgeInsets.all(175),
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        color: Theme.of(context).primaryColor,
                        iconSize: 50,
                        onPressed: () {
                          // Verificando se o dispositivo é android ou iOS
                          if (Platform.isAndroid) {
                            // Mostrar o bottom sheet para selecionar camera ou galeria android
                            showModalBottomSheet(
                              context: context,
                              // passando a função onImageSelected por paramtro para pegar o file selecionado
                              builder: (_) => ImageSourceSheet(onImageSelected: onImageSelected),
                            );
                          } else {
                            // Mostrar o bottom sheet para selecionar camera ou galeria ios
                            showCupertinoModalPopup(
                              context: context,
                              // passando a função onImageSelected por paramtro para pegar o file selecionado
                              builder: (_) => ImageSourceSheet(onImageSelected: onImageSelected),
                            );
                          }
                        },
                      ),
                    ),
                  )),
                // Opções de carrossel
                options: CarouselOptions(
                  height: 415,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                ),
              ),
            ),
            // Verificando se tem erro
            if (state.hasError)
              Container(
                margin: const EdgeInsets.only(top: 16, left: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  state.errorText ?? "Erro desconhecido",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
