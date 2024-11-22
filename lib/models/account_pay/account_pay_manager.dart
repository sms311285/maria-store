import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/account_pay/account_pay_model.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';

class AccountPayManager extends ChangeNotifier {
  // Lista de contas
  final List<AccountPayModel> _accountPay = [];

  List<AccountPayModel> filterAccountPays = [];

  DateTime? startDateFilter;
  DateTime? endDateFilter;

  DateTime? startDueDateFilter;
  DateTime? endDueDateFilter;

  DateTime? startDatePayFilter;
  DateTime? endDatePayFilter;

  String? accountPayIdFilter;

  SupplierApp? supplierFilter;

  PaymentMethodModel? paymentMethodFilter;

  List<StatusAccountPay> statusFilter = [StatusAccountPay.pending];

  StreamSubscription? _subscription;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // atualizar user
  void updateAdmin({required bool adminEnabled}) {
    _accountPay.clear();
    _subscription?.cancel();
    filterAccountPays.clear();
    if (adminEnabled) {
      _listenToAccountPay();
    }
  }

  // lista de pedidos
  void _listenToAccountPay() {
    _subscription = firestore.collection('accountpay').snapshots().listen(
      (event) {
        for (final change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              _accountPay.add(
                AccountPayModel.fromDocument(change.doc),
              );
              break;
            case DocumentChangeType.modified:
              final modAccountPay = _accountPay.firstWhere((p) => p.id == change.doc.id);
              modAccountPay.updateFromDocument(change.doc);
              break;
            case DocumentChangeType.removed:
              debugPrint('Deu problema sério!!!');
              break;
          }
        }
        filterAccountPays = List.from(_accountPay);
        notifyListeners();
      },
    );
  }

  // lista de filtros
  List<AccountPayModel> get filteredAccountPay {
    List<AccountPayModel> output = _accountPay.reversed.toList();

    if (accountPayIdFilter != null && accountPayIdFilter!.isNotEmpty) {
      output = output.where((p) => p.id!.contains(accountPayIdFilter!)).toList();
    }

    // filtro forma de pagamento
    if (paymentMethodFilter != null) {
      output = output.where((o) => o.paymentMethod == paymentMethodFilter!.id).toList();
    }

    // verificando se o userFilter e != null e adicionando na lista de order
    if (supplierFilter != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito por um userid seja igual ao userid passado no filtro
      output = output.where((p) => p.supplier == supplierFilter!.id).toList();
    }

    // FILTRO DATA
    if (startDateFilter != null && endDateFilter != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito antes ou depois das datas passado no filtro
      output = output.where((p) {
        DateTime accounDateTime = p.date!.toDate();
        return accounDateTime.isAfter(startDateFilter!) &&
            accounDateTime.isBefore(endDateFilter!.add(const Duration(days: 1)));
      }).toList();
    }

    if (startDueDateFilter != null && endDueDateFilter != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito antes ou depois das datas passado no filtro
      output = output.where((p) {
        DateTime accountDueDateTime = p.dueDate!.toDate();
        return accountDueDateTime.isAfter(startDueDateFilter!) &&
            accountDueDateTime.isBefore(endDueDateFilter!.add(const Duration(days: 1)));
      }).toList();
    }

    if (startDatePayFilter != null && endDatePayFilter != null) {
      // Filtrando apenas os itens onde a data de pagamento não é nula e está no intervalo das datas
      output = output.where((p) {
        // Verifica se a data de pagamento não é nula
        if (p.datePay != null) {
          DateTime accountDatePayTime = p.datePay!.toDate();

          // Verifica se a data de pagamento está entre as datas do filtro
          return accountDatePayTime.isAfter(startDatePayFilter!) &&
              accountDatePayTime.isBefore(endDatePayFilter!.add(const Duration(days: 1)));
        } else {
          // Caso a data de pagamento seja nula, exclui o item do filtro
          return false;
        }
      }).toList();
    }

    return output = output.where((o) => statusFilter.contains(o.statusAccountPay)).toList();
  }

  void setStatusFilter({StatusAccountPay? status, bool? enablad}) {
    // se o status está habilitado
    if (enablad!) {
      // acessa o status filter e add o status que habilitou
      statusFilter.add(status!);
    } else {
      // se está desabilitado, remove o statusFilter
      statusFilter.remove(status);
    }
    notifyListeners();
  }

  void setAllStatusAccountPayFilters(bool value) {
    // Se checkbox "Selecionar Todos" foi marcado
    if (value) {
      // Ele define a lista statusFilter com todos os status disponíveis, exceto selectAll. O método where filtra a lista para excluir selectAll.
      statusFilter = StatusAccountPay.values.where((s) => s != StatusAccountPay.selectAll).toList();
    } else {
      // removendo todos os status
      statusFilter.clear();
    }
    notifyListeners();
  }

  void setAccountPayIdFilter(String? accountPayId) {
    accountPayIdFilter = accountPayId;
    notifyListeners();
  }

  void setSupplierFilter(SupplierApp? supplier) {
    supplierFilter = supplier;
    notifyListeners();
  }

  void setPaymentMethodFilter(PaymentMethodModel? paymentMethod) {
    paymentMethodFilter = paymentMethod;
    notifyListeners();
  }

  void setStartDate(DateTime? start) {
    startDateFilter = start;
    notifyListeners();
  }

  // FILTRO DATA FINAL
  void setEndDate(DateTime? end) {
    endDateFilter = end;
    notifyListeners();
  }

  void setStartDueDate(DateTime? startDue) {
    startDueDateFilter = startDue;
    notifyListeners();
  }

  // FILTRO DATA FINAL
  void setEndDueDate(DateTime? endDue) {
    endDueDateFilter = endDue;
    notifyListeners();
  }

  void setStartDatePay(DateTime? startPay) {
    startDatePayFilter = startPay;
    notifyListeners();
  }

  // FILTRO DATA FINAL
  void setEndDatePay(DateTime? endPay) {
    endDatePayFilter = endPay;
    notifyListeners();
  }

  // caculos totias
  //TOTAL PEDIDO
  double calculateTotalAccountPay(List<AccountPayModel> accountPay) {
    return accountPay.fold(0, (total, accountPay) => total + accountPay.priceTotal!);
  }

  // TOTAL duplicatas
  int calculateQuantityAccountPay(List<AccountPayModel> accountPay) {
    return accountPay.length;
  }

  // Lista de contas para o drop de filtro de conta
  void filterAccountPay(String query) {
    if (query.isEmpty) {
      filterAccountPays = List.from(_accountPay);
    } else {
      filterAccountPays = _accountPay.where((o) => o.id!.contains(query)).toList();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // cancelando a subscription
    _subscription?.cancel();
    super.dispose();
  }
}
