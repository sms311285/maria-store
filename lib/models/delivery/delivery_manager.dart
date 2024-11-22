import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveryManager extends ChangeNotifier {
  // Instancia para carregar os dados na tela classe card delivery
  DeliveryManager() {
    loadDataDelivery();
  }

  // instancia firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // variaveis
  num? base;
  num? km;
  num? lat;
  num? long;
  num? maxkm;

  // Criando uma referencia pegando os dados atuais para salvar, obtendo o documento relativo a categoria (id) que estou editando
  DocumentReference get firestoreRef => firestore.doc('aux/delivery');

  // carregamento
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Método para carregar os dados de entrega
  Future<void> loadDataDelivery() async {
    loading = true;
    try {
      // Obtém a referencia da coleção aux/delivery
      final DocumentSnapshot doc = await firestoreRef.get();

      // Verifica se o documento existe
      if (doc.exists) {
        // Atribui os valores do documento às variáveis da classe
        base = doc['base'] as num;
        km = doc['km'] as num;
        lat = doc['lat'] as num;
        long = doc['long'] as num;
        maxkm = doc['maxkm'] as num;

        loading = false;
        // Notifica os listeners para atualizar a UI, se necessário
        notifyListeners();
      }
    } catch (e) {
      loading = false;
      Future.error('Erro ao carregar dados: $e');
    }
  }

  Future<void> save() async {
    loading = true;
    try {
      // transformando os dados em um map
      final Map<String, dynamic> data = {
        'base': base,
        'km': km,
        'lat': lat,
        'long': long,
        'maxkm': maxkm,
      };

      // verifica se o documento já existe
      final documentSnapshot = await firestoreRef.get();
      if (documentSnapshot.exists) {
        // atualiza os dados
        await firestoreRef.update(data);
      } else {
        // salva os dados
        await firestoreRef.set(data);
      }

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      Future.error('Erro ao salvar dados: $e');
    }
  }
}
