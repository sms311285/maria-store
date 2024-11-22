import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSheet extends StatelessWidget {
  ImageSourceSheet({super.key, required this.onImageSelected});

  // Recebendo uma função file por parametro
  final Function(File) onImageSelected;

  // Instanciando o ImagePicker
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Função para editar a imagem antes de inserir no carrossel
    Future<void> editImage(String path) async {
      // chamando o package ImageCropper, configuraçõs padrões
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Imagem',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Editar Imagem',
            cancelButtonTitle: 'Cancelar',
            doneButtonTitle: 'Concluir',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      // Verificando para caso editar a imagem e fechar a tela
      if (croppedFile != null) {
        final File file = File(croppedFile.path);
        onImageSelected(file);
      }
    }

    // Verificando a plataforma
    if (Platform.isAndroid) {
      // BottomSheet do Material padrão android para abrir a opção no rodapé para selecionar img da galeria ou camera para tirar foto
      return BottomSheet(
        // Obrigatório para fechar o popUP o BottomSheet
        onClosing: () {},
        builder: (context) => Column(
          // Ocupar minimo espaco disponível
          mainAxisSize: MainAxisSize.min,
          // Aumentar a área de clique do btn camera e galeria
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                // Abrindo camera
                final XFile? file = await picker.pickImage(source: ImageSource.camera);
                // Enviando na função o arquivo selecionado
                editImage(file!.path);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Câmera',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                // Abrindo galeria
                final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                // Enviando na função o arquivo selecionado
                editImage(file!.path);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.photo_library,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Galeria',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // BottomSheet do Cupertino para adicionar imagem padrão ios
      return CupertinoActionSheet(
        title: const Text('Selecionar foto para o item'),
        message: const Text('Escolha a origem da foto'),
        // Botão de cancelar e fechar o bottomSheet
        cancelButton: CupertinoActionSheetAction(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            // Destacando opção padrão
            isDefaultAction: true,
            onPressed: () async {
              // Abrindo camera
              final XFile? file = await picker.pickImage(source: ImageSource.camera);
              // Enviando na função o arquivo selecionado
              editImage(file!.path);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text('Camera'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              // Abrindo camera
              final XFile? file = await picker.pickImage(source: ImageSource.camera);
              // Enviando na função o arquivo selecionado
              editImage(file!.path);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.photo_library,
                  color: Theme.of(context).primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text('Galeria'),
              ],
            ),
          ),
        ],
      );
    }
  }
}
