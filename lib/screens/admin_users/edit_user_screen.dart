import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:provider/provider.dart';

class EditUserScreen extends StatelessWidget {
  // passando um supplier vazio se for novo cadastro e um supplier se for edição
  EditUserScreen({super.key, UserApp? user})
      // verificando que se for edição, o supplier vem preenchido
      : editing = user != null,
        // Se for novo cadastro o user vem vazio chamando o clone para caso queira descartar as moficicações
        userApp = user != null ? user.clone() : UserApp();
  // caso não quiser criar o clone basta = supplierApp = supplier ?? SupplierApp();

  final UserApp? userApp;

  // variavel para saber se é edição ou novo cadastro
  final bool editing;

  // GlobalKey para validar os campos
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ChangeNotifierProvider.value(
      value: userApp,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            // Verificando para mostrar o texto
            editing ? 'Editar ${userApp?.name}' : 'Criar Usuário',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            if (editing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  showDialog(
                    // ignore: use_build_context_synchronously
                    context: context,
                    builder: (_) {
                      return CustomDialog(
                        title: 'Remover Usuário...',
                        content: Text('Deseja realmente remover o usuário "${userApp?.name}"?'),
                        confirmText: 'Remover',
                        onConfirm: () async {
                          // ação de deletar prd
                          context.read<AdminUsersManager>().delete(userApp!);
                          // retornando para tela de todos os produtos
                          Navigator.of(context).pop(); // fecha a dialog
                          Navigator.of(context).pop(); // fecha a tela de edição de prd
                        },
                        onCancel: () => Navigator.of(context).pop(),
                      );
                    },
                  );
                },
              )
          ],
        ),
        body: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: <Widget>[
                // NOME
                TextFormField(
                  initialValue: userApp?.name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  keyboardType: TextInputType.text,
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return 'Por favor, insira um nome.';
                    }
                    return null;
                  },
                  onSaved: (name) => userApp?.name = name,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),

                // EMAIL
                TextFormField(
                  initialValue: userApp?.email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'usuario@example.com',
                  ),
                  keyboardType: TextInputType.text,
                  onSaved: (email) => userApp?.email = email,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return 'Por favor, insira um email.';
                    }
                    return null;
                  },
                ),

                // PHONE
                TextFormField(
                  initialValue: userApp?.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(99) 99123-4567',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter(),
                  ],
                  validator: (phone) {
                    if (phone == null || phone.isEmpty) {
                      return 'Por favor, insira um telefone.';
                    }
                    return null;
                  },
                  onSaved: (phone) => userApp?.phone = phone,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),

                // consumer para funcionar o olho da senha
                Consumer<UserApp>(
                  builder: (_, user, __) {
                    if (!editing) {
                      return Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Senha',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  user.obscureText = !user.obscureText;
                                },
                                icon: Icon(
                                  user.obscureText ? Icons.visibility : Icons.visibility_off,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            enabled: !user.loading,
                            obscureText: user.obscureText,
                            validator: (pass) {
                              if (pass!.isEmpty) {
                                return 'Campo Obrigatório';
                              } else if (pass.length < 6) {
                                return 'Senha muito curta';
                              }
                              return null;
                            },
                            onSaved: (pass) => userApp!.password = pass,
                          ),

                          // Repetir senha
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Repita a Senha',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  userApp!.obscureConfirmText = !userApp!.obscureConfirmText;
                                },
                                icon: Icon(
                                  userApp!.obscureConfirmText ? Icons.visibility : Icons.visibility_off,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            enabled: !userApp!.loading,
                            obscureText: userApp!.obscureConfirmText,
                            validator: (pass) {
                              if (pass!.isEmpty) {
                                return 'Campo Obrigatório';
                              } else if (pass.length < 6) {
                                return 'Senha muito curta';
                              }
                              return null;
                            },
                            onSaved: (pass) => userApp!.confirmPassword = pass,
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),

                // ENDEREÇO CONFIGURAR BUSCA DE CEP USANDO API

                const SizedBox(height: 20),

                // BOTÃO SALVAR
                Consumer<UserApp>(
                  builder: (_, user, __) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: !userApp!.loading
                          ? () async {
                              if (formKey.currentState!.validate()) {
                                // chama o método onSaved de cada campo do formulário
                                formKey.currentState?.save();

                                await userApp?.saveAuthentication(onSuccess: () {});

                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop();
                              }
                            }
                          : null,
                      child: userApp!.loading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(color: Colors.white),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
