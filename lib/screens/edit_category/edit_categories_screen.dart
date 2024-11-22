// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/category/categories.dart';
import 'package:maria_store/models/category/categories_manager.dart';
import 'package:maria_store/screens/edit_category/components/images_icon.dart';
import 'package:provider/provider.dart';

class EditCategoriesScreen extends StatelessWidget {
  EditCategoriesScreen({super.key, required this.categories});

  // Insstanciando obj categoria
  final Categories categories;

  final TextEditingController name = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return ChangeNotifierProvider.value(
      value: categories,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            categories.id != null ? 'Editar Categoria ${categories.name}' : 'Criar Categoria',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            // Se for uma nova categoria esconde o icone de excluir
            if (categories.id != null)
              IconButton(
                onPressed: () async {
                  // Obtem a função diretamente do cartmanager
                  final inUse = await context.read<CategoriesManager>().isCategoryInUse(categories);

                  showDialog(
                    context: context,
                    builder: (_) {
                      return CustomDialog(
                        title: 'Remover categoria...',
                        content: inUse
                            ? Text(
                                'A categoria "${categories.name}" está em uso. Deseja realmente removê-la? Isso pode afetar produtos vinculados.')
                            : Text('Deseja realmente remover a categoria "${categories.name}"?'),
                        confirmText: 'Remover',
                        onConfirm: () async {
                          if (inUse) {
                            // Confirmou a exclusão mesmo com a categoria em uso
                            context.read<CategoriesManager>().delete(categories);
                            Navigator.of(context).pop(); // Fechar o AlertDialog
                            Navigator.of(context).pop(); // Fechar a tela e voltar para a tela de categorias
                          } else {
                            // Se não estiver em uso, remover normalmente
                            context.read<CategoriesManager>().delete(categories);
                            Navigator.of(context).pop(); // Fechar o AlertDialog
                            Navigator.of(context).pop(); // Fechar a tela e voltar para a tela de categorias
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
                ImagesIcon(categories: categories),

                const SizedBox(height: 20),
                TextFormField(
                  initialValue: categories.name,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                  ),
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return 'Nome obrigatório...';
                    }
                    // Obtendo o objeto CategoriesManager dentro da função por isso usando o read,
                    // ou chama só o obj
                    // final categoriesManager = context.read<CategoriesManager>();
                    // ou a função direto no caso allCategory
                    final categoriesManager = context.read<CategoriesManager>().allCategory;
                    // Adicionando validação personalizada para garantir que a categoria seja única e o que id seja diferente para não confundir com a edição de uma categoria existente
                    if (categoriesManager.any((category) =>
                        category.name?.toLowerCase() == name.toLowerCase() && category.id != categories.id)) {
                      return 'Já existe uma categoria com este nome...';
                    }
                    return null;
                  },
                  onSaved: (name) => categories.name = name,
                ),
                const SizedBox(height: 20),
                Consumer<Categories>(
                  builder: (_, categories, __) {
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: !categories.loading
                            ? () async {
                                if (formKey.currentState!.validate()) {
                                  // Salvar usando onsaved
                                  formKey.currentState!.save();

                                  // Chamado metodo save do Categories
                                  await categories.save();

                                  // Informar o CategoriesManager atraves da função update que houve mudança em uma categoria e atualizar a tela instantaneamente, pq lá que carrego as categorias
                                  context.read<CategoriesManager>().update(categories);

                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        child: categories.loading
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
