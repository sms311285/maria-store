import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/product/product.dart';

// ChangeNotifier para deixar a lista de produtos disponível em todo app via Provider
class ProductManager extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Declarando lista de produtos para tela de todos os produtos
  List<Product> allProducts = [];

  // lista de produto para filter na tela de seleção de prd
  List<Product> filterProducts = [];

  // controlador do texto do filtro
  final TextEditingController searchController = TextEditingController();

  // Definindo variavel search iniciando vazio campo pesquisa ProductsScreen
  String _search = '';

  // Definindo variavel _selectedCategory iniciando sem nenhuma selecionada
  String _selectedCategory = '';

  // Construtor para buscar todos os produtos do firebase
  ProductManager() {
    // Logo que instancia já carrega os produtos
    _loadAllProducts();
  }

  // PRODUTOS PESQUISA
  // Expondo para retornar search
  String get search => _search;
  // Sempre que der search = search no ProductScreen ele vai setar que está pesquisando
  set search(String value) {
    _search = value;
    notifyListeners();
  }

  // PRODUTOS CATEGORIA
  // Expondo para retornar selectedCategory
  String get selectedCategory => _selectedCategory;
  // Sempre que der selectedCategory = selectedCategory no ProductScreen ele vai setar que está pesquisando
  set selectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  // Função para selecionar e desselecionar categoria
  void toggleCategory(String categoryId) {
    if (_selectedCategory == categoryId) {
      _selectedCategory = '';
    } else {
      _selectedCategory = categoryId;
    }
    notifyListeners();
  }

  // Função para atualizar o texto do filtro na tela de seleção de prd
  void updateSearchProduct(String product) {
    searchController.text = product;
    filterProduct(product);
  }

  // Método de filtragem para pesquisa de produto por nome na tela de seleção de prd
  void filterProduct(String query) {
    if (query.isEmpty) {
      filterProducts = List.from(allProducts);
    } else {
      filterProducts = allProducts
          .where(
            (product) => product.name!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  // Método que identifica quando está pesquisando e realiza os filtros
  List<Product>? get filteredProducts {
    final List<Product> filteredProducts = [];

    if (search.isEmpty && selectedCategory.isEmpty) {
      // Se estiver vazia add todos os produtos
      filteredProducts.addAll(allProducts);
    } else {
      // Aplicar ambos os filtros ao mesmo tempo um baseado no outro
      filteredProducts.addAll(
        allProducts.where((p) {
          final matchesSearch = p.name!.toLowerCase().contains(search.toLowerCase());
          final matchesCategory = selectedCategory.isEmpty || p.categoryId == selectedCategory;
          return matchesSearch && matchesCategory;
        }),
      );
    }
    return filteredProducts;
  }

  // Metodo para carregar todos os produtos
  Future<void> _loadAllProducts() async {
    // Acessando a coleção produtos e pegando todos os documentos e guardando snapProducts e verificando se o prd está deletado para apresentar ou não
    final QuerySnapshot snapProducts = await firestore.collection('products').where('deleted', isEqualTo: false).get();
    // Acessando documento de produtos (snapProducts) e transformando em objeto e depois em uma lista guardando em _allProducts
    allProducts = snapProducts.docs.map((d) => Product.fromDocument(d)).toList();
    // Iniciando a lista na tela de seleção de prd com todos os prd
    filterProducts = List.from(allProducts);
    // Notificando mudanças
    notifyListeners();
  }

  // Função para buscar os produtos pelo ID
  Product? findProductById(String id) {
    // Tratando exceção caso não encontre o prd
    try {
      // Pesquisar e Retornar o primeiro item que for igual ao ID
      return allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Função upDate para atualizar o produto para o ProductManager notificar mudanças
  void update(Product product) {
    // Remover produto antigo
    allProducts.removeWhere((p) => p.id == product.id);
    // Adicionar novo
    allProducts.add(product);
    // Notificar mudanças
    notifyListeners();
  }

  // deletar produto, recebendo o product que vai ser deletado
  void delete(Product product) {
    // pedindo para prd se deletar a si mesmo
    product.delete();
    // procurando o prd a ser deletado
    allProducts.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  // Dispose faz parte do changenotifier, cancela o _subscription e para de ficar obs as mudanças/atualizações
  @override
  dispose() {
    // Dispose do controller quando não for mais necessário
    searchController.dispose();
    super.dispose();
  }
}
