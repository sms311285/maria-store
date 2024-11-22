import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/bag/bag_product.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';

class BagManager extends ChangeNotifier {
  // Lista de bagProduct para carregar e guardar a lista de itens do carrinho
  List<BagProduct> items = [];

  // Para salvar o usuário logado, obtendo seus dados a partir do parametro
  UserApp? userApp;

  // Variavel para pegar o valor total dos prd
  num productsPrice = 0.0;

  // varialvel para guardar o calculo do total do pedido. como o delivery price é nulo inicialmente faz o tratamento para receber ?? 0
  num get totalPrice => productsPrice;

  // instanciando o firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // sistema de carregamento
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // variável para selecionar o forn
  SupplierApp? _selectedSupplier;
  // Função para obter a forn selecionada
  SupplierApp? get selectedSupplier => _selectedSupplier;
  // Função para selecionar a forn
  void setSelectedSupplier(SupplierApp? selectedSupplier) {
    _selectedSupplier = selectedSupplier;
    notifyListeners();
  }

  // variável para selecionar a forn para retirada
  PaymentMethodModel? _selectedPaymentMethod;
  // Função para obter a forn selecionada
  PaymentMethodModel? get selectedPaymentMethod => _selectedPaymentMethod;
  // Função para selecionar e desselecionar forma de pgto
  void togglePaymentMethodPurchase(PaymentMethodModel? paymentMethodId) {
    if (_selectedPaymentMethod == paymentMethodId) {
      _selectedPaymentMethod = null;
    } else {
      _selectedPaymentMethod = paymentMethodId;
      _selectedInstallmentPurchase = null;
      _selectedDays = null;
    }
    notifyListeners();
  }

  // FUNÇÃO PARA SELECIONAR A PARCELA
  int? _selectedInstallmentPurchase;
  // Method to update the selected installment
  // Getter para obter a parcela selecionada
  int? get selectedInstallmentPurchase => _selectedInstallmentPurchase;
  void setSelectedInstallmentPurchase(int? installmentPurchase) {
    _selectedInstallmentPurchase = installmentPurchase;
    notifyListeners(); // Notifies widgets to update
  }

  // Função para obter o número de parcelas disponíveis para o método de pagamento selecionado
  int? get selectedPaymentMethodInstallments {
    // Se o método de pagamento for nulo, retorna null
    if (_selectedPaymentMethod == null) return null;
    // Retorna o número de parcelas se estiver definido no método de pagamento
    return _selectedPaymentMethod?.installmentsPurchase;
  }

  // Variável para armazenar o número de dias selecionados
  int? _selectedDays; // Valor inicial
  int? get selectedDays => _selectedDays;
  // Método para atualizar a quantidade de dias
  void setSelectedDays(int days) {
    _selectedDays = days;
    notifyListeners(); // Notifica os ouvintes sobre a mudança
  }

  // limpar campos de seleção na tela de Entrega AddressScreen
  void clearSelectedOptions() {
    _selectedPaymentMethod = null;
    _selectedSupplier = null;
    _selectedInstallmentPurchase = null;
    notifyListeners();
  }

  // Metodo para atualizar o user logado e carregar seu carrinho
  void updateUser(UserManager userManager) {
    // Usuario sendo modificado
    userApp = userManager.userApp;
    // Zerando o valor do carrinho, para que tbm não aparece valores caso outro user logue
    productsPrice = 0.0;
    // Apagar itens do carrinho
    items.clear();
    // limpar forma de pagamento
    _selectedPaymentMethod = null;

    _selectedSupplier = null;

    _selectedInstallmentPurchase = null;

    // Carregar carrinho e endereço do user logado
    if (userApp != null) {
      // Carregar carrinho do user logado
      _loadBagItems();
    }
  }

  // Função para acessar o carrinho do user e buscar os documentos usando bagReference referencia do carrinho criado em userApp
  Future<void> _loadBagItems() async {
    // Buscar/carregar todos os documentos do carrinho
    final QuerySnapshot bagSnap = await userApp!.bagReference.get();
    // Pegar cada um dos documentos e mapear em um bagProduct que será criado a partir do documento recuperado
    // addListener, em cada item do carrinho, para obter as atualizaçõs na qtde exemplo se adicionar ou remover itens no carrinho
    items = bagSnap.docs.map((d) => BagProduct.fromDocument(d)..addListener(_onItemUpdated)).toList();
  }

  // Add produto ao carrinho passando um prd por parametro
  void addToBag(Product product) {
    // Tratando exceções
    try {
      // stackable - Procurar se tem algum item que seja empilhavel, para não aparecer item repetido caso for igual.
      final e = items.firstWhere((p) => p.stackable(product));
      // Se encontrar o item incrementar
      e.increment();
    } catch (e) {
      // Criar o bagProduct para Pegar produto, transformar em um prd que pode entrar no carrinho e add aos itens
      final bagProduct = BagProduct.fromProduct(product);
      // addListener parte do ChangeNotifier que observa a mudança e passa uma função (_onItemUpdated) por parametro para ser executado
      // adicionado addListener em cada item do carrinho _loadbagItems
      bagProduct.addListener(_onItemUpdated);
      // Adicionando itens
      items.add(bagProduct);
      // Salvar bagProduct (para adicionar dados no firebase precisa tranformar em map) lá no bagReference do userApp
      userApp!.bagReference.add(bagProduct.toBagItemMap()).then((doc) => bagProduct.id = doc.id);
      // Chamar _onItemUpdated manualmente para atualizar as mudanças
      _onItemUpdated();
    }
    notifyListeners();
  }

  // Metodo para remover o item do carrinho se a qtde for = 0
  void removeOfBag(BagProduct bagProduct) {
    // Procurar pelo item que corresponde o id e remove se o id for igual
    items.removeWhere((p) => p.id == bagProduct.id);
    // Remover do bagReference do userApp
    userApp?.bagReference.doc(bagProduct.id).delete();
    // Remover o addListener do bagProduct
    bagProduct.removeListener(_onItemUpdated);
    notifyListeners();
  }

  // Função para remover/limpar todos os itens do carrinho
  void clear() {
    // passar pelos itens do carrinho e limpar cada um
    for (final bagProduct in items) {
      // acessar a referencia do carrinho do user, acessar o documento e deletar o item
      userApp!.bagReference.doc(bagProduct.id).delete();
    }
    // pegar a lista local e apagar
    items.clear();
    notifyListeners();
  }

  // Metodo para ser executado no addlistener (Atualizar dados do item do carrinho)
  void _onItemUpdated() {
    // para recalcular o preço do carrinho, zerando os valores
    productsPrice = 0.0;
    // acessar cada um dos itens/produtos no carrinho
    for (int i = 0; i < items.length; i++) {
      final bagProduct = items[i];
      // Verificar se há prd com qtde  = 0
      if (bagProduct.quantity == 0) {
        // Remover do carrinho
        removeOfBag(bagProduct);
        i--;
        // Depois de remover o item do carrinho, pular a parte abaixo e voltar para o for
        continue;
      }
      // Para cada um dos prd se não estiver vazio e qtde zero:
      productsPrice += bagProduct.totalPrice;
      // Chamando a função para atualizar
      _updateBagProduct(bagProduct);
    }
    // Notificando as atualizações
    notifyListeners();
  }

  // Função para realizar a atualização no firebase
  void _updateBagProduct(BagProduct bagProduct) {
    if (bagProduct.id != null) {
      // Acessando o bagReference do userApp e atualizando os dados
      userApp?.bagReference.doc(bagProduct.id).update(bagProduct.toBagItemMap());
    }
  }
}
