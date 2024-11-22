import 'package:flutter/material.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/screens/address/components/address_input_filed.dart';
import 'package:maria_store/screens/address/components/cep_input_field.dart';
import 'package:provider/provider.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        // modificando/observando o estado do card endereço
        child: Consumer<CartManager>(
          builder: (_, cartManager, __) {
            // acessando o addres do cartmanager, setando que pode ser nulo retornando um novo obj Address
            final address = cartManager.address ?? Address();

            // criando um form para textfield criado em outro widget que é CepInputField
            return Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Endereço de entrega',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // chamado o widget separado
                  CepInputField(address: address),

                  // chamado widget de endereço, passando o address por parametro para ter acesso ao address do cartmanager
                  AddressInputField(address: address),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
