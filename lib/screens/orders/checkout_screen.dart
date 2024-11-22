import 'package:flutter/material.dart';
import 'package:maria_store/common/order/price_card.dart';
import 'package:maria_store/models/cart/cart_manager.dart';
import 'package:maria_store/models/order/checkout_manager.dart';
import 'package:maria_store/screens/orders/components/cpf_field.dart';
import 'package:maria_store/screens/orders/components/phone_field.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  // usa a globalKey para controlar o scaffold e snackbar
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // toda vez que chamar a tela de checkout, vai criar um novo CheckoutModel - proxyprovider para vincular CheckoutManager com CartManager
    return ChangeNotifierProxyProvider<CartManager, CheckoutManager>(
      // no create passa o CheckoutManager
      create: (_) => CheckoutManager(),
      // qdo houver alterações no cartManager vai atualizar o checkoutManager chamando oo updateCart
      update: (_, cartManager, checkoutManager) => checkoutManager!..updateCart(cartManager),
      // lazy: false, para que o checkoutManager seja criado apenas quando for instanciado
      lazy: false,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text(
            'Pagamento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        // consumer para rebuildar a tela ao houver modificação no CheckoutManager
        body: Consumer<CheckoutManager>(
          builder: (_, checkoutManager, __) {
            if (checkoutManager.loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Processando seu pagamento...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  ],
                ),
              );
            }
            // form para salvar CPF e Phone
            return Form(
              key: formKey,
              child: ListView(
                children: <Widget>[
                  // cpf
                  const CpfField(),
                  // phone
                  const PhoneField(),
                  PriceCard(
                    buttonText: 'Finalizar Pedido',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // salvando os dados do form via onsaved
                        formKey.currentState?.save();
                        // chamando a função checkout
                        checkoutManager.checkout(
                          // passando o onStockFail para informar que o estoque foi insuficiente
                          onStockFail: (e) {
                            // voltando para tela de inicio do carrinho, dar pop até chegar na tela cart, para isso ir lá no main e após o build dar um settings:settings
                            Navigator.of(context).popUntil((route) => route.settings.name == '/cart');
                          },

                          // chamando a função onSuccess para informar que o checkout foi concluído com sucesso passando o order com parametro para tela de confirmação
                          onSuccess: (order) {
                            // voltando para tela de inicio
                            Navigator.of(context).popUntil((route) => route.settings.name == '/');
                            // navegando para tela de confirmação
                            Navigator.of(context).pushNamed('/confirmation', arguments: order);
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
