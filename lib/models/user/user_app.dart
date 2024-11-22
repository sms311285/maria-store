import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/helpers/firebase_errors.dart';
import 'package:maria_store/models/address/address.dart';

class UserApp extends ChangeNotifier {
  // Variaveis
  String? id;
  String? email;
  String? password;
  String? name;
  String? confirmPassword;
  String? cpf;
  String? phone;
  // Variavel controlar admin
  bool admin = false;

  // variavel para controlar o exclusão do user
  bool? deleted;

  // isntanciando o endereço do usuario
  Address? address;

  // Criando as referencias de usuário para organizar o código e aproveitar smp que precisar
  DocumentReference get firestoreRef => FirebaseFirestore.instance.doc('users/$id');

  // Pegando a referencia do carrinho para o usuario referencia da coleção usuário
  CollectionReference get cartReference => firestoreRef.collection('cart');

  // Pegando a referencia do carrinho para o usuario referencia da coleção usuário
  CollectionReference get bagReference => firestoreRef.collection('bag');

  // Pegando a referencia do favoritos para o usuario
  CollectionReference get favoritesReference => firestoreRef.collection('favorites');

  // Obtendo instancia Auth do FirebaseAuth
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Construtor
  UserApp({
    this.id,
    this.email,
    this.password,
    this.name,
    this.confirmPassword,
    this.cpf,
    this.phone,
    this.deleted = false,
  });

  UserApp clone() {
    return UserApp(
      id: id,
      email: email,
      name: name,
      cpf: cpf,
      phone: phone,
      deleted: deleted,
      //address: address,
    );
  }

  // Construtor para recuperar o user e para receber o documento gerado no UserManager para gerar objeto (que contém os dados do user) atravez do documento
  UserApp.fromDocument(DocumentSnapshot document) {
    id = document.id;
    // as String pq lem baixo eu criei um map dynamic
    name = document['name'] as String;
    email = document['email'] as String;

    // se mexer aqui define dataMap pois assim ele não cria o campo no firebase e não dá erro de falta de campo
    //cpf = document['cpf'] as String?; Se foi definido campo null no toMap() não precisa mexer aqui
    //phone = document['phone'] as String?; // isso por conta deste map para chamar no metodo salvar

    // o método document.data() retorna um Object?, e você precisa convertê-lo explicitamente para um Map<String, dynamic> antes de usar o containsKey
    Map<String, dynamic> dataMap = document.data() as Map<String, dynamic>;

    // deletar user passando false fazendo a verificação caso se não houver o campo assume que não está eletado outra forma de setar o campo como null ou outra info
    deleted = (document['deleted'] ?? false) as bool;

    // Verificar se o campo 'cpf' existe antes de atribuir
    cpf = dataMap.containsKey('cpf') ? dataMap['cpf'] as String? : null;

    // Verificar se o campo 'phone' existe antes de atribuir
    phone = dataMap.containsKey('phone') ? dataMap['phone'] as String? : null;

    // obter dados do endereço do firebase, se conter endereço no firebase
    if (dataMap.containsKey('address')) {
      // buscando atraves do fromMap criado no Address
      address = Address.fromMap(dataMap['address'] as Map<String, dynamic>);
    }
  }

  // sistema de carregamento
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Função para controle do icone olho na visibilidade de senha
  bool _obscureText = true;
  bool get obscureText => _obscureText;
  set obscureText(bool value) {
    _obscureText = value;
    notifyListeners();
  }

  // Função para controle do icone olho na visibilidade de confirmação senha
  bool _obscureConfirmText = true;
  bool get obscureConfirmText => _obscureConfirmText;
  set obscureConfirmText(bool value) {
    _obscureConfirmText = value;
    notifyListeners();
  }

  // Metodo que realiza o cadastro em Authentication do Firebase
  Future<void> saveAuthentication({Function? onFail, required Function onSuccess}) async {
    loading = true;
    try {
      // Metodo para criar o user no Firebase
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      // Salvando o id do user que acabou de criar no obj userApp
      id = result.user!.uid;

      // Salvando os dados do user no Firestore tabela users usando userApp que é onde estão os dados
      await saveData();

      // Desconecta o usuário após o cadastro - Se o user sair e entrar terá que logar novamente, enquanto ele não fizer isso continua navegando normalmente
      await auth.signOut();

      onSuccess();
    } on FirebaseAuthException catch (e) {
      onFail!(getErrorString(e.code));
    }
    loading = false;
  }

  // Metodo Salvando os dados do user no Firestore
  Future<void> saveData() async {
    loading = true;
    // Usando a referencia do user para salvar os dados
    await firestoreRef.set(toMap());
    loading = false;
    notifyListeners();
  }

  // Criando função map para transformar os dados em um map e usar no saveData passando no set
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'deleted': deleted,
      // salvando o endereço somente se o address for diferente de nulo e passando o toMap (criado lá no address) pois salva no firestore como mapa
      if (address != null) 'address': address!.toMap(),
      // passando null ou vazio para o campo ser criado no firebase
      //'cpf': cpf ?? '', // Envia o CPF como vazio se não for informado, informando aqui não precisa mexer no construtor UserApp.fromDocument ele cria os campos no BD
      //'phone': phone ?? '', // isso por conta deste map para chamar no metodo salvar
      if (cpf != null) 'cpf': cpf ?? '',
      if (phone != null) 'phone': phone ?? '',
    };
  }

  // deletando o user  setando o campo deleted no firebase como true
  void delete() {
    firestoreRef.update({'deleted': true});
  }

  // metodo para setar e salvar o endereço do user, recebendo o endereço
  void setAddress(Address address) {
    // pegando o endereço e salvanado no objeto usuario
    this.address = address;

    // chamando o metodo para salvar os dados dando o toMap conforme o metodo criado logo acima
    saveData();
  }

  // metodo para setar e salvar o cpf do user, recebendo o cpf
  void setCpf(String? cpf) {
    this.cpf = cpf;
    saveData();
  }

  // metodo para setar e salvar o phone do user, recebendo o phone
  void setPhone(String? phone) {
    this.phone = phone;
    saveData();
  }
}
