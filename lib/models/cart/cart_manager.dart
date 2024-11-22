// Classe para gerenciar o carrinho, incluir, remover, buscar no banco

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/models/cart/cart_product.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/stores/stores_model.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:maria_store/services/cepaberto_service.dart';

class CartManager extends ChangeNotifier {
  // Lista de cartProduct para carregar e guardar a lista de itens do carrinho
  List<CartProduct> items = [];

  // Para salvar o usuário logado, obtendo seus dados a partir do parametro
  UserApp? userApp;

  // declarando obj Address
  Address? address;

  // Variavel para pegar o valor total dos prd
  num productsPrice = 0.0;

  // variavel para o preço da entrega
  num? deliveryPrice;

  // varialvel para guardar o calculo do total do pedido. como o delivery price é nulo inicialmente faz o tratamento para receber ?? 0
  num get totalPrice => productsPrice + (deliveryPrice ?? 0);

  // instanciando o firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // sistema de carregamento
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // variável de estado para a seleção de entrega/retirada
  String? _selectedOptionShipping;
  // Função para obter a opção de envio selecionada
  String? get selectedOptionShipping => _selectedOptionShipping;
  // Função para selecionar a opção de entrega/retirada e calcular frete baseado nesta seleção
  void setSelectedOptionShipping(String? optionShipping) {
    _selectedOptionShipping = optionShipping;
    // Se a opção for "Entrega" e o endereço estiver disponível, calcula o valor da entrega
    if (optionShipping == 'Entrega' && address != null) {
      calculateDelivery(address!.lat!, address!.long!);
    } else if (optionShipping == 'Retirada') {
      // Se for "Retirada", zera o valor da entrega
      deliveryPrice = 0;
    }
    notifyListeners();
  }

  // variável para selecionar a loja para retirada
  StoresModel? _selectedStore;
  // Função para obter a loja selecionada
  StoresModel? get selectedStore => _selectedStore;
  // Função para selecionar a loja
  void setSelectedStore(StoresModel? store) {
    _selectedStore = store;
    notifyListeners();
  }

  // variável para selecionar a forma de pgto
  PaymentMethodModel? _selectedPaymentMethod;
  // Função para obter a forma de pgto selecionada
  PaymentMethodModel? get selectedPaymentMethod => _selectedPaymentMethod;
  // Função para selecionar e desselecionar forma de pgto
  void togglePaymentMethodOrder(PaymentMethodModel? paymentMethodId) {
    if (_selectedPaymentMethod == paymentMethodId) {
      _selectedPaymentMethod = null;
    } else {
      _selectedPaymentMethod = paymentMethodId;
      _selectedInstallmentOrder = null;
    }
    notifyListeners();
  }

  // FUNÇÃO PARA SELECIONAR A PARCELA
  int? _selectedInstallmentOrder;
  // Method to update the selected installment
  // Getter para obter a parcela selecionada
  int? get selectedInstallmentOrder => _selectedInstallmentOrder;
  void setSelectedInstallmentOrder(int? installmentOrder) {
    _selectedInstallmentOrder = installmentOrder;
    notifyListeners(); // Notifies widgets to update
  }

  // Função para obter o número de parcelas disponíveis para o método de pagamento selecionado
  int? get selectedPaymentMethodInstallments {
    // Se o método de pagamento for nulo, retorna null
    if (_selectedPaymentMethod == null) return null;
    // Retorna o número de parcelas se estiver definido no método de pagamento
    return _selectedPaymentMethod?.installmentsOrder;
  }

  // limpar campos de seleção na tela de Entrega AddressScreen
  void clearSelectedOptions() {
    _selectedOptionShipping = null;
    _selectedStore = null;
    _selectedPaymentMethod = null;
    deliveryPrice = 0.0;
    _selectedInstallmentOrder = null;
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
    // limpar campo de forma de envio
    _selectedOptionShipping = null;
    // limpar loja
    _selectedStore = null;
    // limpar forma de pagamento
    _selectedPaymentMethod = null;
    // removendo o endereço para caso outro user logue não calcular o frete com endereço do user antigo logado pois o addres já estará disponível função criada ali em baixo
    _selectedInstallmentOrder = null;
    removeAddress();

    // Carregar carrinho e endereço do user logado
    if (userApp != null) {
      // Carregar carrinho do user logado
      _loadCartItems();
      // carregar o endereço, qdo entrar no app já ter o endereço do user se houver e já calcular o frete, qdo tbm ele entrar
      _loadUserAddress();
    }
  }

