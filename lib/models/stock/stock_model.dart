import 'package:cloud_firestore/cloud_firestore.dart';

class StockModel {
  String? id;
  Timestamp? date;
  String? orderId;
  String? purchaseId;
  num? quantity;
  num? status;
  String? type;
  num? initialStock;
  num? finalStock;

  StockModel({
    this.id,
    this.date,
    this.orderId,
    this.purchaseId,
    this.quantity,
    this.status,
    this.type,
    this.initialStock,
    this.finalStock,
  });

  // Construtor para obter os dados do Firestore
  StockModel.fromDocument(DocumentSnapshot document) {
    id = document.id;
    date = document['date'] as Timestamp;
    // Convertendo em map para usar o containsKey
    Map<String, dynamic> dataMap = document.data() as Map<String, dynamic>;
    // Verificando se os campos existem antes de acessá-los
    orderId = dataMap.containsKey('orderId') ? dataMap['orderId'] as String? : null;
    purchaseId = dataMap.containsKey('purchaseId') ? dataMap['purchaseId'] as String? : null;
    quantity = document['quantity'] as num;
    status = document['status'] as num;
    type = document['type'] as String;
    initialStock = document['initialStock'] as num;
    finalStock = document['finalStock'] as num;
  }
}
