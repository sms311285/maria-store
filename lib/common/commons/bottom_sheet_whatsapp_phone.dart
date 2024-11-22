import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomSheetWhatsappPhone extends StatelessWidget {
  const BottomSheetWhatsappPhone({super.key, required this.phoneNumber});

  // recebendo o telefone do clinete por parametro enviado pela tela AdminUsersScreen, AdminSuppliersScreen e OrderInformationTile
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    // INICIO BUILD

    // função para mostrar uma mensagem de erro
    void showError() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta função não está disponível neste dispositivo'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // abrir o telefone
    Future<void> openPhone() async {
      // formatar o telefone para o formato correto 021999999999
      String formattedPhoneNumber = '021${phoneNumber.replaceAll(RegExp(r'[()-\s]'), '')}';
      // criar o uri para abrir o telefone no app default
      final phoneUri = Uri(scheme: 'tel', path: formattedPhoneNumber);

      // verificar se o telefone pode ser aberto
      if (await canLaunchUrl(phoneUri)) {
        // abrir o telefone
        launchUrl(phoneUri);
      } else {
        showError();
      }
    }

    // Função abrir o whatsapp
    void openWhatsApp() async {
      // Verificar se o telefone não é nulo ou vazio
      if (phoneNumber.isNotEmpty) {
        // Formatar o telefone para o formato correto 55xxxxxxxxxx
        String formattedPhoneNumber = '55${phoneNumber.replaceAll(RegExp(r'[()-\s]'), '')}';
        // Criar a URL do WhatsApp
        final Uri url = Uri.parse("https://wa.me/$formattedPhoneNumber");
        // Abrir o WhatsApp
        if (!await launchUrl(url)) {
          throw Exception('Não foi possível abrir o WhatsApp $url');
        }
      } else {
        // Exibir erro caso o telefone seja nulo ou vazio
        showError();
      }
    }

    // bottomsheet
    if (Platform.isAndroid) {
      // BottomSheet do Material padrão Android para mostrar opções
      return BottomSheet(
        onClosing: () {},
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: () {
                openPhone();
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ), // Ícone do telefone
                  const SizedBox(width: 8), // Espaço entre o ícone e o texto
                  Text(
                    'Ligar',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                openWhatsApp();
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WhatsApp',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // BottomSheet do Cupertino padrão iOS para mostrar opções
      return CupertinoActionSheet(
        title: const Text('Contato com o cliente'),
        message: const Text('Escolha a forma de contato'),
        cancelButton: CupertinoActionSheetAction(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              openPhone();
              Navigator.of(context).pop();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(CupertinoIcons.phone), // Ícone do telefone para iOS
                SizedBox(width: 8),
                Text('Ligar'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              openWhatsApp();
              Navigator.of(context).pop();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(CupertinoIcons.chat_bubble), // Ícone de chat para iOS
                SizedBox(width: 8),
                Text('WhatsApp'),
              ],
            ),
          ),
        ],
      );
    }
  }
}
