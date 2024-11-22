import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maria_store/common/commons/bottom_sheet_whatsapp_phone.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/stores/stores_model.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    this.store,
  });

  // recebendo por parametro a store
  final StoresModel? store;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // função para obter a cor do status
    Color colorForStatus(StoreStatus status) {
      switch (status) {
        case StoreStatus.closed:
          return Colors.red;
        case StoreStatus.open:
          return Colors.green;
        case StoreStatus.closing:
          return Colors.orange;
        default:
          return Colors.green;
      }
    }

    // função para mostrar uma mensagem de erro
    void showError() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta função não está disponível neste dispositivo'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // abrir o mapa
    Future<void> openMap() async {
      // exceção pois isso pode aprsentar erros
      try {
        // obter os mapas instalados no dispositivo
        final availableMaps = await MapLauncher.installedMaps;

        showModalBottomSheet(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (_) {
            // safe area para ajustar card de abrir o mapa no rodapé
            return SafeArea(
              child: Column(
                // ocupar o minimo tamanho possivel
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // verificando passando por cada item da lista  e exibir os mapas disponíveis
                  for (final map in availableMaps)
                    ListTile(
                      onTap: () {
                        // passando as coordenadas, nome e endereço da loja para o maps ou waze
                        map.showMarker(
                          coords: Coords(store!.address!.lat!, store!.address!.long!),
                          title: store!.name!,
                          description: store?.addressText,
                        );
                        Navigator.of(context).pop();
                      },
                      // nome do app waze o google maps
                      title: Text(map.mapName),
                      // inserindo uma borda com ClipRRect
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                    )
                ],
              ),
            );
          },
        );
      } catch (e) {
        showError();
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // cortar o card para que fique arredondado
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          // sized box para limmitar a altura da imagem
          SizedBox(
            height: 180,
            child: Stack(
              // expandir a imagem cobrir todo oo espaço coma imagem
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(store!.image!, fit: BoxFit.cover),
                // texto do status
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      store!.statusText,
                      style: TextStyle(
                        color: colorForStatus(store!.status!),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    // espaçando os itens na vertical por causa que é coluna
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // alinhando itens a esquerda
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            store!.name!,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                          ),
                          const SizedBox(width: 8),
                          Consumer<UserManager>(
                            builder: (_, userManager, __) {
                              if (userManager.adminEnabled) {
                                return IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/edit_store', arguments: store);
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                          )
                        ],
                      ),
                      Text(
                        store!.addressText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        store!.openingText,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  // um maximo pra cima outro max pra baixo
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CustomIconButton(
                      iconData: Icons.map,
                      color: primaryColor,
                      onTap: openMap,
                    ),
                    CustomIconButton(
                      iconData: Icons.phone,
                      color: primaryColor,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => BottomSheetWhatsappPhone(
                            phoneNumber: store?.cleanPhone ?? '', // Passa o telefone da loja
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
