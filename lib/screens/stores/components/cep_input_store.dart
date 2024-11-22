import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/stores/stores_manager.dart';
import 'package:maria_store/models/stores/stores_model.dart';
import 'package:provider/provider.dart';

// stateful para não perder o cep digitado no caso de inválido, com stateless não estava sendo possível sempre apagava o texto do campo quando cep era inválido
class CepInputStore extends StatefulWidget {
  const CepInputStore({super.key, required this.address, required this.store});

  // receebendo a instancia do address e passando por parametro
  final Address address;
  final StoresModel store;

  @override
  State<CepInputStore> createState() => _CepInputStoreState();
}

class _CepInputStoreState extends State<CepInputStore> {
  // criando um contralodaor par ao texto
  final TextEditingController cepController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // obtendo a cor padrão
    final primaryColor = Theme.of(context).primaryColor;

    // obtendo e observando o cartmanager
    final storesManager = context.watch<StoresManager>();

    // verificado se zipcode for nulo mostrar o widget
    if (widget.address.zipCode == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  // desabilitando o campo durante o carregamento da busca do cep
                  enabled: !storesManager.loading,
                  controller: cepController,
                  decoration: const InputDecoration(
                    // isdense: dimunuir a altura do campo
                    isDense: true,
                    labelText: 'CEP',
                    hintText: '12.345-678',
                  ),
                  // fazendo bloqueios
                  inputFormatters: [
                    // bloquenado para somente numeros
                    FilteringTextInputFormatter.digitsOnly,
                    // formatando cep
                    CepInputFormatter(),
                  ],
                  // tipo do teclado
                  keyboardType: TextInputType.number,
                  // validando campo
                  validator: (cep) {
                    if (cep == null || cep.isEmpty) {
                      return 'Campo obrigatório...';
                    } else if (cep.length != 10) {
                      return 'CEP inválido...';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                onPressed: !storesManager.loading
                    ? () async {
                        // validando campo quando o form é de outro widget no caso está no AddressCard, neste caso não precisa de key GlobalKey<FormState>(),usa somente quando chama no mesmo widget
                        if (Form.of(context).validate()) {
                          // tratando exceções e mostrqando erro
                          try {
                            // mandar o cartManager buscar o endereço relacionado ao cep - acessa o cepabertoservice busca o endereço e modifica o estado da tela
                            await context.read<StoresManager>().getAddress(cepController.text);
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // indicador de carregamento ao buscar cep
          if (storesManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
        ],
      );
      // se não for nulo mostrar outro edit incluindo o cep q digitou e o icone edição
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'CEP: ${widget.address.zipCode}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CustomIconButton(
              iconData: Icons.edit,
              color: primaryColor,
              size: 25,
              onTap: () {
                // acessando a função remove do cartmanager
                context.read<StoresManager>().removeAddress();
              },
            ),
          ],
        ),
      );
    }
  }
}
