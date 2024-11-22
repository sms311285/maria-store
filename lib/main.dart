import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maria_store/models/account_receive/account_receive_manager.dart';
import 'package:maria_store/models/admin_orders/admin_orders_manager.dart';
import 'package:maria_store/models/admin_purchases/admin_purchases_manager.dart';
import 'package:maria_store/models/admins/admins_manager.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/delivery/delivery_manager.dart';
import 'package:maria_store/models/account_pay/account_pay_manager.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/models/order/orders_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_manager.dart';
import 'package:maria_store/models/payment_method/payment_method_model.dart';
import 'package:maria_store/models/item_size/item_size_manager.dart';
import 'package:maria_store/models/purchase/purchase_model.dart';
import 'package:maria_store/models/stock/stock_manager.dart';
import 'package:maria_store/models/stores/stores_manager.dart';
import 'package:maria_store/models/stores/stores_model.dart';
import 'package:maria_store/models/supplier/admin_suppliers_manager.dart';
import 'package:maria_store/models/supplier/supplier_app.dart';
import 'package:maria_store/models/user/admin_users_manager.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/category/categories.dart';
import 'package:maria_store/models/category/categories_manager.dart';
import 'package:maria_store/models/favorites/favorites_manager.dart';
import 'package:maria_store/models/home/home_manager.dart';
import 'package:maria_store/models/product/product.dart';
import 'package:maria_store/models/product/product_manager.dart';
import 'package:maria_store/models/user/user_app.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:maria_store/screens/address/address_screen.dart';
import 'package:maria_store/screens/admin_suppliers/edit_supplier_screen.dart';
import 'package:maria_store/screens/admin_users/edit_user_screen.dart';
import 'package:maria_store/screens/bag/bag_screen.dart';
import 'package:maria_store/screens/base/base_screen.dart';
import 'package:maria_store/screens/cart/cart_screen.dart';
import 'package:maria_store/screens/confirmation/confirmation_purchase_screen.dart';
import 'package:maria_store/screens/confirmation/confirmation_screen.dart';
import 'package:maria_store/screens/edit_category/edit_categories_screen.dart';
import 'package:maria_store/screens/financial_balance/financial_balance_screen.dart';
import 'package:maria_store/screens/orders/checkout_screen.dart';
import 'package:maria_store/screens/edit_product/edit_product_screen.dart';
import 'package:maria_store/screens/login/login_screen.dart';
import 'package:maria_store/screens/edit_payment_method/edit_payment_method_screen.dart';
import 'package:maria_store/screens/product/product_screen.dart';
import 'package:maria_store/screens/purchases/checkout_purchase_screen.dart';
import 'package:maria_store/screens/purchases/finish_purchase_screen.dart';
import 'package:maria_store/screens/selections/select_category_screen.dart';
import 'package:maria_store/screens/selections/select_product_screen.dart';
import 'package:maria_store/screens/signup/signup_screen.dart';
import 'package:maria_store/screens/stock/stock_movement_screen.dart';
import 'package:maria_store/screens/stores/edit_store_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Antes usava Provider para acessar UserManager e outras classes de qqer lugar do app
    // Agora usa ChangeNotifierProvider por conta do consumer e notifyListeners e do ChangeNotifier do UserManager e outras classes
    // Criando o MultiProvider por boas praticas, conseguir inserir vários providers e organização codigo
    return MultiProvider(
      providers: [
        // Provider UserManager
        ChangeNotifierProvider(
          create: (_) => UserManager(),
          lazy: false,
        ),

        // Provider ProductManager
        ChangeNotifierProvider(
          create: (_) => ProductManager(),
          lazy: false,
        ),

        // Provider HomeManager
        ChangeNotifierProvider(
          create: (_) => HomeManager(),
          lazy: false,
        ),

        // Provider Categorias
        ChangeNotifierProvider(
          create: (_) => CategoriesManager(),
          lazy: false,
        ),

        // Provider formas de pgto
        ChangeNotifierProvider(
          create: (_) => PaymentMethodManager(),
          lazy: false,
        ),

        // stock
        ChangeNotifierProvider(
          create: (_) => StockManager(),
          lazy: false,
        ),

        // financial
        ChangeNotifierProvider(
          create: (_) => FinancialManager(),
          lazy: false,
        ),

        // Provider formas de pgto
        ChangeNotifierProvider(
          create: (_) => ItemSizeManager(),
          lazy: false,
        ),

        // delivery
        ChangeNotifierProvider(
          create: (_) => DeliveryManager(),
          lazy: false,
        ),

        // lojas
        ChangeNotifierProvider(
          create: (_) => StoresManager(),
        ),

        // ProxyProvider - Sempre que o userManager for alterado, o favoritesManager vai ser rebuildado caso consumer2
        // Para por exemplo pegar o favoritos do user logado e carregar o favorito do user especifico
        ChangeNotifierProxyProvider<UserManager, FavoritesManager>(
          create: (_) => FavoritesManager(),
          // Garante que o FavoritesManager seja criado assim que o app inicializa, não apenas quando necessário
          lazy: false,
          // Injetando o userManager para o favoritesManager
          update: (_, userManager, favoritesManager) => favoritesManager!..updateUser(userManager),
        ),

        // ProxyProvider - Sempre que o userManager for alterado, o ordersManager vai ser rebuildado caso consumer2 - Quando o user for modificado atualizar o OrderManager
        ChangeNotifierProxyProvider<UserManager, OrdersManager>(
          create: (_) => OrdersManager(),
          lazy: false,
          // passando updateUser(userManager.userApp), outra forma de fazer, nos outros pegamos atravez do user manager como <UserManager, CartManager>
          update: (_, userManager, ordersManager) => ordersManager!..updateUser(userManager.userApp),
        ),

        // ProxyProvider - Sempre que o userManager for alterado, o cartManager vai ser rebuildado caso consumer2
        // Para por exemplo pegar o carrinho do user logado e carregar o carrinho do user especifico
        ChangeNotifierProxyProvider<UserManager, CartManager>(
          create: (_) => CartManager(),
          // Garante que o FavoritesManager seja criado assim que o app inicializa, não apenas quando necessário
          lazy: false,
          // Injetando o userManager para o cartManager
          update: (_, userManager, cartManager) => cartManager!..updateUser(userManager),
        ),

        ChangeNotifierProxyProvider<UserManager, BagManager>(
          create: (_) => BagManager(),
          // Garante que o FavoritesManager seja criado assim que o app inicializa, não apenas quando necessário
          lazy: false,
          // Injetando o userManager para o cartManager
          update: (_, userManager, bagManager) => bagManager!..updateUser(userManager),
        ),

        // ProxyProvider para vinlcular o userManager com o AdminOrdersManager, rebuildar se o user for admin
        ChangeNotifierProxyProvider<UserManager, AdminOrdersManager>(
          create: (_) => AdminOrdersManager(),
          lazy: false,
          // Injetando o userManager para o AdminOrdersManager, updateUser é o metodo criado no AdminOrdersManager passando se o adm está habilitado ou não
          update: (_, userManager, adminOrdersManager) =>
              // passa adminEnabled como paramentro nomeado para ficar claro o bool do AdminOrdermanager pq está habilitando o admin
              adminOrdersManager!..updateAdmin(adminEnabled: userManager.adminEnabled),
        ),

        // ProxyProvider para vinlcular o userManager com o AdminPurchasesManager, rebuildar se o user for admin
        ChangeNotifierProxyProvider<UserManager, AdminPurchasesManager>(
          create: (_) => AdminPurchasesManager(),
          lazy: false,
          // Injetando o userManager para o AdminPurchasesManager, updateUser é o metodo criado no AdminPurchasesManager passando se o adm está habilitado ou não
          update: (_, userManager, adminPurchasesManager) =>
              // passa adminEnabled como paramentro nomeado para ficar claro o bool do AdminOrdermanager pq está habilitando o admin
              adminPurchasesManager!..updateAdmin(adminEnabled: userManager.adminEnabled),
        ),

        // ProxyProvider para vinlcular o userManager com o AdminUsersManager, rebuildar se o user for admin
        ChangeNotifierProxyProvider<UserManager, AdminUsersManager>(
          create: (_) => AdminUsersManager(),
          lazy: false,
          // Injetando o userManager para o adminUsersManager, updateUser é o metodo criado no AdminUsersManager
          update: (_, userManager, adminUsersManager) => adminUsersManager!..updateUser(userManager),
        ),

        // ProxyProvider para vinlcular o userManager com o AdminUsersManager, rebuildar se o user for admin
        ChangeNotifierProxyProvider<UserManager, AdminsManager>(
          create: (_) => AdminsManager(),
          lazy: false,
          // Injetando o userManager para o adminUsersManager, updateUser é o metodo criado no AdminUsersManager
          update: (_, userManager, adminsManager) => adminsManager!..updateUser(userManager),
        ),

        ChangeNotifierProxyProvider<UserManager, AdminSuppliersManager>(
          create: (_) => AdminSuppliersManager(),
          lazy: false,
          update: (_, userManager, adminSuppliersManager) =>
              adminSuppliersManager!..updateAdmin(adminEnabled: userManager.adminEnabled),
        ),

        // vincular user manager com accountpay
        ChangeNotifierProxyProvider<UserManager, AccountPayManager>(
          create: (_) => AccountPayManager(),
          lazy: false,
          update: (_, userManager, accountPayManager) {
            return accountPayManager!..updateAdmin(adminEnabled: userManager.adminEnabled);
          },
        ),

        // vincular user manager com accountreceive
        ChangeNotifierProxyProvider<UserManager, AccountReceiveManager>(
          create: (_) => AccountReceiveManager(),
          lazy: false,
          update: (_, userManager, accountReceiveManager) {
            return accountReceiveManager!..updateAdmin(adminEnabled: userManager.adminEnabled);
          },
        ),
      ],

      // MaterialApp
      child: MaterialApp(
        title: 'Loja Maria Luiza',
        debugShowCheckedModeBanner: false,

        // alterando o idioma para pt-BR
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        theme: ThemeData(
          // Cor geral do app
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 4, 125, 141)),
          // Cor geral do Scaffold
          scaffoldBackgroundColor: const Color.fromARGB(255, 4, 125, 141),
          // Configurações appBar
          appBarTheme: const AppBarTheme(
            color: Color.fromARGB(255, 4, 125, 141),
            // Tirar a sobra da appBar
            elevation: 0,
            // Cores dos ícones da AppBar
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),

        // Criando as rotas do app a partir do MaterialApp e onGenerateRoute
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // Rota Login
            case '/login':
              // Gerando uma nova MaterialPageRoute ou seja uma nova rota
              return MaterialPageRoute(
                builder: (_) => LoginScreen(),
              );

            // Rota Product
            case '/product':
              return MaterialPageRoute(
                builder: (_) => ProductScreen(
                  // O argumento passado ProductListTile para abrir a tela de produtos vem parar nos settings
                  product: settings.arguments as Product,
                ),
              );

            // Rota para carrinho
            case '/cart':
              return MaterialPageRoute(
                builder: (_) => const CartScreen(),
                // passando o obj settings ali de cima, para poder voltar varias telas
                settings: settings,
              );

            // Rota para carrinho
            case '/bag':
              return MaterialPageRoute(
                builder: (_) => const BagScreen(),
                // passando o obj settings ali de cima, para poder voltar varias telas
                settings: settings,
              );

            // Rota para endereço
            case '/address':
              return MaterialPageRoute(
                builder: (_) => const AddressScreen(),
              );

            // Rota para seleção de fornecedor para compra
            case '/close_purchase':
              return MaterialPageRoute(
                builder: (_) => const FinishPurchaseScreen(isSale: false),
              );

            // Rota para checkout
            case '/checkout':
              return MaterialPageRoute(
                builder: (_) => CheckoutScreen(),
              );

            // Rota para checkout de compras
            case '/checkout_purchase':
              return MaterialPageRoute(
                builder: (_) => CheckoutPurchaseScreen(),
              );

            // Rota para selecionar prd
            case '/select_product':
              return MaterialPageRoute(
                builder: (_) => const SelectProductScreen(),
              );

            // Rota para selecionar category
            case '/select_category':
              return MaterialPageRoute(
                builder: (_) => const SelectCategoryScreen(),
              );

            // Rota SignUp
            case '/signup':
              return MaterialPageRoute(
                builder: (_) => SignupScreen(),
              );

            // rota para movimentações financeiras
            case '/financial_movements':
              return MaterialPageRoute(
                builder: (_) => const FinancialBalanceScreen(),
              );

            // Rota para movimentações de estoque
            // case '/stock_movements':
            //   return MaterialPageRoute(
            //     builder: (_) => StockMovementScreen(
            //       product: settings.arguments as Product,
            //     ),
            //   );
            // QUANDO OS PARAMETROS É UM OBJETO E UMA STRING ELE ACEITA MAIS DE UM PARAMETRO NÃO ACEITA 2 OBJETOS
            case '/stock_movements':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => StockMovementScreen(
                  product: args['product'],
                  sizeName: args['sizeName'],
                ),
              );

            // Rota Editar Produto
            case '/edit_product':
              return MaterialPageRoute(
                builder: (_) => EditProductScreen(
                    // Passando argumento para ao editar a tela, buscar o produto especifico que está clicando p editar
                    // as Product? = setando null caso nenhum prd seja passado e assim seria uma criação de produto
                    // Ou tbm pode passar o argumento no ProductScreen para abrir a tela de prdutos com prd vazio para cadsatrar um novo
                    p: settings.arguments as Product?),
              );

            // Rota Editar Categoria
            case '/edit_categories':
              return MaterialPageRoute(
                builder: (_) => EditCategoriesScreen(categories: settings.arguments as Categories),
              );

            // Rota Editar forma de pgto
            case '/edit_payment_method':
              return MaterialPageRoute(
                builder: (_) => EditPaymentMethodScreen(paymentMethodModel: settings.arguments as PaymentMethodModel),
              );

            // Rota Editar supplier
            case '/edit_supplier':
              return MaterialPageRoute(
                builder: (_) => EditSupplierScreen(supplier: settings.arguments as SupplierApp?),
              );

            // Rota Editar user
            case '/edit_user':
              return MaterialPageRoute(
                builder: (_) => EditUserScreen(user: settings.arguments as UserApp?),
              );

            // rota para editar loja
            case '/edit_store':
              return MaterialPageRoute(
                builder: (_) => EditStoreScreen(s: settings.arguments as StoresModel?),
              );

            // Rota confirmation
            case '/confirmation':
              return MaterialPageRoute(
                // passaando a order para a ConfirmationScreen e passando o obj settings ali de cima, para poder voltar varias telas
                builder: (_) => ConfirmationScreen(order: settings.arguments as OrderModel),
              );

            // Rota confirmation
            case '/confirmation_purchase':
              return MaterialPageRoute(
                // passaando a order para a ConfirmationScreen e passando o obj settings ali de cima, para poder voltar varias telas
                builder: (_) => ConfirmationPurchaseScreen(purchase: settings.arguments as PurchaseModel),
              );

            // Rota Base
            case '/':
            default:
              return MaterialPageRoute(
                builder: (_) => const BaseScreen(),
                // passando o obj settings ali de cima, para poder voltar varias telas
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
