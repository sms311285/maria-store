import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';

enum StatusAccountPay {
  pending,
  canceled,
  postponed,
  paid,
  selectAll,
}

class AccountPayModel {
  String? id;
  String? paymentMethod;
  String? purchaseId;
  String? supplier;
  num? priceTotal;
  num? installments;
  Timestamp? date;
  Timestamp? dueDate;
  Timestamp? datePay;
  StatusAccountPay? statusAccountPay;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // pegando a referencia do firebase - referencia do pedido em si
  DocumentReference get firestoreRef => firestore.collection('accountpay').doc(id);

  String get formattedId => '#${id?.padLeft(8, '0')}';

  // get para pegar o status e expor a variavel para o app
  String get statusText => getStatusText(statusAccountPay!);

  static String getStatusText(StatusAccountPay statusAccountPay) {
    switch (statusAccountPay) {
      case StatusAccountPay.pending:
        return 'Pendente';
      case StatusAccountPay.paid:
        return 'Pago';
      case StatusAccountPay.postponed:
        return 'Adiado';
      case StatusAccountPay.canceled:
        return 'Cancelado';
      case StatusAccountPay.selectAll:
        return 'Selecionar Todos';
      default:
        return '';
    }
  }

  // contrutor padrão das contas
  AccountPayModel({
    this.id,
    this.paymentMethod,
    this.purchaseId,
    this.supplier,
    this.priceTotal,
    this.date,
    this.dueDate,
    this.datePay,
    this.statusAccountPay,
    this.installments,
  });

  // clonar contas
  AccountPayModel clone() {
    return AccountPayModel(
      id: id,
      paymentMethod: paymentMethod,
      purchaseId: purchaseId,
      supplier: supplier,
      priceTotal: priceTotal,
      date: date,
      dueDate: dueDate,
      datePay: datePay,
      statusAccountPay: statusAccountPay,
      installments: installments,
    );
  }

  AccountPayModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    paymentMethod = doc['paymentMethod'] as String;
    purchaseId = doc['purchaseId'] as String;
    supplier = doc['supplier'] as String;
    priceTotal = doc['priceTotal'] as num;
    date = doc['date'] as Timestamp;
    dueDate = doc['dueDate'] as Timestamp;
    datePay = doc['datePay'] as Timestamp?;
    statusAccountPay = StatusAccountPay.values[doc['statusAccountPay'] as int];
    installments = doc['installments'] as num?;
  }

  // função para atualizar as modificações no pedido do orderManager para quando avançar ou voltar o status
  void updateFromDocument(DocumentSnapshot doc) {
    statusAccountPay = StatusAccountPay.values[doc['statusAccountPay'] as int];
    datePay = doc['datePay'] as Timestamp?;
  }

  // Método para gerar o próximo ID da conta
  Future<int> _getAccountPayId() async {
    final ref = firestore.doc('aux/accountpaycounter');
    try {
      final result = await firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final id = doc['current'] as int;
        tx.update(ref, {'current': id + 1});
        return {'id': id};
      });
      return result['id'] as int;
    } catch (e) {
      return Future.error('Falha ao gerar número da conta a pagar $e');
    }
  }

  // metodo para salvar uma conta
  Future<void> save(num? installments, int? daysBetweenInstallments) async {
    // ID base da conta
    final baseId = await _getAccountPayId();
    // Instanciar Financial Manager
    final FinancialManager financialManager = FinancialManager();
    // obtendo a lista atualizada da movimentação financeira
    await financialManager.fetchMovementsFinancial();
    // Buscar função da última movimentação financeira
    final lastMovement = await financialManager.getLastMovement();
    // Usar o saldo final da última movimentação como saldo inicial
    var initialBalance = lastMovement?.finalBalance ?? 0;
    // data atual
    final DateTime now = DateTime.now();

    if (installments != null && installments > 1) {
      for (int i = 0; i < installments; i++) {
        // Gerar o ID da parcela no formato baseId-número
        final installmentId = '$baseId-${i + 1}';
        // obtendo valor das parcelas
        final pricePerInstallment = priceTotal! / installments;
        // Calcular saldo final para cada parcela
        final finalBalance = initialBalance - pricePerInstallment;
        // Ajustar a data de vencimento para cada parcela com a hora 23:59:59
        final dueDate = DateTime(now.year, now.month, now.day + (daysBetweenInstallments! * (i + 1)), 23, 59, 59);

        // salvando a conta
        firestore.collection('accountpay').doc(installmentId.toString()).set({
          'paymentMethod': paymentMethod,
          'purchaseId': purchaseId,
          'supplier': supplier,
          'priceTotal': pricePerInstallment,
          'installments': installments,
          'date': date,
          'dueDate': Timestamp.fromDate(dueDate),
          'datePay': datePay,
          'statusAccountPay': statusAccountPay?.index,
        });

        // Salvando a movimentação financeira
        await firestore.collection('movementsFinancial').add({
          'accountPayId': installmentId,
          'priceTotal': pricePerInstallment,
          'date': Timestamp.now(),
          'status': statusAccountPay?.index,
          'type': 'accountPay',
          'initialBalance': initialBalance,
          'finalBalance': finalBalance,
        });

        // Atualizar saldo inicial para próxima parcela
        initialBalance = finalBalance;

        // Atualizar o campo accountPayId na compra (purchase) após salvar e obter o id da conta
        if (purchaseId != null && i == 0) {
          // Atualiza apenas na primeira parcela
          await firestore.collection('purchases').doc(purchaseId).update({
            'accountPayId': baseId.toString(),
          });
        }
      }
    } else {
      // Se não houver parcelas, salvar apenas uma conta
      id = baseId.toString();
      // calculando o saldo final
      final finalBalance = initialBalance - priceTotal!;

      // salvando a conta
      firestore.collection('accountpay').doc(baseId.toString()).set({
        'paymentMethod': paymentMethod,
        'purchaseId': purchaseId,
        'supplier': supplier,
        'priceTotal': priceTotal,
        'installments': installments,
        'date': date,
        'dueDate': dueDate,
        'datePay': datePay,
        'statusAccountPay': statusAccountPay?.index,
      });

      // Salvando a movimentação financeira diretamente
      await firestore.collection('movementsFinancial').add({
        'accountPayId': id,
        'priceTotal': priceTotal,
        'date': Timestamp.now(),
        'status': statusAccountPay?.index,
        'type': 'accountPay',
        'initialBalance': initialBalance,
        'finalBalance': finalBalance,
      });

      // Atualizar o campo accountPayId na compra (purchase) após salvar e obter o id da conta
      if (purchaseId != null) {
        await firestore.collection('purchases').doc(purchaseId).update({
          'accountPayId': id.toString(),
        });
      }
    }
  }

  // função que altera o status para pago
  Future<void> pay(String accountPayId) async {
    statusAccountPay = StatusAccountPay.paid;
    firestoreRef.update(
      {
        'statusAccountPay': statusAccountPay!.index,
        'datePay': Timestamp.now(),
      },
    );

    // Recuperar o movimento financeiro usando accountPayId vendo se existe algum documento com accountpayId
    final QuerySnapshot movementSnapshot =
        await firestore.collection('movementsFinancial').where('accountPayId', isEqualTo: accountPayId).get();

    if (movementSnapshot.docs.isNotEmpty) {
      // Se o documento foi encontrado, atualiza o status para 3
      for (var doc in movementSnapshot.docs) {
        await doc.reference.update({
          'status': statusAccountPay!.index,
        });
      }
    } else {
      debugPrint('Erro: Nenhum documento encontrado em movementFinancial com accountPayId: $accountPayId');
    }
  }

  // função que altera o status para pendente
  Future<void> pending(String accountPayId) async {
    statusAccountPay = StatusAccountPay.pending;
    firestoreRef.update(
      {
        'statusAccountPay': statusAccountPay!.index,
        'datePay': null,
      },
    );

    // Recuperar o movimento financeiro usando accountPayId vendo se existe algum documento com accountpayId
    final QuerySnapshot movementSnapshot =
        await firestore.collection('movementsFinancial').where('accountPayId', isEqualTo: accountPayId).get();

    if (movementSnapshot.docs.isNotEmpty) {
      // Se o documento foi encontrado, atualiza o status para 3
      for (var doc in movementSnapshot.docs) {
        await doc.reference.update({
          'status': statusAccountPay!.index,
        });
      }
    } else {
      debugPrint('Erro: Nenhum documento encontrado em movementFinancial com accountPayId: $accountPayId');
    }
  }

  // função que altera o status para adiado
  Future<void> postponed(DateTime newDueDate, String accountPayId) async {
    // definindo dia/mes/ano e horario 23:59
    newDueDate = DateTime(newDueDate.year, newDueDate.month, newDueDate.day, 23, 59, 59);
    dueDate = Timestamp.fromDate(newDueDate);
    statusAccountPay = StatusAccountPay.postponed;
    firestoreRef.update(
      {
        'statusAccountPay': statusAccountPay!.index,
        'datePay': null,
        'dueDate': dueDate,
      },
    );

    // Recuperar o movimento financeiro usando accountPayId vendo se existe algum documento com accountpayId
    final QuerySnapshot movementSnapshot =
        await firestore.collection('movementsFinancial').where('accountPayId', isEqualTo: accountPayId).get();

    if (movementSnapshot.docs.isNotEmpty) {
      // Se o documento foi encontrado, atualiza o status para 3
      for (var doc in movementSnapshot.docs) {
        await doc.reference.update({
          'status': statusAccountPay!.index,
        });
      }
    } else {
      debugPrint('Erro: Nenhum documento encontrado em movementFinancial com accountPayId: $accountPayId');
    }
  }
}
