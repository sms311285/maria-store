import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';

class AdminSuppliersManager extends ChangeNotifier {
  List<SupplierApp> suppliers = [];

  // controlador do texto do filtro
  final TextEditingController searchController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  List<String?> get names => suppliers.map((e) => e.name).toList();
  List<String?> get phones => suppliers.map((e) => e.phone).toList();

  void updateAdmin({required bool adminEnabled}) {
    _subscription?.cancel();
    if (adminEnabled) {
      _listenToSuppliers();
    } else {
      suppliers.clear();
      notifyListeners();
    }
  }

  void _listenToSuppliers() {
    _subscription = firestore.collection('suppliers').where('deleted', isEqualTo: false).snapshots().listen(
      (snapshot) {
        suppliers = snapshot.docs.map((d) => SupplierApp.fromDocument(d)).toList();
        suppliers.sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
        notifyListeners();
      },
    );
  }

  SupplierApp? findSupplierById(String id) {
    try {
      return suppliers.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  void delete(SupplierApp supplierApp) {
    // pedindo para prd se deletar a si mesmo
    supplierApp.delete();
    // procurando o prd a ser deletado
    suppliers.removeWhere((u) => u.id == supplierApp.id);
    notifyListeners();
  }

  @override
  dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