  // Função para acessar o carrinho do user e buscar os documentos usando cartReference referencia do carrinho criado em userApp
  Future<void> _loadCartItems() async {
    // Buscar/carregar todos os documentos do carrinho
    final QuerySnapshot cartSnap = await userApp!.cartReference.get();
    // Pegar cada um dos documentos e mapear em um CartProduct que será criado a partir do documento recuperado
    // addListener, em cada item do carrinho, para obter as atualizaçõs na qtde exemplo se adicionar ou remover itens no carrinho
    items = cartSnap.docs.map((d) => CartProduct.fromDocument(d)..addListener(_onItemUpdated)).toList();
  }

  // metodo para carregar o endereço do user e já calcular o frete
  Future<void> _loadUserAddress() async {
    // calcular o valor de entrega se tiver dentro do raio
    if (userApp?.address != null && await calculateDelivery(userApp!.address!.lat!, userApp!.address!.long!)) {
      // setando o endereço no obj address criado lem cima
      address = userApp!.address;
      notifyListeners();
    }
  }

  // Add produto ao carrinho passando um prd por parametro
  void addToCart(Product product) {
    // Tratando exceções
    try {
      // stackable - Procurar se tem algum item que seja empilhavel, para não aparecer item repetido caso for igual.
      final e = items.firstWhere((p) => p.stackable(product));
      // Se encontrar o item incrementar
      e.increment();
    } catch (e) {
      // Criar o cartProduct para Pegar produto, transformar em um prd que pode entrar no carrinho e add aos itens
      final cartProduct = CartProduct.fromProduct(product);
      // addListener parte do ChangeNotifier que observa a mudança e passa uma função (_onItemUpdated) por parametro para ser executado
      // adicionado addListener em cada item do carrinho _loadCartItems
      cartProduct.addListener(_onItemUpdated);
      // Adicionando itens
      items.add(cartProduct);
      // Salvar cartProduct (para adicionar dados no firebase precisa tranformar em map) lá no cartReference do userApp
      userApp!.cartReference.add(cartProduct.toCartItemMap()).then((doc) => cartProduct.id = doc.id);
      // Chamar _onItemUpdated manualmente para atualizar as mudanças
      _onItemUpdated();
    }
    notifyListeners();
  }

  // Metodo para remover o item do carrinho se a qtde for = 0
  void removeOfCart(CartProduct cartProduct) {
    // Procurar pelo item que corresponde o id e remove se o id for igual
    items.removeWhere((p) => p.id == cartProduct.id);
    // Remover do cartReference do userApp
    userApp?.cartReference.doc(cartProduct.id).delete();
    // Remover o addListener do cartProduct
    cartProduct.removeListener(_onItemUpdated);
    notifyListeners();
  }

  // Função para remover/limpar todos os itens do carrinho
  void clear() {
    // passar pelos itens do carrinho e limpar cada um
    for (final cartProduct in items) {
      // acessar a referencia do carrinho do user, acessar o documento e deletar o item
      userApp!.cartReference.doc(cartProduct.id).delete();
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
      final cartProduct = items[i];
      // Verificar se há prd com qtde  = 0
      if (cartProduct.quantity == 0) {
        // Remover do carrinho
        removeOfCart(cartProduct);
        i--;
        // Depois de remover o item do carrinho, pular a parte abaixo e voltar para o for
        continue;
      }
      // Para cada um dos prd se não estiver vazio e qtde zero:
      productsPrice += cartProduct.totalPrice;
      // Chamando a função para atualizar
      _updateCartProduct(cartProduct);
    }
    // Notificando as atualizações
    notifyListeners();
  }

