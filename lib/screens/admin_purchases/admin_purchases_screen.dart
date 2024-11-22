import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/common/purchase/purchase_tile.dart';
import 'package:maria_store/models/admin_purchases/admin_purchases_manager.dart';
import 'package:maria_store/models/purchase/purchase_model.dart';
import 'package:maria_store/screens/admin_purchases/admin_filter_purchases.dart';
import 'package:maria_store/screens/admin_purchases/admin_purchases_summary.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AdminPurchasesScreen extends StatefulWidget {
  const AdminPurchasesScreen({super.key});

  @override
  State<AdminPurchasesScreen> createState() => _AdminPurchasesScreenState();
}

class _AdminPurchasesScreenState extends State<AdminPurchasesScreen> {
  // controlador do painel ao tocar abrir ou fechar
  final PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    // arredondamento das bordas
    BorderRadiusGeometry radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    // obtendo a cor padrão
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Todas as Compras',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // aqui vai um consumer
      body: Consumer<AdminPurchasesManager>(
        builder: (_, adminPurchasesManager, __) {
          // chamado o metodo para filtrar os pedidos para não precisar chamar todas vez já instancia ele numa variavel dessa forma
          final filteredPurchases = adminPurchasesManager.filteredPurchases;

          return SlidingUpPanel(
            controller: panelController,
            backdropEnabled: true,
            borderRadius: radius,
            minHeight: 40,
            maxHeight: 470,
            // collapsed ações/stilo quando fechado gesture detector para qdo tocar tbm subir o painel de filtro
            collapsed: GestureDetector(
              onTap: () {
                // verificando se está fechado se clicado abrir ou fechar
                if (panelController.isPanelClosed) {
                  panelController.open();
                } else {
                  panelController.close();
                }
              },

              // estilo enquanto colapsado ou seja fechado
              child: Container(
                // bordas do painel colapsado / fechado
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: radius,
                ),
                child: Center(
                  child: Text(
                    "Deslize ⬆ para os filtros",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            panel: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    // verificando se está fechado se clicado abrir ou fechar
                    if (panelController.isPanelClosed) {
                      panelController.open();
                    } else {
                      panelController.close();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: primaryColor,
                    ),
                    // altura do painel
                    height: 40,
                    // centralizar
                    alignment: Alignment.center,
                    // texto do painel
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.filter_alt_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Filtros',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // itens flags e demais filtros
                Expanded(
                  child: Wrap(
                    // pegando cada um dos status e mapear cada um dos status em um widget Retorna uma lista com todos os valores da enumeração
                    children: StatusPurchase.values.map((s) {
                      return SizedBox(
                        // Largura para caber 2 por linha
                        width: MediaQuery.of(context).size.width / 2,
                        child: CheckboxListTile(
                          // pegando o nome dos status da função static da ordPurchaseModelerModel
                          title: Text(PurchaseModel.getStatusText(s)),
                          // não ocupar altura muito grande
                          dense: true,
                          // checando se o status = selectAll
                          value: s == StatusPurchase.selectAll
                              // verifica se todos os filtros, exceto selectAll, estão selecionados. Se sim, o checkbox de "Selecionar Todos" é marcado.
                              ? adminPurchasesManager.statusFilter.length == StatusPurchase.values.length - 1
                              // Caso contrário, verifica se o status atual está na lista de filtros statusFilter do adminPurchasesManager.
                              : adminPurchasesManager.statusFilter.contains(s),
                          // selecionar e deselecionar itens, passando o status e o novo valor
                          onChanged: (v) {
                            // Quando o checkbox de "Selecionar Todos" é alterado (s == StatusPurchase.selectAll),
                            // ele chama setAllStatusFilters(true) se for marcado, ou setAllStatusFilters(false) se for desmarcado.
                            if (s == StatusPurchase.selectAll) {
                              // se o valor for true setar todos para true e
                              if (v == true) {
                                adminPurchasesManager.setAllStatusFilters(true);
                              } else {
                                // se for false setar todos para false
                                adminPurchasesManager.setAllStatusFilters(false);
                              }
                              // Se qualquer outro status for alterado, ele chama setStatusFilter para ativar ou desativar esse status específico.
                            } else {
                              adminPurchasesManager.setStatusFilter(
                                // recebendo status em si
                                status: s,
                                // controlar o que está ativo e inativo
                                enablad: v,
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // filtros diversos
                const AdminFilterPurchases(),

                // espaçamento no rodapé
                const SizedBox(height: 8),
              ],
            ),

            // retornar as infos do filtro e os pedidos filtrados
            body: Column(
              children: <Widget>[
                // verificar se tem nenhum pedido
                if (adminPurchasesManager.supplierFilter != null ||
                    adminPurchasesManager.startDate != null ||
                    adminPurchasesManager.endDate != null ||
                    adminPurchasesManager.purchaseIdFilter != null ||
                    adminPurchasesManager.productFilter != null ||
                    adminPurchasesManager.sizeFilter != null ||
                    adminPurchasesManager.paymentMethodFilter != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // txt filtro data
                            if (adminPurchasesManager.startDate != null && adminPurchasesManager.endDate != null)
                              Text(
                                'Data: ${DateFormat('dd/MM/yyyy').format(
                                  adminPurchasesManager.startDate!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  adminPurchasesManager.endDate!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro forma de pagamento
                            if (adminPurchasesManager.paymentMethodFilter != null)
                              Text(
                                'Forma de pagamento: ${adminPurchasesManager.paymentMethodFilter?.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro pedido
                            if (adminPurchasesManager.purchaseIdFilter != null)
                              Text(
                                'Número Compra: ${adminPurchasesManager.purchaseIdFilter}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro tamanho
                            if (adminPurchasesManager.sizeFilter != null)
                              Text(
                                'Tamanho: ${adminPurchasesManager.sizeFilter}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // forncedeor
                            if (adminPurchasesManager.supplierFilter != null)
                              Text(
                                'Fornecedor: ${adminPurchasesManager.supplierFilter?.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            // txt filtro produto
                            if (adminPurchasesManager.productFilter != null)
                              Text(
                                'Produto: ${adminPurchasesManager.productFilter}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            const SizedBox(height: 5),
                          ],
                        ),
                        // btn limpar filtro
                        CustomIconButton(
                          iconData: Icons.close,
                          color: Colors.white,
                          onTap: () {
                            // setando null na função para limpar o filtro
                            adminPurchasesManager.setSupplierFilter(null);
                            adminPurchasesManager.setStartDate(null);
                            adminPurchasesManager.setEndDate(null);
                            adminPurchasesManager.setPurchaseIdFilter(null);
                            adminPurchasesManager.setProductFilter(null);
                            adminPurchasesManager.setSizeFilter(null);
                            adminPurchasesManager.setPaymentMethodFilter(null);
                          },
                        ),
                      ],
                    ),
                  ),
                // verificar se tem nenhum pedido
                if (filteredPurchases.isEmpty)
                  const Expanded(
                    child: EmptyCard(
                      title: 'Nenhum compra foi realizado ainda!',
                      iconData: Icons.border_clear,
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      // qtde de itens na lista passando o filteredOrders
                      itemCount: filteredPurchases.length,
                      itemBuilder: (_, index) {
                        return PurchaseTile(
                          // passando o pedido a partir do index, passando filteredOrders index que são os pedidos filtrados se gouver filtros
                          purchase: filteredPurchases[index],
                          // mostrar os botões de controle de pedido
                          showControls: true,
                        );
                      },
                    ),
                  ),

                // SUMMARY
                AdminPurchasesSummary(adminPurchasesManager: adminPurchasesManager),
                // SizedeBox para não sobrepor os itens com o painel de filtros no rodapé
                const SizedBox(height: 135)
              ],
            ),
          );
        },
      ),
    );
  }
}
