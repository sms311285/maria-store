import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialModel {
  String? id;
  Timestamp? date;
  String? accountPayId;
  String? accountReceiveId;
  num? priceTotal;
  num? status;
  String? type;
  num? initialBalance;
  num? finalBalance;

  FinancialModel({
    this.id,
    this.date,
    this.accountPayId,
    this.accountReceiveId,
    this.priceTotal,
    this.status,
    this.type,
    this.initialBalance,
    this.finalBalance,
  });

  // Construtor para converter o documento do Firestore em um modelo
  FinancialModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    id = doc.id;
    date = data['date'] as Timestamp;
    accountPayId = data['accountPayId'] as String?;
    accountReceiveId = data['accountReceiveId'] as String?;
    priceTotal = data['priceTotal'] as num?;
    status = data['status'] as num?;
    type = data['type'] as String?;
    initialBalance = data['initialBalance'] as num?;
    finalBalance = data['finalBalance'] as num?;
  }
}
