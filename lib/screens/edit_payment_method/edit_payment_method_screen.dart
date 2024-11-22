// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/screens/edit_payment_method/components/images_payment_method.dart';
import 'package:provider/provider.dart';

class EditPaymentMethodScreen extends StatelessWidget {
  EditPaymentMethodScreen({super.key, required this.paymentMethodModel});

  // Insstanciando obj forma pgto
  final PaymentMethodModel paymentMethodModel;

  final TextEditingController name = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider.value(
      value: paymentMethodModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            paymentMethodModel.id != null
                ? 'Editar Forma de Pagamento ${paymentMethodModel.name}'
                : 'Criar Forma de Pagamento',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            // Se for uma nova forma pgto esconde o icone de excluir
            if (paymentMethodModel.id != null)
              IconButton(
                onPressed: () async {
                  final inUse = await context.read<PaymentMethodManager>().isPaymentMethodInUse(paymentMethodModel);

                  showDialog(
                    context: context,
                    builder: (_) {
                      return CustomDialog(
                        title: 'Remover forma de pagamento...',
                        content: inUse
                            ? Text(
                                'A forma de pagamento "${paymentMethodModel.name}" está em uso. Deseja realmente removê-la? Isso pode afetar compras ou vendas vinculadas.')
                            : Text('Deseja realmente remover a forma de pagamento "${paymentMethodModel.name}"?'),
                        confirmText: 'Remover',
                        onConfirm: () async {
                          if (inUse) {
                            // Confirmou a exclusão mesmo com a forma de pagamento em uso
                            context.read<PaymentMethodManager>().delete(paymentMethodModel);
                            Navigator.of(context).pop(); // Fechar o AlertDialog
                            Navigator.of(context).pop(); // Fechar a tela e voltar para a tela de forma de pagamentos
                          } else {
                            // Se não estiver em uso, remover normalmente
                            context.read<PaymentMethodManager>().delete(paymentMethodModel);
                            Navigator.of(context).pop(); // Fechar o AlertDialog
                            Navigator.of(context).pop(); // Fechar a tela e voltar para a tela de forma de pagamentos
                          }
                        },
                        onCancel: () => Navigator.of(context).pop(),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: formKey,
            child: ListView(
              // Ocupar espaço de acordo com conteudo
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Text('Selecionar Ícone:'),
                const SizedBox(height: 10),

                // Widget para a seleção de imagem
                ImagesPaymentMethod(paymentMethodModel: paymentMethodModel),

                const SizedBox(height: 20),
                TextFormField(
                  initialValue: paymentMethodModel.name,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                  ),
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return 'Nome obrigatório...';
                    }
                    // Obtendo o objeto PaymentMethodManager dentro da função por isso usando o read,
                    // ou chama só o obj
                    // final PaymentMethodManager = context.read<PaymentMethodManager>();
                    // ou a função direto no caso allPaymentMethod
                    final paymentMethodManager = context.read<PaymentMethodManager>().allPaymentMethod;
                    // Adicionando validação personalizada para garantir que a forma pgto seja única e o que id seja diferente para não confundir com a edição de uma forma pgto existente
                    if (paymentMethodManager.any((paymentMethod) =>
                        paymentMethod.name?.toLowerCase() == name.toLowerCase() &&
                        paymentMethod.id != paymentMethodModel.id)) {
                      return 'Já existe uma forma de pagamento com este nome...';
                    }
                    return null;
                  },
                  onSaved: (name) => paymentMethodModel.name = name,
                ),

                // campo número de parcelas venda
                TextFormField(
                  initialValue: paymentMethodModel.installmentsOrder.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Número de parcelas Vendas',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (installmentsOrder) =>
                      paymentMethodModel.installmentsOrder = int.parse(installmentsOrder ?? '0'),
                ),

                const SizedBox(height: 20),

                // campo número de parcelas compra
                TextFormField(
                  initialValue: paymentMethodModel.installmentsPurchase.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Número de parcelas Compras',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (installmentsPurchase) =>
                      paymentMethodModel.installmentsPurchase = int.parse(installmentsPurchase ?? '0'),
                ),

                const SizedBox(height: 20),

                Consumer<PaymentMethodModel>(
                  builder: (_, paymentMethodModel, __) {
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: !paymentMethodModel.loading
                            ? () async {
                                if (formKey.currentState!.validate()) {
                                  // Salvar usando onsaved
                                  formKey.currentState!.save();

                                  // Chamado metodo save do paymentMethodModel
                                  await paymentMethodModel.save();

                                  // Informar o PaymentMethodManager atraves da função update que houve mudança em uma forma pgto e atualizar a tela instantaneamente, pq lá que carrego as forma pgtos
                                  context.read<PaymentMethodManager>().update(paymentMethodModel);

                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        child: paymentMethodModel.loading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(fontSize: 18),
                              ),
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
