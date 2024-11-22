import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/helpers/validators.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Pegando o objeto userApp iniciando com usuário vazio, para usar no onSaved e obter os campos
  // E passar os dados para ele para poder enviar lá para o UserManager
  final UserApp userApp = UserApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Crie sua conta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          // Formulario
          child: Form(
            key: formKey,
            // Consumer para usar o loading para o btn cadastrar
            child: Consumer<UserManager>(
              builder: (_, userManager, __) {
                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  children: <Widget>[
                    // Nome
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Nome Completo'),
                      // Desativando o campo se não estiver carregando
                      enabled: !userManager.loading,
                      validator: (name) {
                        if (name!.isEmpty) {
                          return 'Campo Obrigatório';
                        } else if (name.trim().split(' ').length <= 1) {
                          return 'Preencha seu nome completo';
                        }
                        return null;
                      },
                      // Passando onsaved para salvar diretamente, outra opção ao inves de criar controladores
                      onSaved: (name) => userApp.name = name,
                    ),
                    const SizedBox(height: 16.0),
                    // Email
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      enabled: !userManager.loading,
                      keyboardType: TextInputType.emailAddress,
                      validator: (email) {
                        if (email!.isEmpty) {
                          return 'Campo Obrigatório';
                        } else if (!emailValid(email)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                      onSaved: (email) => userApp.email = email,
                    ),
                    const SizedBox(height: 16.0),
                    // Phone
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Telefone'),
                      enabled: !userManager.loading,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter(),
                      ],
                      validator: (phone) {
                        if (phone!.isEmpty) {
                          return 'Campo Obrigatório';
                        } else if (phone.length != 15) {
                          return 'Telefone Inválido';
                        }
                        return null;
                      },
                      onSaved: (phone) => userApp.phone = phone,
                    ),
                    const SizedBox(height: 16.0),
                    // Senha
                    TextFormField(
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
                      enabled: !userManager.loading,
                      obscureText: userManager.obscureText,
                      validator: (pass) {
                        if (pass!.isEmpty) {
                          return 'Campo Obrigatório';
                        } else if (pass.length < 6) {
                          return 'Senha muito curta';
                        }
                        return null;
                      },
                      onSaved: (pass) => userApp.password = pass,
                    ),
                    const SizedBox(height: 16.0),
                    // Repetir senha
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Repita a Senha',
                        suffixIcon: IconButton(
                          onPressed: () {
                            userManager.obscureConfirmText = !userManager.obscureConfirmText;
                          },
                          icon: Icon(
                            userManager.obscureConfirmText ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      enabled: !userManager.loading,
                      obscureText: userManager.obscureConfirmText,
                      validator: (pass) {
                        if (pass!.isEmpty) {
                          return 'Campo Obrigatório';
                        } else if (pass.length < 6) {
                          return 'Senha muito curta';
                        }
                        return null;
                      },
                      onSaved: (pass) => userApp.confirmPassword = pass,
                    ),
                    const SizedBox(height: 16.0),
                    // Btn Cadastrar
                    SizedBox(
                      height: 44.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
                        ),
                        onPressed: userManager.loading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  // Chamando o método onsave de cada um dos form
                                  formKey.currentState!.save();

                                  // Validando se as senhas são iguais
                                  if (userApp.password != userApp.confirmPassword) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Senhas diferentes!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  // Pegar todos os campos de textos colocar no objeto de usuário e enviar ao UserManager
                                  userManager.signUp(
                                    // Passando obj usuário com os dados
                                    userApp: userApp,
                                    onSuccess: () {
                                      Navigator.of(context).pop();
                                    },
                                    onFail: (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Falha ao criar conta: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                        child: userManager.loading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Criar Conta',
                                style: TextStyle(fontSize: 18.0),
                              ),
                      ),
                    )
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
