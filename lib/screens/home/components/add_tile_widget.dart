import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/home/section.dart';
import 'package:maria_store/models/home/section_item.dart';
import 'package:maria_store/common/commons/image_source_sheet.dart';
import 'package:provider/provider.dart';

class AddTileWidget extends StatelessWidget {
  const AddTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // obtendo e observando as seções
    final section = context.watch<Section>();

    // metodo para acessar e add a imagem
    void onImageSelected(File file) {
      // ir na seção e add mais um item
      section.addItem(
        SectionItem(image: file),
      );
      // Fechando a dialog de imagem
      Navigator.of(context).pop();
    }

    // widget ter o aspecto quadrado
    return AspectRatio(
      aspectRatio: 1,
      // Reconhecer o toque noo widget
      child: GestureDetector(
        onTap: () {
          if (Platform.isAndroid) {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return ImageSourceSheet(
                  onImageSelected: onImageSelected,
                );
              },
            );
          } else {
            showCupertinoModalPopup(
              context: context,
              builder: (_) {
                return ImageSourceSheet(
                  onImageSelected: onImageSelected,
                );
              },
            );
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            color: Colors.white.withAlpha(30),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
