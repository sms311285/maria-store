import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/stores/stores_manager.dart';
import 'package:maria_store/models/stores/stores_model.dart';
import 'package:maria_store/screens/stores/components/address_input_store.dart';
import 'package:maria_store/screens/stores/components/cep_input_store.dart';
import 'package:maria_store/screens/stores/components/images_store.dart';
import 'package:provider/provider.dart';

class EditStoreScreen extends StatelessWidget {
  EditStoreScreen({super.key, StoresModel? s})
      : editing = s != null,
        store = s != null ? s.clone() : StoresModel();

  final StoresModel store;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final bool editing;

  @override
  Widget build(BuildContext context) {
    // cor padrão

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? 'Editar ${store.name}' : 'Criar Loja',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (editing)
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                // excluir Loja
              },
            ),
        ],
      ),
      body: Consumer<StoresManager>(
        builder: (_, storesManager, __) {
          // carregando endereço
          final address = storesManager.address ?? store.address ?? Address();

          return Card(
            margin: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 8),
            child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  const Text('Selecionar Imagem:'),
                  const SizedBox(height: 10.0),
                  ImagesStore(store: store),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // NOME
                      TextFormField(
                        initialValue: store.name,
                        decoration: const InputDecoration(labelText: 'Nome: '),
                        //validator: (name) => name!.isEmpty ? 'Nome obrigatório' : null,
                        onSaved: (name) => store.name = name,
                      ),

                      // PHONE
                      TextFormField(
                        initialValue: store.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone: ',
                          hintText: '(99) 99123-4567',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TelefoneInputFormatter(),
                        ],
                        //validator: (phone) => phone!.isEmpty ? 'Telefone obrigatório' : null,
                        onSaved: (phone) => store.phone = phone,
                      ),

                      const SizedBox(height: 20),

                      // CAMPOS DO ENDEREÇO
                      const Text(
                        'Endereço:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),

                      const SizedBox(height: 5),

                      CepInputStore(store: store, address: address),

                      AddressInputStore(store: store, address: address),

                      const SizedBox(height: 20),

                      // HORÁRIOS DE FUNCIONAMENTO
                      const Text(
                        'Horários de funcionamento:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: store.formattedPeriod(store.opening?['monfri']),
                              decoration: const InputDecoration(
                                labelText: 'Horário Seg-Sex:',
                                hintText: '08:00-18:00',
                              ),
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final times = value.split('-');
                                  store.opening?['monfri'] = {
                                    "from": TimeOfDay(
                                      hour: int.parse(times[0].split(':')[0]),
                                      minute: int.parse(times[0].split(':')[1]),
                                    ),
                                    "to": TimeOfDay(
                                      hour: int.parse(times[1].split(':')[0]),
                                      minute: int.parse(times[1].split(':')[1]),
                                    ),
                                  };
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: store.formattedPeriod(store.opening?['saturday']),
                              decoration: const InputDecoration(
                                labelText: 'Horário Sábado:',
                                hintText: '08:00-18:00',
                              ),
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final times = value.split('-');
                                  store.opening?['saturday'] = {
                                    "from": TimeOfDay(
                                      hour: int.parse(times[0].split(':')[0]),
                                      minute: int.parse(times[0].split(':')[1]),
                                    ),
                                    "to": TimeOfDay(
                                      hour: int.parse(times[1].split(':')[0]),
                                      minute: int.parse(times[1].split(':')[1]),
                                    ),
                                  };
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: store.formattedPeriod(store.opening?['sunday']),
                              decoration: const InputDecoration(
                                labelText: 'Horário Domingo:',
                                hintText: '08:00-18:00',
                              ),
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final times = value.split('-');
                                  store.opening?['sunday'] = {
                                    "from": TimeOfDay(
                                      hour: int.parse(times[0].split(':')[0]),
                                      minute: int.parse(times[0].split(':')[1]),
                                    ),
                                    "to": TimeOfDay(
                                      hour: int.parse(times[1].split(':')[0]),
                                      minute: int.parse(times[1].split(':')[1]),
                                    ),
                                  };
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // botão
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Salvar',
                            style: TextStyle(fontSize: 18),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              // Salva o endereço atualizado no modelo de loja
                              store.address = address;
                              // Aqui você pode adicionar a lógica para salvar o `store` no Firebase
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
