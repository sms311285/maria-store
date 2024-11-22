import 'package:flutter/material.dart';
import 'package:maria_store/common/commons/custom_dialog.dart';
import 'package:maria_store/models/category/categories.dart';
import 'package:maria_store/models/category/categories_manager.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/product/product_manager.dart';
import 'package:maria_store/screens/edit_product/components/images_form.dart';
import 'package:maria_store/screens/edit_product/components/sizes_form.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatelessWidget {
  // Antes Passando product no construtor para pegar o parametro
  EditProductScreen({super.key, Product? p})
      // Agora Passando um produto nulo caso for cadastrar um novo produto
      : editing = p != null,
        // p.clone() para clonar o objeto para nao alterar o prd original até salvar, caso volte a tela, descarta todas as alterações
        product = p != null ? p.clone() : Product();

  // Passando product por parametro para tela
  final Product product;

  // Se for editar ou criar apresentar o texto no topo da tela
  final bool editing;

  // GlobalKey para validar os campos
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Chamando o Provider para passar o obj product para tbm indicar o carregamento do btn
    return ChangeNotifierProvider.value(
      value: product,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            // Verificando para mostrar o texto
            editing ? 'Editar ${product.name}' : 'Criar Produto',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: <Widget>[
            if (editing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return CustomDialog(
                        title: 'Remover Produto...',
                        content: Text('Deseja realmente remover o produto "${product.name}"?'),
                        confirmText: 'Remover',
                        onConfirm: () {
                          // ação de deletar prd
                          context.read<ProductManager>().delete(product);
                          // retornando para tela de todos os produtos
                          Navigator.of(context).pop(); // fecha a dialog
                          Navigator.of(context).pop(); // fecha a tela de edição de prd
                          Navigator.of(context).pop(); // fecha a tela de produto
                        },
                        onCancel: () => Navigator.of(context).pop(),
                      );
                    },
                  );
                },
              )
          ],
        ),
        backgroundColor: Colors.white,
        // Form para validar os campos
        body: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              // Classe criada para o widget de imagens, passando product como parametro
              ImagesForm(product: product),
              // Formularios de Texto
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  // Largura maxima possível para os widgets
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // NOME
                    TextFormField(
                      initialValue: product.name,
                      decoration: const InputDecoration(
                        hintText: 'Título',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),

                      // Validador
                      validator: (name) {
                        if (name!.length < 6) return 'Título muito curto...';
                        return null;
                      },

                      // saved para salvar os campos
                      onSaved: (name) => product.name = name,
                    ),

                    // A PARTIR DE
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'A partir de',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                    // CAMPO VALOR
                    Text(
                      'R\$ ...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    // CATEGORIAS
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Categoria:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Selecionar categoria
                    FormField<String>(
                      validator: (value) {
                        if (product.categoryId == null) {
                          return 'Selecione uma categoria';
                        }
                        return null;
                      },
                      // builder para pegar e alterar o estado do campo, pode ser colocar dentro do formfield
                      builder: (state) {
                        // obtendo o categoria cujo ID é o mesmo Id que está sendo clicado, buscar o categoria que está vinculado ao prd
                        final categories = context.read<CategoriesManager>().findCategoryById(product.categoryId ?? "");
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () async {
                                // obtendo o categ e Acessando a tela de selecionar categ, await para esperar a tela abrir, selecionar a cate, p depois fechar a tela do dialogo
                                final Categories? selectedCategory =
                                    await Navigator.of(context).pushNamed('/select_category') as Categories?;
                                if (selectedCategory != null) {
                                  // setando a categoria selecionada
                                  product.categoryId = selectedCategory.id;
                                  // atualizando estado do campo
                                  state.didChange(selectedCategory.name);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[500]!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      categories?.name ?? 'Selecione a Categoria',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: product.categoryId != null ? Colors.black : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: product.categoryId != null ? Colors.black : Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    // DESCRICAO
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Descrição:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // TEXTO DESCRICAO
                    TextFormField(
                      initialValue: product.description,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Descrição',
                        border: InputBorder.none,
                      ),
                      // Validador
                      validator: (description) {
                        if (description!.length < 10) return 'Descrição muito curta...';
                        return null;
                      },
                      // saved para salvar os campos
                      onSaved: (description) => product.description = description,
                    ),

                    // Formulario de Tamanhos (Widget separado) passando o produto para ter o acesso aos tamanhos iniciais
                    SizesForm(product: product),

                    // Separador
                    const SizedBox(height: 20),

                    Consumer<Product>(
                      builder: (_, product, __) {
                        // BTN salvar
                        return SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: primaryColor.withAlpha(100),
                            ),
                            // passando o carregamento
                            onPressed: !product.loading
                                ? () async {
                                    // Validando os campos
                                    if (formKey.currentState!.validate()) {
                                      // Salvar usando onsaved
                                      formKey.currentState!.save();

                                      // Salvar os dados no firebase chamando o save do Product
                                      await product.save();

                                      // Informar o productManager atraves da função update que houve mudança em um produtos
                                      // ignore: use_build_context_synchronously
                                      context.read<ProductManager>().update(product);

                                      // Retornar para tela anterior
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                    }
                                  }
                                : null,
                            // passando o carregamento
                            child: product.loading
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
