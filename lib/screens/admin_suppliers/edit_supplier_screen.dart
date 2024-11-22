import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';
import 'package:provider/provider.dart';

class EditSupplierScreen extends StatelessWidget {
  // passando um supplier vazio se for novo cadastro e um supplier se for edição
  EditSupplierScreen({super.key, SupplierApp? supplier})
      // verificando que se for edição, o supplier vem preenchido
      : editing = supplier != null,
        // Se for novo cadastro o supplier vem vazio chamando o clone para caso queira descartar as moficicações
        supplierApp = supplier != null ? supplier.clone() : SupplierApp();
  // caso não quiser criar o clone basta = supplierApp = supplier ?? SupplierApp();

  final SupplierApp? supplierApp;

  // variavel para saber se é edição ou novo cadastro
  final bool editing;

  // GlobalKey para validar os campos
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ChangeNotifierProvider.value(
      value: supplierApp,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            // Verificando para mostrar o texto
            editing ? 'Editar ${supplierApp?.name}' : 'Criar Fornecedor',
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
                        title: 'Remover Fornecedor...',
                        content: Text('Deseja realmente remover o fornecedor "${supplierApp?.name}"?'),
                        confirmText: 'Remover',
                        onConfirm: () async {
                          // ação de deletar prd
                          context.read<AdminSuppliersManager>().delete(supplierApp!);
                          // retornando para tela de todos os produtos

                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop(); // fecha a dialog

                          // ignore: use_build_context_synchronously
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
                  initialValue: supplierApp?.name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  keyboardType: TextInputType.text,
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return 'Por favor, insira um nome.';
                    }
                    return null;
                  },
                  onSaved: (name) => supplierApp?.name = name,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),

                // PHONE
                TextFormField(
                  initialValue: supplierApp?.phone,
                  decoration: const InputDecoration(labelText: 'Telefone'),
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
                  onSaved: (phone) => supplierApp?.phone = phone,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),

                // EMAIL
                TextFormField(
                  initialValue: supplierApp?.email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.text,
                  onSaved: (email) => supplierApp?.email = email,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return 'Por favor, insira um email.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // BOTÃO SALVAR
                Consumer<SupplierApp>(
                  builder: (_, supplier, __) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: !supplierApp!.loading
                          ? () async {
                              if (formKey.currentState!.validate()) {
                                // chama o método onSaved de cada campo do formulário
                                formKey.currentState?.save();

                                await supplierApp?.saveData();

                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop();
                              }
                            }
                          : null,
                      child: supplierApp!.loading
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
