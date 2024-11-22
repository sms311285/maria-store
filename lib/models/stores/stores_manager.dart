import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/stores/stores_model.dart';
import 'package:maria_store/services/cepaberto_service.dart';

class StoresManager extends ChangeNotifier {
  // construtor para obter a lista de lojas do firebase e iniciar o timer
  StoresManager() {
    _loadStoreList();
    _startTimer();
  }

  // criando e iniciando a variável para obter a lista de lojas
  List<StoresModel> stores = [];

  // criando variável para obter o timer
  Timer? _timer;

  StoresModel? storesModel;

  Address? address;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // sistema de carregamento
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // função para obter a lista de lojas do firebase
  Future<void> _loadStoreList() async {
    // acessar o firebase e obter todos os documentos da coleção store
    final snapshot = await firestore.collection('stores').get();
    // transformar cada documento em um objeto e depois em uma lista guardando em stores
    stores = snapshot.docs.map((e) => StoresModel.fromDocument(e)).toList();
    // atualizar a tela storesScreen
    notifyListeners();
  }

  // função para iniciar o timer periodico e passando o tempo de execução
  void _startTimer() {
    // iniciando o timer e passando o tempo de execução
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // chamar a função _checkOpening
      _checkOpening();
    });
  }

  // função para atualizar o status
  void _checkOpening() {
    // percorrer a lista de lojas e atualizar o status
    for (final store in stores) {
      // chamar a função updateStatus para atualizar o status
      store.updateStatus();
    }
    notifyListeners();
  }

  // Função para buscar as lojas pelo ID
  StoresModel? findStoreById(String id) {
    // Tratando exceção caso não encontre o prd
    try {
      // Pesquisar e Retornar o primeiro item que for igual ao ID
      return stores.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // endereço - função para obter o cep
  // ADDRESS
  Future<void> getAddress(String cep) async {
    // carregamento
    loading = true;

    // criando a variavel para receber o cep - enviar para cepaberto service
    final cepAbertoService = CepAbertoService();
    // tratando exceções
    try {
      // obter o endereço atraves da API
      final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);

      // transformando o endereço do app a partir do construtor gerado em Address.dart
      if (cepAbertoAddress != null) {
        // declarando address a partir do obj decxlarado lem cima
        address = Address(
          street: cepAbertoAddress.logradouro,
          district: cepAbertoAddress.bairro,
          zipCode: cepAbertoAddress.cep,
          city: cepAbertoAddress.cidade.nome,
          state: cepAbertoAddress.estado.sigla,
          lat: cepAbertoAddress.latitude,
          long: cepAbertoAddress.longitude,
        );
      }
      // encerrando carregamento
      loading = false;
    } catch (e) {
      // encerrando carregamento
      loading = false;
      return Future.error('CEP Inválido...');
    }
  }

  // função para remover o cep atual informado (serve para edição do cep na tela de entrega)
  void removeAddress() {
    // setando nulo no address
    address = null;
    notifyListeners();
  }

  // função para encerrar o timer
  @override
  void dispose() {
    // cancelando o timer
    super.dispose();
    _timer?.cancel();
  }
}
