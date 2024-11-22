// Gerenciador da lista de categorias

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/category/categories.dart';

class CategoriesManager extends ChangeNotifier {
  // Construtor para buscar todos os categorais do firebase
  CategoriesManager() {
    // Logo que instancia já carrega as categorais
    _loadCategory();
  }

  String? name;

  // Lista de categorias para guradar todas as categorias
  List<Categories> allCategory = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Função para  carregando as categorias
  Future<void> _loadCategory() async {
    // Acessando a coleção category e pegando todas as categorias
    final QuerySnapshot snapCategory = await firestore.collection('category').where('deleted', isEqualTo: false).get();
    // Acessando documento de categorias (snapCategory) e transformando em objeto e depois em uma lista guardando em _allProducts
    allCategory = snapCategory.docs.map((c) => Categories.fromDocument(c)).toList();
    notifyListeners();
  }

  // Função para buscar os categorias pelo ID
  Categories? findCategoryById(String id) {
    // Tratando exceção caso não encontre o prd
    try {
      // Pesquisar e Retornar o primeiro item que for igual ao ID
      return allCategory.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void delete(Categories categories) {
    // pedindo para prd se deletar a si mesmo
    categories.delete();
    // procurando o prd a ser deletado
    allCategory.removeWhere((u) => u.id == categories.id);
    notifyListeners();
  }

  // Função upDate para atualizar lista de categoria para o CategoriesManager notificar mudanças
  void update(Categories categories) {
    // Remover categoria antigo
    allCategory.removeWhere((c) => c.id == categories.id);
    // Adicionar novo
    allCategory.add(categories);
    // Notificar mudanças
    notifyListeners();
  }

  // metodo para verificar se a categoria está em uso e não deixar excluir
  Future<bool> isCategoryInUse(Categories categories) async {
    // Verificar se o ID da categoria existe
    if (categories.id != null) {
      // Verificar se o ID da categoria existe na coleção products
      final QuerySnapshot snapProducts =
          await firestore.collection('products').where('cid', isEqualTo: categories.id).get();
      // Verificar se o ID da categoria existe no documento (snapProducts)
      if (snapProducts.docs.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
