import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';

enum StatusAccountReceive {
  pending,
  canceled,
  postponed,
  paid,
  selectAll,
}

class AccountReceiveModel {
  String? id;
  String? paymentMethod;
  String? orderId;
  String? user;
  num? priceTotal;
  num? installments;
  Timestamp? date;
  Timestamp? dueDate;
  Timestamp? dateReceive;
  StatusAccountReceive? statusAccountReceive;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  // pegando a referencia do firebase - referencia do pedido em si
  DocumentReference get firestoreRef => firestore.collection('accountreceive').doc(id);

  String get formattedId => '#${id?.padLeft(6, '0')}';

  // get para pegar o status e expor a variavel para o app
  String get statusText => getStatusText(statusAccountReceive!);

  static String getStatusText(StatusAccountReceive statusAccountReceive) {
    switch (statusAccountReceive) {
      case StatusAccountReceive.pending:
        return 'Pendente';
      case StatusAccountReceive.paid:
        return 'Pago';
      case StatusAccountReceive.postponed:
        return 'Adiado';
      case StatusAccountReceive.canceled:
        return 'Cancelado';
      case StatusAccountReceive.selectAll:
        return 'Selecionar Todos';
      default:
        return '';
    }
  }

  // contrutor padrão das contas
  AccountReceiveModel({
    this.id,
    this.paymentMethod,
    this.orderId,
    this.user,
    this.priceTotal,
    this.date,
    this.dueDate,
    this.dateReceive,
    this.statusAccountReceive,
    this.installments,
  });

  // clonar contas
  AccountReceiveModel clone() {
    return AccountReceiveModel(
      id: id,
      paymentMethod: paymentMethod,
      orderId: orderId,
      user: user,
      priceTotal: priceTotal,
      date: date,
      dueDate: dueDate,
      dateReceive: dateReceive,
      statusAccountReceive: statusAccountReceive,
      installments: installments,
    );
  }

  AccountReceiveModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    paymentMethod = doc['paymentMethod'] as String;
    orderId = doc['orderId'] as String;
    user = doc['user'] as String;
    priceTotal = doc['priceTotal'] as num;
    installments = doc['installments'] as num?;
    date = doc['date'] as Timestamp;
    dueDate = doc['dueDate'] as Timestamp;
    dateReceive = doc['dateReceive'] as Timestamp?;
    statusAccountReceive = StatusAccountReceive.values[doc['statusAccountReceive'] as int];
  }

  // função para atualizar as modificações no conta para quando avançar ou voltar o status
  void updateFromDocument(DocumentSnapshot doc) {
    statusAccountReceive = StatusAccountReceive.values[doc['statusAccountReceive'] as int];
    // passando o dataReceive pois como ele pode ser nulo passando para ele atualizar na dialog
    dateReceive = doc['dateReceive'] as Timestamp?;
  }

  // Método para gerar o próximo ID da conta
  Future<int> _getAccountReceiveId() async {
    final ref = firestore.doc('aux/accountreceivecounter');
    try {
      final result = await firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final id = doc['current'] as int;
        tx.update(ref, {'current': id + 1});
        return {'id': id};
      });
      return result['id'] as int;
    } catch (e) {
      return Future.error('Falha ao gerar número da conta a receber $e');
    }
  }

  // metodo para salvar uma conta
  Future<void> save() async {
    final baseId = await _getAccountReceiveId();
    // Instanciar Financial Manager
    final FinancialManager financialManager = FinancialManager();
    // obtendo a lista atualizada da movimentação financeira
    await financialManager.fetchMovementsFinancial();
    // Buscar função da última movimentação financeira
    final lastMovement = await financialManager.getLastMovement();
    // Usar o saldo final da última movimentação como saldo inicial
    var initialBalance = lastMovement?.finalBalance ?? 0;

    await firestore.collection('accountreceive').doc(baseId.toString()).set({
      'paymentMethod': paymentMethod,
      'orderId': orderId,
      'user': user,
      'priceTotal': priceTotal,
      'date': date,
      'dueDate': dueDate,
      'dateReceive': dateReceive,
      'statusAccountReceive': statusAccountReceive?.index,
      'installments': installments,
    });

    id = baseId.toString();
    final finalBalance = initialBalance + priceTotal!;

    // salvar movimentação financeira
    await firestore.collection('movementsFinancial').add({
      'accountReceiveId': id,
      'priceTotal': priceTotal,
      'date': Timestamp.now(),
      'status': statusAccountReceive?.index,
      'type': 'accountReceive',
      'initialBalance': initialBalance,
      'finalBalance': finalBalance,
    });

    // Atualizar o campo accountReceiveId na compra (purchase) após salvar e obter o id da conta
    if (orderId != null) {
      await firestore.collection('orders').doc(orderId).update({
        'accountReceiveId': id.toString(),
      });
    }
  }

  // função que altera o status para pago
  void receive(String accountReceiveId) async {
    statusAccountReceive = StatusAccountReceive.paid;
    firestoreRef.update(
      {
        'statusAccountReceive': statusAccountReceive!.index,
        'dateReceive': Timestamp.now(),
      },
    );

    // Recuperar o movimento financeiro usando accountPayId vendo se existe algum documento com accountpayId
    final QuerySnapshot movementSnapshot =
        await firestore.collection('movementsFinancial').where('accountReceiveId', isEqualTo: accountReceiveId).get();

    if (movementSnapshot.docs.isNotEmpty) {
      // Se o documento foi encontrado, atualiza o status para 3
      for (var doc in movementSnapshot.docs) {
        await doc.reference.update({
          'status': statusAccountReceive!.index,
        });
      }
    } else {
      debugPrint('Erro: Nenhum documento encontrado em movementFinancial com accountReceiveId: $accountReceiveId');
    }
  }

  // função que altera o status para pendente
  void pending(String accountReceiveId) async {
    statusAccountReceive = StatusAccountReceive.pending;
    firestoreRef.update(
      {
        'statusAccountReceive': statusAccountReceive!.index,
        'dateReceive': null,
      },
    );

    // Recuperar o movimento financeiro usando accountReceiveId vendo se existe algum documento com accountReceiveId
    final QuerySnapshot movementSnapshot =
        await firestore.collection('movementsFinancial').where('accountReceiveId', isEqualTo: accountReceiveId).get();

    if (movementSnapshot.docs.isNotEmpty) {
      // Se o documento foi encontrado, atualiza o status para 3
      for (var doc in movementSnapshot.docs) {
        await doc.reference.update({
          'status': statusAccountReceive!.index,
        });
      }
    } else {
      debugPrint('Erro: Nenhum documento encontrado em movementFinancial com accountReceiveId: $accountReceiveId');
    }
  }

  // função que altera o status para pago
  void postponed(DateTime newDueDate, String accountReceiveId) async {
    // definindo dia/mes/ano e horario 23:59
    newDueDate = DateTime(newDueDate.year, newDueDate.month, newDueDate.day, 23, 59, 59);
    dueDate = Timestamp.fromDate(newDueDate);
    statusAccountReceive = StatusAccountReceive.postponed;
    firestoreRef.update(
      {
        'statusAccountReceive': statusAccountReceive!.index,
        'dateReceive': null,
        'dueDate': dueDate,
      },
    );

    // Recuperar o movimento financeiro usando accountReceiveId vendo se existe algum documento com accountReceiveId
    final QuerySnapshot movementSnapshot =
        await firestore.collection('movementsFinancial').where('accountReceiveId', isEqualTo: accountReceiveId).get();

    if (movementSnapshot.docs.isNotEmpty) {
      // Se o documento foi encontrado, atualiza o status para 3
      for (var doc in movementSnapshot.docs) {
        await doc.reference.update({
          'status': statusAccountReceive!.index,
        });
      }
    } else {
      debugPrint('Erro: Nenhum documento encontrado em movementFinancial com accountReceiveId: $accountReceiveId');
    }
  }
}
