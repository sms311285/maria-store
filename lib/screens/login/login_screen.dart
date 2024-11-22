import 'package:flutter/material.dart';
import 'package:maria_store/helpers/validators.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Entrar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // pushReplacementNamed - Substituir tela de login pela de cadastro
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            child: const Text(
              'CRIAR CONTA',
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          )
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          // Formulario
          child: Form(
            key: formKey,
            // Consumer = Widget consumidor fica observando as mudanças no UserManager e rebuildar os filhos caso o estado mude
            child: Consumer<UserManager>(
              // child ou __ é uma forma de não rebuildar algum widget dentro do builder
              builder: (_, userManager, __) {
                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  // Para o listview ocupar o menor altura possível
                  shrinkWrap: true,
                  children: <Widget>[
                    // Campos de txt
                    TextFormField(
                      controller: emailController,
                      // habilitar o btn se não estiver carregando
                      enabled: !userManager.loading,
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (email) {
                        if (!emailValid(email!)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: passController,
                      enabled: !userManager.loading,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        suffixIcon: IconButton(
                          onPressed: () {
                            userManager.obscureText = !userManager.obscureText;
                          },
                          icon: Icon(
                            userManager.obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      autocorrect: false,
                      obscureText: userManager.obscureText,
                      validator: (pass) {
                        if (pass!.length < 6 || pass.isEmpty) {
                          return 'Senha inválida';
                        }
                        return null;
                      },
                    ),
                    // Btn esqueci minha senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: Consumer<UserManager>(
                        builder: (_, userManager, __) {
                          return TextButton(
                            onPressed: () {
                              if (emailController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Insira seu e-mail para recuperação.'),
                                    backgroundColor: Colors.redAccent,
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              } else {
                                userManager.recoverPass(emailController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'E-mail enviado para redefinição de senha, confira também sua caixa de spam.'),
                                    backgroundColor: Colors.blue,
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Esqueci minha senha',
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Btn entrar
                    SizedBox(
                      height: 44.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          // Cor quando desativado
                          disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
                        ),
                        // chamando loading do UserManager para bloquear ou não os campos
                        onPressed: userManager.loading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  userManager.signIn(
                                    // Usando obj UserApp pegando email e password do UserApp passado no construtor e enviando os dados p UserApp
                                    userApp: UserApp(
                                      email: emailController.text,
                                      password: passController.text,
                                    ),
                                    // Função callback anonima para chamar o erro da UserManager
                                    onFail: (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Falha ao entrar: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    onSuccess: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }
                              },
                        // Chamando o loading
                        child: userManager.loading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(fontSize: 18.0),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
