import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/stock/stock_model.dart';

class StockManager extends ChangeNotifier {
  // Instância do Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<StockModel> stockMovements = [];

  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  void setStartDate(DateTime? start) {
    _startDate = start;
    notifyListeners();
  }

  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  void setEndDate(DateTime? end) {
    _endDate = end;
    notifyListeners();
  }

  // Função para limpar as movimentações e datas
  void clearMovements() {
    stockMovements = [];
    _startDate = null;
    _endDate = null;
    notifyListeners(); // Notifica as mudanças para atualizar a interface
  }

  // Função para buscar movimentações de estoque na subcoleção de tamanhos
  Future<void> fetchMovements(String productId, String sizeName) async {
    try {
      // Navegar até a subcoleção do tamanho específico
      final QuerySnapshot snapMovements = await firestore
          .collection('products')
          .doc(productId)
          .collection(sizeName) // Subcoleção com o nome do tamanho
          .get();

      // Mapear os documentos para objetos StockModel
      stockMovements = snapMovements.docs.map((doc) => StockModel.fromDocument(doc)).toList();

      // Aplicar filtro de data localmente, se as datas estiverem definidas
      if (startDate != null && endDate != null) {
        stockMovements = stockMovements.where((movement) {
          DateTime movementDate = movement.date!.toDate();
          return movementDate.isAfter(startDate!) &&
              movementDate.isBefore(endDate!.add(const Duration(days: 1))); // Incluir o último dia
        }).toList();
      }

      // Ordenar as movimentações por data
      stockMovements.sort((a, b) => a.date!.compareTo(b.date!));

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar movimentações: $e');
    }
  }
}