  // Função para realizar a atualização no firebase
  void _updateCartProduct(CartProduct cartProduct) {
    if (cartProduct.id != null) {
      // Acessando o cartReference do userApp e atualizando os dados
      userApp?.cartReference.doc(cartProduct.id).update(cartProduct.toCartItemMap());
    }
  }

  // Verificar se o carrinho é valido e se os itens tem stock suficiente, para habilitar o btn de checkout
  bool get isCartValid {
    // Passar e pegar pelos itens do carrinho, cada um dos cartProduct
    for (final cartProduct in items) {
      // Se não tiver estoque, retorna false
      if (!cartProduct.hasStock) return false;
    }
    // Se passar por todos os itens e tiver estoque, retorna true
    return true;
  }

  // desabilitar btn contninuar para pagamento enquanto não calcular o frete, ver se o address é valido
  bool get isAddressValid => address != null && deliveryPrice != null;

  // endereço - função para obter o cep
  // ADDRESS
  Future<void> getAddress(String cep) async {
    // carregamento
    loading = true;

    // criando a variavel para receber o cep - enviar para cepaberto service
    final cepAbertoService = CepAbertoService();
    // tratando exceções
    try {
      // obter o endereço atraves da API
      final cepAbertoAddress = await cepAbertoService.getAddressFromCep(cep);

      // transformando o endereço do app a partir do construtor gerado em Address.dart
      if (cepAbertoAddress != null) {
        // declarando address a partir do obj decxlarado lem cima
        address = Address(
          street: cepAbertoAddress.logradouro,
          district: cepAbertoAddress.bairro,
          zipCode: cepAbertoAddress.cep,
          city: cepAbertoAddress.cidade.nome,
          state: cepAbertoAddress.estado.sigla,
          lat: cepAbertoAddress.latitude,
          long: cepAbertoAddress.longitude,
        );
      }
      // encerrando carregamento
      loading = false;
    } catch (e) {
      // encerrando carregamento
      loading = false;
      return Future.error('CEP Inválido...');
    }
  }

  // metodo para pegar o endereço enviado pelo addres input field e calcular
  Future<void> setAddress(Address address) async {
    // carregamento
    loading = true;
    // acessando o obj da classe declarado lem cima
    this.address = address;

    // passando calculateDelivery para calcular o frete ao setar ao receber o endereço da addresInputField
    if (await calculateDelivery(address.lat!, address.long!)) {
      // calculando com sucesso, salvando o endereço no usuário, somente se é valido, usando o set address
      userApp?.setAddress(address);
      // encerrando carregamento
      loading = false;
    } else {
      // encerrando carregamento
      loading = false;
      // retorna o erro
      return Future.error('Endereço fora do raio de entrega :(');
    }
  }

  // função para remover o cep atual informado (serve para edição do cep na tela de entrega)
  void removeAddress() {
    // setando nulo no address e no deliveryrpice
    address = null;
    deliveryPrice = null;
    notifyListeners();
  }

  // função para calcular o valor da entrega passando a lat e long para o calculo
  Future<bool> calculateDelivery(double lat, double long) async {
    // se endereço ou forma de envio for nulo, retorna true zera o frete
    if (address == null || _selectedOptionShipping == null) {
      deliveryPrice = 0;
      return true;
    }

    // obter a lat e long do firebase - obter o documento delivery
    final DocumentSnapshot doc = await firestore.doc('aux/delivery').get();

    // setar as variaveis lat e long da loja para o calculo de entrega
    final latStore = doc['lat'] as double;
    final longStore = doc['long'] as double;

    // calculo de distancia, setando as variaveis
    final maxkm = doc['maxkm'] as num;

    // variáveis para o calculo do frete
    final base = doc['base'] as num;
    final km = doc['km'] as num;

    // passando o geolocator - package que calcula a distância entre dois pontos (lat e long) retorna coordenadas geograficas em metros
    double dis = Geolocator.distanceBetween(latStore, longStore, lat, long);

    // convertendo a distancia de metros para em km
    dis /= 1000.0;

    // verificando a distancia
    if (dis > maxkm) {
      // se não conseguir calcular retorna false
      return false;
    } else {
      // faz o calculo
      deliveryPrice = base + dis * km;
      notifyListeners();
      return true;
    }
  }
}
