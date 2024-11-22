import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SupplierApp extends ChangeNotifier {
  String? id;
  String? name;
  String? email;
  String? phone;

  // variavel para controlar o exclusão do user
  bool? deleted;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Criando as referencias de usuário para organizar o código e aproveitar smp que precisar
  DocumentReference get firestoreRef => FirebaseFirestore.instance.doc('suppliers/$id');

  // Construtor para criar um novo fornecedor
  SupplierApp({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.deleted = false,
  });

  // Clonando o supplier para caso queira descartar as alterações
  SupplierApp clone() {
    return SupplierApp(
      id: id,
      name: name,
      email: email,
      phone: phone,
      deleted: deleted,
    );
  }

  // RECUPERANDO DADOS DO DOCUMENTO
  SupplierApp.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] as String;
    email = document['email'] as String;
    phone = document['phone'] as String;
    deleted = (document['deleted'] ?? false) as bool;
  }

  // sistema de carregamento
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Metodo Salvando os dados do user no Firestore
  Future<void> saveData() async {
    loading = true;
    // verificando se a seção ja existe ou se criamos uma nova sessão
    if (id == null) {
      // criando uma nova seção
      final doc = await firestore.collection('suppliers').add(toMap());
      // Obtendo o ID do produto que está sendo criado
      id = doc.id;
    } else {
      // atualizando seção acessando a referencia criada lá em cima perto da referencia do firestore
      await firestoreRef.update(toMap());
    }
    loading = false;
    notifyListeners();
  }

  // Criando função map para transformar os dados em um map e usar no saveData passando no set
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'deleted': deleted,
    };
  }

  void delete() {
    firestoreRef.update({'deleted': true});
  }
}
