import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/helpers/firebase_errors.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ChangeNotifier para obter o notifyListner para mudar o estado e usar o consumer na LoginScreen
class UserManager extends ChangeNotifier {
  // Instanciando UserManager
  UserManager() {
    // Logo que instancia chama o _loadCurrentUser user atual
    _loadCurrentUser();
  }

  // Obtendo instancia Auth do FirebaseAuth
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Obtendo instancia do FirebaseFirestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // obj userApp para para atribuir o novo user a esse objeto e deixar todos os dados disponíveis na userApp
  UserApp? userApp;

  // Boa prática quando utiliza ChangeNotifier para fazer o loading
  // variável para controlar o loading do app
  bool _loading = false;
  // expondo a variavel atraves do getter para pegar o valor em outra classe
  bool get loading => _loading;
  // Função para controlar o loading alterando o estado, setando valor do estado
  set loading(bool value) {
    _loading = value;
    // notifica o consumer na loginScreen, modificando o estado onde estiver observando UserManager
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

  // Verificar se user está logado
  bool get isLoggedIn => userApp != null;

  // Função autenticar user no Firebase e Criando onFail e onSuccess funções callback para tratar exceções
  Future<void> signIn({UserApp? userApp, Function? onFail, Function? onSuccess}) async {
    loading = true;
    // Tratando com try/catch exceções caso user inválido
    try {
      // Metodo para autenticar o usuário via FirebaseAuth
      final UserCredential result = await auth.signInWithEmailAndPassword(
        email: userApp!.email!,
        password: userApp.password!,
      );
      // Resgatando o user atual e passando para _loadCurrentUser
      await _loadCurrentUser(firebaseUser: result.user);
      onSuccess!();
    } on FirebaseAuthException catch (e) {
      // Passando a msg de erro criado no arq FirebaseErrors.dart
      onFail!(getErrorString(e.code));
    }
    loading = false;
  }

  // Metodo que realiza o cadastro em Authentication do Firebase
  Future<void> signUp({UserApp? userApp, Function? onFail, Function? onSuccess}) async {
    loading = true;
    try {
      // Metodo para criar o user no Firebase
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: userApp!.email!,
        password: userApp.password!,
      );
      // Salvando o id do user que acabou de criar no obj userApp
      userApp.id = result.user!.uid;
      // Pegar o user do objeto userApp e atribuir para o this.userApp
      this.userApp = userApp;
      // Salvando os dados do user no Firestore tabela users usando userApp que é onde estão os dados
      await userApp.saveData();

      onSuccess!();
    } on FirebaseAuthException catch (e) {
      onFail!(getErrorString(e.code));
    }
    loading = false;
  }

  // Metodo para deslogar o user
  void signOut() {
    // metodo firebase que desloga
    auth.signOut();
    // seta user null
    userApp = null;
    // Notifica o consumer lá do CustomDrawerHeader
    notifyListeners();
  }

  // Recuperando dados do user no login ao abrir o app
  Future<void> _loadCurrentUser({User? firebaseUser}) async {
    // passando o firebaseuser para recuperar o user atual no signin
    final User? currentUser = firebaseUser ?? auth.currentUser;

    if (currentUser != null) {
      // Acessando a coleção users, pegando uid do user que acabou de logar e dando um get para obter o documento
      final DocumentSnapshot docUser = await firestore.collection('users').doc(currentUser.uid).get();
      // Pegar os documentos lá do fromdocument do UserApp passando o docUser e atribui ao obj userApp
      userApp = UserApp.fromDocument(docUser);
      // Acessar a coleção admins, dar um get para buscar e verificar se o user é um admin
      final docAdmin = await firestore.collection('admins').doc(userApp?.id).get();
      // Habilitando modo admin para user se for admin
      if (docAdmin.exists) {
        userApp!.admin = true;
      }
      // Notifica as alterações para rebuildar
      notifyListeners();
    }
  }

  // get para recuperar o userApp dentro da vairavel adminEnabled, para conseguir acessar de qualquer lugar do app
  bool get adminEnabled => userApp != null && userApp!.admin;

  // metodo recuperar senha
  void recoverPass(String email) {
    auth.sendPasswordResetEmail(email: email);
    notifyListeners();
  }
}
