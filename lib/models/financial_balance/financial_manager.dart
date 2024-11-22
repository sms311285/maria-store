import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/financial_balance/financial_model.dart';

class FinancialManager extends ChangeNotifier {
  // Construtor: Carrega as movimentações automaticamente ao inicializar
  // FinancialManager() {
  //   fetchMovementsFinancial(); // Carrega os dados ao criar a instância
  // }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<FinancialModel> financialMovements = [];

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
  void clearMovementsFinancial() {
    financialMovements = [];
    _startDate = null;
    _endDate = null;
    notifyListeners(); // Notifica as mudanças para atualizar a interface
  }

  // Função para buscar movimentações financeiras
  Future<void> fetchMovementsFinancial() async {
    try {
      // Navegar até a coleção de movimentações financeiras
      final QuerySnapshot snapMovements = await firestore.collection('movementsFinancial').get();
      // Mapear os documentos para objetos FinancialModel
      financialMovements = snapMovements.docs.map((doc) => FinancialModel.fromDocument(doc)).toList();
      // Aplicar filtro de data localmente, se as datas estiverem definidas
      if (startDate != null && endDate != null) {
        financialMovements = financialMovements.where((movement) {
          DateTime movementDate = movement.date!.toDate();
          return movementDate.isAfter(startDate!) && movementDate.isBefore(endDate!.add(const Duration(days: 1)));
        }).toList();
      }
      // Ordenar as movimentações por data (caso não esteja usando orderBy)
      financialMovements.sort((a, b) => a.date!.compareTo(b.date!));
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao buscar movimentações: $e');
    }
  }

  // Função para buscar a última movimentação financeira registrada
  Future<FinancialModel?> getLastMovement() async {
    if (financialMovements.isNotEmpty) {
      return financialMovements.last;
    }
    return null;
  }

  // Função para calcular total a receber, total a pagar e saldo
  // Função para calcular total a receber, total a pagar e saldo
  Map<String, num> calculateBalanceTotal() {
    num totalReceive = 0;
    num totalPay = 0;

    // Itera sobre as movimentações e acumula valores de acordo com o tipo e status
    for (var movement in financialMovements) {
      if (movement.type == 'accountReceive') {
        if (movement.status == 1) {
          totalReceive -= movement.priceTotal ?? 0; // Subtrai se for cancelada
        } else {
          totalReceive += movement.priceTotal ?? 0; // Soma normalmente
        }
      } else if (movement.type == 'accountPay') {
        if (movement.status == 1) {
          totalPay += movement.priceTotal ?? 0; // Subtrai se for cancelada
        } else {
          totalPay -= movement.priceTotal ?? 0; // Soma normalmente
        }
      }
    }

    // Calcula o saldo final
    num balanceFinal = totalReceive + totalPay;

    return {
      'totalReceive': totalReceive,
      'totalPay': totalPay,
      'balanceFinal': balanceFinal,
    };
  }
}
