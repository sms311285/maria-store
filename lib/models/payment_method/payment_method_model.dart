import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PaymentMethodModel extends ChangeNotifier {
  // Variaveis
  String? id;
  String? name;
  String? image;
  int? installmentsOrder;
  int? installmentsPurchase;
  bool? deleted;

  // Instanciando firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Instanciando o storage
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Criando uma referencia pegando os dados atuais para salvar, obtendo o documento relativo a forma pgto (id) que estou editando
  DocumentReference get firestoreRef => firestore.doc('paymentmethod/$id');

  // Criando a referencia do storage e criando as pastas com id do prd acessando o ref pasta principal
  Reference get storageRef => storage.ref().child('paymentmethod').child(id!);

  // Variavel para salvar as novas imagens de uma lista dinamica para aceitar tanto de file ou url
  dynamic newImage;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Construtor
  PaymentMethodModel({
    this.name,
    this.id,
    this.image,
    this.installmentsOrder,
    this.installmentsPurchase,
    this.deleted = false,
  });

  // Construtor - Sempre converte os dados do firebase em objeto no construtor para ficar mais prático recuperar os dados objeto
  PaymentMethodModel.fromDocument(DocumentSnapshot document) {
    // Dados da forma pgto
    id = document.id;
    name = document['name'] as String;
    image = document['image'] as String;
    installmentsOrder = document['installmentsOrder'] as int;
    installmentsPurchase = document['installmentsPurchase'] as int;
    deleted = (document['deleted'] ?? false) as bool;
  }

  // Salvar os dados no firebase
  Future<void> save() async {
    loading = true;

    // Map padrão do firebase para salvar dados e enviar ao firebase
    final Map<String, dynamic> data = {
      'name': name,
      'installmentsOrder': installmentsOrder,
      'installmentsPurchase': installmentsPurchase,
      'deleted': deleted,
    };

    // Verificar se o forma pgto já existe ou se está criando
    if (id == null) {
      // Criando acessando a coleção e adicionando os dados
      final doc = await firestore.collection('paymentmethod').add(data);
      // Obtendo o ID do produto que está sendo criado
      id = doc.id;
    } else {
      // Atualizando, pegando a referência (Criada ali em cima) do catagoria e atualizando os dados
      await firestoreRef.update(data);
    }

    // Declarando a URL da imagem atualizada
    String? updateImage;

    // Salvando a imagem
    if (newImage != null) {
      if (image == newImage) {
        // Se a imagem não mudou, mantenha a mesma URL
        updateImage = newImage as String;
      } else {
        // Se a imagem mudou, suba a nova imagem no storage
        final UploadTask task = storageRef.child(const Uuid().v1()).putFile(newImage as File);
        final TaskSnapshot snapshot = await task.whenComplete(() {});
        updateImage = await snapshot.ref.getDownloadURL();

        // Remover a imagem antiga do storage se necessário
        if (image != null && image!.contains('firebase')) {
          try {
            final ref = storage.refFromURL(image!);
            await ref.delete();
          } catch (e) {
            Future.error('Falha ao deletar imagem $e');
          }
        }
      }
    }

    // Atualizando a URL da imagem no Firestore
    await firestoreRef.update({'image': updateImage});

    // Atualizando a URL da imagem na variável da classe
    image = updateImage;

    loading = false;
  }

  void delete() {
    firestoreRef.update({'deleted': true});
  }
}
