import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/home/section_item.dart';
import 'package:uuid/uuid.dart';

class Section extends ChangeNotifier {
  // Construtor padrao da seção
  Section({
    this.id,
    this.name,
    this.type,
    this.items,
  }) {
    // caso o item for vazio/nulo, colcar uma nova seção, isso para não dar erro de null
    items = items ?? []; // seção após a modificação
    // Caso o item original seja vazio/nulo, colcar uma nova seção (qdo clonar setar o originalItems como sendo uma lista nova)
    originalItems = List.from(items!); // ou utilizar items as Iterable
  }

  // Construtor obter os dados da seção
  Section.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] as String;
    type = document['type'] as String;
    // Transformando em uma Lista Dinamica de seção e mapeando para um tipo SectionItem
    items = (document['items'] as List).map((i) => SectionItem.fromMap(i as Map<String, dynamic>)).toList();
  }

  // criando a instancia do firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // criando a instancia do storage
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Criando a referencia para fazer o update, forma mais pratica de trabalhar
  DocumentReference get firestoreRef => firestore.doc('home/$id');

  // criando a referencia do storage, mesmo caso que acima, entrando na pasta no storage
  Reference get storageRef => storage.ref().child('home/$id');

  // Variaveis
  String? id;
  String? name;
  String? type;
  // Lista de seções
  List<SectionItem>? items;

  // criando a lista original das seções para edição
  List<SectionItem>? originalItems;

  // criando um error para facilitar a validação dos campos e mostrar o erro na home ao editar e salvar a home
  String? _error;
  // Expondo a variavel error para utilizar em outra classe
  String? get error => _error;
  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  // Adicionar um novo item para adicionar nova imagem
  void addItem(SectionItem item) {
    items!.add(item);
    notifyListeners();
  }

  // Metodo para remover a imagem da lista ou stagered
  void removeItem(SectionItem item) {
    items!.remove(item);
    notifyListeners();
  }

  // metodo salvar, parecido com o salvamento do produto, recebendo a pos no save
  Future<void> save(int pos) async {
    // criando o mapa (padrão de salvamento) para enviar ao firebase
    final Map<String, dynamic> data = {
      'name': name,
      'type': type,
      'pos': pos,
    };

    // verificando se a seção ja existe ou se criamos uma nova sessão
    if (id == null) {
      // criando uma nova seção
      final doc = await firestore.collection('home').add(data);
      // Obtendo o ID do produto que está sendo criado
      id = doc.id;
    } else {
      // atualizando seção acessando a referencia criada lá em cima perto da referencia do firestore
      await firestoreRef.update(data);
    }

    // percorrer cada um dos itens atuais
    for (final item in items!) {
      // verificando se o item tem id
      if (item.image is File) {
        // criando o upload para o firebase, uuid para criar um nome para a imagem, putfile para uploadar o arquivo no caso o item.iimage
        final UploadTask task = storageRef.child(const Uuid().v1()).putFile(item.image as File);
        // criando um await para aguardar o upload
        final TaskSnapshot snapshot = await task.whenComplete(() {});
        // criando o url da imagem
        final String url = await snapshot.ref.getDownloadURL();
        // atualizando a imagem
        item.image = url;
      }
    }

    // excluir imagens lixo, passando por cada um dos itens originais
    for (final original in originalItems!) {
      // verificando se o item foi excluido se ainda existe - verificando se o item original existe
      if (!items!.contains(original) && (original.image as String).contains('firebase')) {
        // tratando exceções
        try {
          // criando a referência da imagem e excluindo ela do firebase
          final ref = storage.refFromURL(original.image as String);
          // excluindo a imagem do firebase
          await ref.delete();
        } catch (e) {
          // tratar o erro retornar algo
          Future.error('Falha ao deletar $e');
        }
      }
    }

    // atualizando os itens da sessão com o ID da sessão atual e os itens da sessão, to map criado no sectionItem, por isso não passa ele no map ali em cima junto com outros campos
    final Map<String, dynamic> itemsData = {'items': items?.map((e) => e.toMap()).toList()};

    // atualizando os itens da sessão
    await firestoreRef.update(itemsData);
  }

  // metodo para deletar
  Future<void> delete() async {
    // deletar os dados do firestore
    await firestoreRef.delete();
    // passar pelas imagens e deletar
    for (final item in items!) {
      // verificar se a imagem está no firestore - inerindo a verificação para o firebase evitando exceções no IOS
      if ((item.image as String).contains('firebase')) {
        try {
          // pegando a referencia da imagem
          final ref = storage.refFromURL(item.image as String);
          // deletando
          await ref.delete();
        } catch (e) {
          Future.error('Falha ao deletar $e');
        }
      }
    }
  }

  // criando metodo valid de validação dos campos
  bool valid() {
    if (name == null || name!.isEmpty) {
      error = 'Título inválido';
    } else if (items!.isEmpty) {
      error = 'Insira ao menos uma imagem';
    } else {
      // se chegar até aqui é pq não tem erro então retorna null
      error = null;
    }
    // retornando se tiver erro retrnar null para validar as seções
    return error == null;
  }

  // Criando o clone da sessão
  Section clone() {
    // retornar construtor
    return Section(
      id: id,
      name: name,
      type: type,
      // Duplicando os obj da lista, se fosse apenas string poderia passar item direto, mas como é lista de items precisa fazer esse map
      items: items?.map((e) => e.clone()).toList(),
    );
  }

  // Gerando toString para verificar os dados no console por exemplo
  @override
  String toString() => 'Section(name: $name, type: $type, items: $items)';
}
