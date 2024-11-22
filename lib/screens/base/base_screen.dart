import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maria_store/screens/account_receive/account_receive_screen.dart';
import 'package:maria_store/screens/admin_orders/admin_orders_screen.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:maria_store/screens/admin_purchases/admin_purchases_screen.dart';
import 'package:maria_store/screens/admin_suppliers/admin_suppliers_screen.dart';
import 'package:maria_store/screens/admin_users/admin_users_screen.dart';
import 'package:maria_store/screens/admins/admins_screen.dart';
import 'package:maria_store/screens/categories/categories_screen.dart';
import 'package:maria_store/screens/delivery/delivery_screen.dart';
import 'package:maria_store/screens/favorites/favorites_screen.dart';
import 'package:maria_store/screens/account_pay/account_pay_screen.dart';
import 'package:maria_store/screens/home/home_screen.dart';
import 'package:maria_store/screens/orders/orders_screen.dart';
import 'package:maria_store/screens/payment_mehod/payment_method_screen.dart';
import 'package:maria_store/screens/products/products_screen.dart';
import 'package:maria_store/screens/stores/stores_screen.dart';
import 'package:provider/provider.dart';

// alterando para statefull para não sar erro ao dar hotreload e não cosneguir trocar de abas
class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  // Definindo o controller para alternar as páginas
  final PageController pageController = PageController();

  //TRAVANDO A TELA NA VERTICAL
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    // Provider para controlar as paginas
    return Provider(
      // Criando obj do tipo pageManager Passando pageController (do pageManager) para o Provider alterar tela
      create: (_) => PageManager(pageController),
      // Consumer para habilitar as telas para o admin
      child: Consumer<UserManager>(
        builder: (_, userManager, __) {
          // PageView para Alternar entre uma tela e outra
          return PageView(
            controller: pageController,
            // Impedir que movimente a pageview atraves de gestos
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              // Home = Page 0
              const HomeScreen(),

              // Todos Produtos = Page 1
              const ProductsScreen(),

              // Meus Pedidos = Page 2
              const OrdersScreen(),

              // Favoritos = Page 3
              const FavoritesScreen(),

              // Lojas = Page 4
              const StoresScreen(),

              // Telas para o admin, fazendo a verificação dentro da lista e adicionando as tabs com ...[]
              if (userManager.adminEnabled) ...[
                // tela usuários = Page 5
                const AdminUsersScreen(),

                // tela fornecedores Page 6
                const AdminSuppliersScreen(),

                // Tela admins = Page 7
                const AdminsScreen(),

                // Tela Categorias = Page 8
                const CategoriesScreen(),

                // Tela formas de pagamento = Page 9
                const PaymentMethodScreen(),

                // Tela Delivery = Page 10
                const DeliveryScreen(),

                // Tela todos os pedidos = Page 11
                const AdminOrdersScreen(),

                // Tela todos as compras = Page 12
                const AdminPurchasesScreen(),

                // Tela contas pagar = Page 13
                const AccountPayScreen(),

                // Tela contas receber = Page 14
                const AccountReceiveScreen(),
              ]
            ],
          );
        },
      ),
    );
  }
}
