import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

class ExportAddressDialog extends StatelessWidget {
  ExportAddressDialog({super.key, required this.address, required this.orderModel});

  // passando por parametro para obter o endereço, lá no order tile passa esse parametro que contem endereço
  final Address address;

  // criando o controler do screenshor (package para exportar a img para galeria)
  final ScreenshotController screenshotController = ScreenshotController();

  // instanciando orderModel para obter os dados
  final OrderModel orderModel;

  @override
  Widget build(BuildContext context) {
    // obtendo os dados do user atraves do userId que está no order passando por parametro
    final user = context.watch<AdminUsersManager>().findUserById(orderModel.userId ?? "");

    // Função para enviar o endereço para o whatsapp
    void sendAddressWhatsApp(Address address, OrderModel orderModel) async {
      // Format the date
      String formattedDate = DateFormat('dd/MM/yyyy').format(orderModel.date!.toDate());
      // Create the message
      final String message = '- Data: $formattedDate \n'
          '- Cliente: ${user?.name}\n'
          '- Endereço de Entrega: ${address.street}, ${address.number} ${address.complement}, ${address.district},${address.city}/${address.state} - ${address.zipCode}\n'
          '- Valor Total: R\$ ${orderModel.priceTotal!.toStringAsFixed(2).replaceAll('.', ',')}\n'
          '- Forma de Pagamento: ${'Dinheiro'}';

      // Encode the message
      final String encodedMessage = Uri.encodeFull(message);

      // Construct the WhatsApp URL
      final Uri url = Uri.parse("https://wa.me/?text=$encodedMessage");

      // Launch the WhatsApp URL
      if (!await launchUrl(url)) {
        throw Exception('Não foi possível abrir o WhatsApp $url');
      }
    }

    return AlertDialog(
      title: const Text(
        'Endereço de entrega',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      // SingleChildScrollView para o conteudo do AlertDialog ser scrollavel
      content: SingleChildScrollView(
        // screenshot para exportar a img do endereço, envolvendo a área que quero a imagem
        child: Screenshot(
          // controller
          controller: screenshotController,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Card data e cliente
                _buildCard(
                  children: <Widget>[
                    _buildTitle('Data do pedido: ', Icons.calendar_today),
                    _buildContent(DateFormat('dd/MM/yyyy').format(orderModel.date!.toDate())),
                    const SizedBox(height: 4),
                    _buildTitle('Cliente: ', Icons.person),
                    _buildContent(user?.name ?? '')
                  ],
                ),

                const SizedBox(height: 8),

                // card endereço
                _buildCard(
                  children: <Widget>[
                    _buildTitle('Endereço: ', Icons.location_on),
                    _buildContent(
                        '${address.street}, ${address.number} ${address.complement}, ${address.district}, ${address.city}/${address.state} - ${address.zipCode}'),
                  ],
                ),

                const SizedBox(height: 8),

                // card valor e form de pgto
                _buildCard(
                  children: <Widget>[
                    _buildTitle('Valor: ', Icons.attach_money),
                    _buildContent('R\$ ${orderModel.priceTotal!.toStringAsFixed(2).replaceAll('.', ',')}'),
                    const SizedBox(height: 4),
                    _buildTitle('Forma de Pagamento: ', Icons.payment),
                    _buildContent(user?.name ?? ''),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // organizar os elementos dentro da dialog
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

      actions: <Widget>[
        // btn exportar

        // btn avançar
        TextButton.icon(
          onPressed: () async {
            // tirar o screenShot capturar a imagem
            final image = await screenshotController.capture();
            // Obter o diretório temporário
            final directory = (await getTemporaryDirectory()).path;
            // Converte a imagem capturada em bytes (Uint8List) e os salva como um arquivo PNG no diretório temporário.
            final filePath = '$directory/screenshot.png';

            // Salvar a imagem capturada em um arquivo temporário
            File file = File(filePath);
            await file.writeAsBytes(image!);

            // salvar imagem na galeria
            await GallerySaver.saveImage(filePath);

            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          },
          icon: const FaIcon(
            FontAwesomeIcons.image,
            size: 17,
          ),
          label: const Text('Exportar'),
        ),

        TextButton.icon(
          onPressed: () {
            sendAddressWhatsApp(address, orderModel);
          },
          icon: const FaIcon(
            FontAwesomeIcons.whatsapp,
            size: 17,
          ),
          label: const Text('Compartilhar'),
        ),
      ],
    );
  }
}

// widget separado para card
Widget _buildCard({required List<Widget> children}) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 2),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

// widgets de titulo
Widget _buildTitle(String title, [IconData? icon]) {
  return Row(
    children: <Widget>[
      if (icon != null) Icon(icon, size: 18),
      const SizedBox(width: 4),
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

// widget de content
Widget _buildContent(String content) {
  return Text(
    content,
    style: const TextStyle(color: Colors.grey),
  );
}
