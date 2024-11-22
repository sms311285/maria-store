import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/common/commons/image_source_sheet.dart';

class ImagesPaymentMethod extends StatelessWidget {
  // Passando parametro no construtor para receber os dados da forma pgto
  const ImagesPaymentMethod({super.key, required this.paymentMethodModel});

  // Passando forma pgto por parametro para pegar os seus dados
  final PaymentMethodModel paymentMethodModel;

  @override
  Widget build(BuildContext context) {
    // FormField para validar os campos e especificar o tipo de dado <dynamic> para imagem se for arquivo ou imagem url string varios tipos
    return FormField<dynamic>(
      // Criando uma nova lista (clonando) passando uma cópia para ao selecionar a imagem ou excluir não perder a referencia da lista antiga
      initialValue: paymentMethodModel.image,
      // validador da imagem
      validator: (image) {
        if (image == null) return 'Adicione uma imagem...';
        return null;
      },
      // Salvando as imagens, pegando o new image que foi uma variavel que criei em paymentMethodModel para salvar tanto file como string
      onSaved: (image) => paymentMethodModel.newImage = image,
      // Builder state para pegar o estado do campo
      builder: (state) {
        // Função para receber a imagem selecionada que foi enviada por paramtro do ImageSourceSheet
        void onImageSelected(File file) {
          // Atualizar com a imagem selecionada
          state.didChange(file);
          // Fechando o dialog de imagem
          Navigator.of(context).pop();
        }

        // Widget para mostrar imagem
        return Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  // Verificando se a imagem é url ou arquivo por isso o <dynamic> lem cima
                  if (state.value is String)
                    // Imagens URL
                    Image.network(
                      state.value as String,
                      // Ocupar o espaço disponível
                      fit: BoxFit.cover,
                    )
                  else if (state.value is File)
                    // Imagem Arquivo
                    Image.file(
                      // Convertendo para File indicando que é arquivo
                      state.value as File,
                      // Ocupar o espaço disponível
                      fit: BoxFit.cover,
                    ),
                  // Icone de remover imagem
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.remove),
                      color: Colors.red,
                      onPressed: () {
                        // Alterando o estado
                        state.didChange(null);
                      },
                    ),
                  ),
                  if (state.value == null)
                    Material(
                      color: Colors.grey[300],
                      child: Center(
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
                                // Passando a função onImageSelected por parametro para pegar o file selecionado
                                builder: (_) => ImageSourceSheet(onImageSelected: onImageSelected),
                              );
                            } else {
                              // Mostrar o bottom sheet para selecionar camera ou galeria ios
                              showCupertinoModalPopup(
                                context: context,
                                // Passando a função onImageSelected por parametro para pegar o file selecionado
                                builder: (_) => ImageSourceSheet(onImageSelected: onImageSelected),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
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
