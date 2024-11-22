import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';

class PaymentMethodManager extends ChangeNotifier {
  // Construtor para buscar todos os foma pgto do firebase
  PaymentMethodManager() {
    // Logo que instancia já carrega as foma pgto
    _loadPaymentMethod();
  }

  String? name;

  // Lista de forma pgto para guradar todas as forma pgto
  List<PaymentMethodModel> allPaymentMethod = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Função para  carregando as forma pgto
  Future<void> _loadPaymentMethod() async {
    // Acessando a coleção paymentmethod e pegando todas as forma pgto
    final QuerySnapshot snapPaymentMethod =
        await firestore.collection('paymentmethod').where('deleted', isEqualTo: false).get();
    // Acessando documento de forma pgto (snapPaymentMethod) e transformando em objeto e depois em uma lista guardando em _allProducts
    allPaymentMethod = snapPaymentMethod.docs.map((c) => PaymentMethodModel.fromDocument(c)).toList();
    notifyListeners();
  }

  // Função para buscar os forma pgto pelo ID
  PaymentMethodModel? findPaymentMethodById(String id) {
    // Tratando exceção caso não encontre o prd
    try {
      // Pesquisar e Retornar o primeiro item que for igual ao ID
      return allPaymentMethod.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void delete(PaymentMethodModel paymentMethodModel) {
    // pedindo para prd se deletar a si mesmo
    paymentMethodModel.delete();
    // procurando o prd a ser deletado
    allPaymentMethod.removeWhere((u) => u.id == paymentMethodModel.id);
    notifyListeners();
  }

  // Função upDate para atualizar lista de forma pgto para o PaymentMethodManager notificar mudanças
  void update(PaymentMethodModel paymentMethodModel) {
    // Remover forma pgto antigo
    allPaymentMethod.removeWhere((c) => c.id == paymentMethodModel.id);
    // Adicionar novo
    allPaymentMethod.add(paymentMethodModel);
    // Notificar mudanças
    notifyListeners();
  }

  // metodo para verificar se a forma pgto está em uso e não deixar excluir
  Future<bool> isPaymentMethodInUse(PaymentMethodModel paymentMethodModel) async {
    // Verificar se o ID da forma pgto existe
    if (paymentMethodModel.id != null) {
      // Verificar se o ID da forma pgto existe na coleção products
      final QuerySnapshot snapProducts =
          await firestore.collection('orders').where('paymentMethod', isEqualTo: paymentMethodModel.id).get();
      // Verificar se o ID da forma pgto existe no documento (snapProducts)
      if (snapProducts.docs.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
