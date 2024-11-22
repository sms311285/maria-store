import 'package:flutter/material.dart';
import 'package:maria_store/common/purchase/price_purchase_card.dart';
import 'package:maria_store/models/bag/bag_manager.dart';
import 'package:maria_store/models/purchase/checkout_purchase_manager.dart';
import 'package:provider/provider.dart';

class CheckoutPurchaseScreen extends StatelessWidget {
  CheckoutPurchaseScreen({super.key});

  // usa a globalKey para controlar o scaffold e snackbar
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // toda vez que chamar a tela de checkout, vai criar um novo CheckoutModel - proxyprovider para vincular CheckoutManager com PurchaseManager
    return ChangeNotifierProxyProvider<BagManager, CheckoutPurchaseManager>(
      // no create passa o CheckoutManager
      create: (_) => CheckoutPurchaseManager(),
      // qdo houver alterações no PurchaseManager vai atualizar o checkoutManager chamando oo updatePurchase
      update: (_, bagManager, checkoutPurchaseManager) => checkoutPurchaseManager!..updateBag(bagManager),
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
        body: Consumer<CheckoutPurchaseManager>(
          builder: (_, checkoutPurchaseManager, __) {
            if (checkoutPurchaseManager.loading) {
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
                  PricePurchaseCard(
                    buttonText: 'Finalizar Compra',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // salvando os dados do form via onsaved
                        formKey.currentState?.save();
                        // chamando a função checkout
                        checkoutPurchaseManager.checkoutPurchase(
                          // chamando a função onSuccess para informar que o checkout foi concluído com sucesso passando o order com parametro para tela de confirmação
                          onSuccess: (purchase) {
                            // voltando para tela de inicio
                            Navigator.of(context).popUntil((route) => route.settings.name == '/');
                            // navegando para tela de confirmação
                            Navigator.of(context).pushNamed('/confirmation_purchase', arguments: purchase);
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
