import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/item_size/item_size.dart';

// Classe para gerenciar tamanhos extraídos dos produtos
class ItemSizeManager extends ChangeNotifier {
  ItemSizeManager() {
    // Carregar tamanhos
    _loadItemSizes();
  }
  List<ItemSize> sizes = [];

  // controlador do texto do filtro
  final TextEditingController searchController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Função para carregar tamanhos dos produtos do Firebase
  Future<void> _loadItemSizes() async {
    try {
      // Obter todos os documentos da coleção de produtos
      final snapshot = await firestore.collection('products').get();
      // Listar todos os tamanhos de todos os produtos
      List<ItemSize> allSizes = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final List<dynamic> sizesList = data['sizes'] ?? [];
        allSizes.addAll(sizesList.map((e) => ItemSize.fromMap(e)).toList());
      }

      // Remover tamanhos duplicados baseado no nome
      sizes = _removeDuplicateSizes(allSizes);
      // Notificar ouvintes sobre a atualização
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar tamanhos: $e');
    }
  }

  // Remove tamanhos duplicados baseado no nome
  List<ItemSize> _removeDuplicateSizes(List<ItemSize> sizes) {
    final seen = <String>{};
    return sizes.where((size) => seen.add(size.name ?? '')).toList();
  }

  // Obtém todos os tamanhos disponíveis
  List<String> get sizeNames => sizes.map((e) => e.name ?? '').toList();

  // Dispose faz parte do changenotifier, cancela o _subscription e para de ficar obs as mudanças/atualizações
  @override
  dispose() {
    // Dispose do controller quando não for mais necessário
    searchController.dispose();
    super.dispose();
  }
}
