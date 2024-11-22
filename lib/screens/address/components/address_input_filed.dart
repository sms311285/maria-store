import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:provider/provider.dart';

class AddressInputField extends StatelessWidget {
  const AddressInputField({super.key, required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    // recuperando a cor
    final primaryColor = Theme.of(context).primaryColor;

    // acessando o cartmanager via watch para rebuildar o widget e ter acesso as funções e variaveis da classe cartmanager
    final cartManager = context.watch<CartManager>();

    // criando um validador geral para os campos de endereço
    String? emptyValidator(String? text) => text!.isEmpty ? 'Campo obrigatório' : null;

    // verificando se o zipcode é diferente de null e cartManager.deliveryPrice não tiver calculado para mostrar o widget de endereço
    if (address.zipCode != null && cartManager.deliveryPrice == null) {
      return Column(
        // espaçar os campos , no caso esticar o btn ao máximo
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // rua
          TextFormField(
            cursorColor: primaryColor,
            // desabilitando o campo durante o calculo do frete
            enabled: !cartManager.loading,
            initialValue: address.street,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Rua/Avenida',
              hintText: 'Av. Brasil',
            ),
            validator: emptyValidator,
            // pegando o texto e salvando na variável
            onSaved: (t) => address.street = t,
          ),

          // numero e complemento
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  enabled: !cartManager.loading,
                  initialValue: address.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Número',
                    hintText: '123',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  validator: emptyValidator,
                  onSaved: (t) => address.number = t,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  enabled: !cartManager.loading,
                  initialValue: address.complement,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Complemento',
                    hintText: 'Opcional',
                  ),
                  onSaved: (t) => address.complement = t,
                ),
              ),
            ],
          ),

          // bairro
          TextFormField(
            enabled: !cartManager.loading,
            initialValue: address.district,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Bairro',
              hintText: 'Guanabara',
            ),
            validator: emptyValidator,
            onSaved: (t) => address.district = t,
          ),

          // cidade e uf
          Row(
            children: <Widget>[
              Expanded(
                // flex de 3 para ser o maior 3x do campo uf
                flex: 3,
                child: TextFormField(
                  enabled: false,
                  initialValue: address.city,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Cidade',
                    hintText: 'Campinas',
                  ),
                  validator: emptyValidator,
                  onSaved: (t) => address.city = t,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  autocorrect: false,
                  enabled: false,
                  // especificando que são caracteres
                  textCapitalization: TextCapitalization.characters,
                  initialValue: address.state,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'UF',
                    hintText: 'SP',
                    // setando vazio por conta do max length e não desalinhar o campo na tela
                    counterText: '',
                  ),
                  // permitindo apenas 2 caracteres
                  maxLength: 2,
                  validator: (e) {
                    if (e!.isEmpty) {
                      return 'Campo obrigatório';
                    } else if (e.length != 2) {
                      return 'Inválido';
                    }
                    return null;
                  },
                  onSaved: (t) => address.state = t,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // indicador de carregamento enquanto calcula o frete
          if (cartManager.loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation(primaryColor),
              backgroundColor: Colors.transparent,
            ),
          // botão
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primaryColor.withAlpha(100),
            ),
            onPressed: !cartManager.loading
                ? () async {
                    // validando os campos
                    if (Form.of(context).validate()) {
                      // salvando o endereço
                      Form.of(context).save();
                      try {
                        // acessando o cartManager e mandando o endereço para ele, await pq a função setAdrees é um Future
                        await context.read<CartManager>().setAddress(address);
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
            child: const Text('Calcular Frete'),
          ),
        ],
      );
      // retrair o card de endereço e mostrar widget com resumo do endereço, verificar se cep != null e mostrar o widget
    } else if (address.zipCode != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          '${address.street}, ${address.number}\n${address.district}\n${address.city} - ${address.state}',
        ),
      );
      // se cep for nulo mostrar container vazio para não aparecer null null no card
    } else {
      return Container();
    }
  }
}
