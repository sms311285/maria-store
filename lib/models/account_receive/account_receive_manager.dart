import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/account_receive/account_receive_model.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/user/user_app.dart';

class AccountReceiveManager extends ChangeNotifier {
  // Lista de contas
  final List<AccountReceiveModel> _accountReceive = [];

  List<AccountReceiveModel> filterAccountReceives = [];

  DateTime? startDateFilter;
  DateTime? endDateFilter;

  DateTime? startDueDateFilter;
  DateTime? endDueDateFilter;

  DateTime? startDateReceiveFilter;
  DateTime? endDateReceiveFilter;

  String? accountReceiveIdFilter;

  UserApp? userFilter;

  PaymentMethodModel? paymentMethodFilter;

  List<StatusAccountReceive> statusFilter = [StatusAccountReceive.pending];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  // atualizar user
  void updateAdmin({required bool adminEnabled}) {
    _accountReceive.clear();
    _subscription?.cancel();
    filterAccountReceives.clear();
    if (adminEnabled) {
      _listenToAccountReceive();
    }
  }

  // lista de pedidos
  void _listenToAccountReceive() {
    _subscription = firestore.collection('accountreceive').snapshots().listen(
      (event) {
        for (final change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              _accountReceive.add(
                AccountReceiveModel.fromDocument(change.doc),
              );
              break;
            case DocumentChangeType.modified:
              final modAccountReceive = _accountReceive.firstWhere((p) => p.id == change.doc.id);
              modAccountReceive.updateFromDocument(change.doc);
              break;
            case DocumentChangeType.removed:
              debugPrint('Deu problema sério!!!');
              break;
          }
        }
        filterAccountReceives = List.from(_accountReceive);
        notifyListeners();
      },
    );
  }

  // lista de filtros
  List<AccountReceiveModel> get filteredAccountReceive {
    List<AccountReceiveModel> output = _accountReceive.reversed.toList();

    if (accountReceiveIdFilter != null && accountReceiveIdFilter!.isNotEmpty) {
      output = output.where((p) => p.id!.contains(accountReceiveIdFilter!)).toList();
    }

    // verificando se o userFilter e != null e adicionando na lista de order
    if (userFilter != null) {
      // pegando todos os itens que já tinha no output e procurando todos os itens cujo pedido foi feito por um userid seja igual ao userid passado no filtro
      output = output.where((p) => p.user == userFilter!.id).toList();
    }

    // filtro forma de pagamento
    if (paymentMethodFilter != null) {
      output = output.where((o) => o.paymentMethod == paymentMethodFilter!.id).toList();
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

    if (startDateReceiveFilter != null && endDateReceiveFilter != null) {
      // Filtrando apenas os itens onde a data de pagamento não é nula e está no intervalo das datas
      output = output.where((p) {
        // Verifica se a data de pagamento não é nula
        if (p.dateReceive != null) {
          DateTime accountDatePayTime = p.dateReceive!.toDate();

          // Verifica se a data de pagamento está entre as datas do filtro
          return accountDatePayTime.isAfter(startDateReceiveFilter!) &&
              accountDatePayTime.isBefore(endDateReceiveFilter!.add(const Duration(days: 1)));
        } else {
          // Caso a data de pagamento seja nula, exclui o item do filtro
          return false;
        }
      }).toList();
    }

    return output = output.where((o) => statusFilter.contains(o.statusAccountReceive)).toList();
  }

  void setStatusFilter({StatusAccountReceive? status, bool? enablad}) {
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

  void setAllStatusAccountReceiveFilters(bool value) {
    // Se checkbox "Selecionar Todos" foi marcado
    if (value) {
      // Ele define a lista statusFilter com todos os status disponíveis, exceto selectAll. O método where filtra a lista para excluir selectAll.
      statusFilter = StatusAccountReceive.values.where((s) => s != StatusAccountReceive.selectAll).toList();
    } else {
      // removendo todos os status
      statusFilter.clear();
    }
    notifyListeners();
  }

  void setAccountReceiveIdFilter(String? accountReceiveId) {
    accountReceiveIdFilter = accountReceiveId;
    notifyListeners();
  }

  void setUserFilter(UserApp? user) {
    userFilter = user;
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

  void setStartDateReceive(DateTime? startReceive) {
    startDateReceiveFilter = startReceive;
    notifyListeners();
  }

  // FILTRO DATA FINAL
  void setEndDateReceive(DateTime? endReceive) {
    endDateReceiveFilter = endReceive;
    notifyListeners();
  }

  // caculos totias
  //TOTAL PEDIDO
  double calculateTotalAccountReceive(List<AccountReceiveModel> accountReceive) {
    return accountReceive.fold(0, (total, accountReceive) => total + accountReceive.priceTotal!);
  }

  // TOTAL duplicatas
  int calculateQuantityAccountReceive(List<AccountReceiveModel> accountReceive) {
    return accountReceive.length;
  }

  void filterAccountReceive(String query) {
    if (query.isEmpty) {
      filterAccountReceives = List.from(_accountReceive);
    } else {
      filterAccountReceives = _accountReceive.where((o) => o.id!.contains(query)).toList();
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
