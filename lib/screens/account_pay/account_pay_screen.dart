import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/account_pay/account_pay_model.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';
import 'package:maria_store/screens/account_pay/components/account_pay_filters.dart';
import 'package:maria_store/screens/account_pay/components/account_pay_summary.dart';
import 'package:maria_store/screens/account_pay/components/account_pay_tile.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/models/account_pay/account_pay_manager.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AccountPayScreen extends StatefulWidget {
  const AccountPayScreen({super.key});

  @override
  State<AccountPayScreen> createState() => _AccountPayScreenState();
}

class _AccountPayScreenState extends State<AccountPayScreen> {
  // controlador do painel ao tocar abrir ou fechar
  final PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    // obtendo a cor padrão
    final Color primaryColor = Theme.of(context).primaryColor;

    final financialManager = context.watch<FinancialManager>();

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Contas à Pagar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              financialManager.clearMovementsFinancial();
              // navegar para rota de movimentações financieras
              Navigator.of(context).pushNamed('/financial_movements');
            },
            icon: const Icon(Icons.bar_chart),
          )
        ],
      ),

      // corpo
      body: Consumer<AccountPayManager>(
        builder: (_, accountPayManager, __) {
          final filteredAccountPay = accountPayManager.filteredAccountPay;

          return SlidingUpPanel(
            controller: panelController,
            backdropEnabled: true,
            borderRadius: radius,
            minHeight: 40,
            maxHeight: 505,
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

            // painel
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
                    children: StatusAccountPay.values.map((s) {
                      return SizedBox(
                        // Largura para caber 2 por linha
                        width: MediaQuery.of(context).size.width / 2,
                        child: CheckboxListTile(
                          title: Text(AccountPayModel.getStatusText(s)),
                          // não ocupar altura muito grande
                          dense: true,
                          // checando se o status = selectAll
                          value: s == StatusAccountPay.selectAll
                              // verifica se todos os filtros, exceto selectAll, estão selecionados. Se sim, o checkbox de "Selecionar Todos" é marcado.
                              ? accountPayManager.statusFilter.length == StatusAccountPay.values.length - 1
                              // Caso contrário, verifica se o status atual está na lista de filtros statusFilter do accountPayManager.
                              : accountPayManager.statusFilter.contains(s),
                          // selecionar e deselecionar itens, passando o status e o novo valor
                          onChanged: (v) {
                            // Quando o checkbox de "Selecionar Todos" é alterado (s == StatusAccountPay.selectAll),
                            // ele chama setAllStatusFilters(true) se for marcado, ou setAllStatusFilters(false) se for desmarcado.
                            if (s == StatusAccountPay.selectAll) {
                              // se o valor for true setar todos para true e
                              if (v == true) {
                                accountPayManager.setAllStatusAccountPayFilters(true);
                              } else {
                                // se for false setar todos para false
                                accountPayManager.setAllStatusAccountPayFilters(false);
                              }
                              // Se qualquer outro status for alterado, ele chama setStatusFilter para ativar ou desativar esse status específico.
                            } else {
                              accountPayManager.setStatusFilter(
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
                const AccountPayFilters(),

                // espaçamento no rodapé
                const SizedBox(height: 8),
              ],
            ),

            body: Column(
              children: <Widget>[
                // verificar se tem nenhum pedido
                if (accountPayManager.supplierFilter != null ||
                    accountPayManager.startDateFilter != null ||
                    accountPayManager.endDateFilter != null ||
                    accountPayManager.startDatePayFilter != null ||
                    accountPayManager.endDatePayFilter != null ||
                    accountPayManager.paymentMethodFilter != null ||
                    accountPayManager.startDueDateFilter != null ||
                    accountPayManager.endDueDateFilter != null ||
                    accountPayManager.accountPayIdFilter != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // txt filtro data
                            if (accountPayManager.startDateFilter != null && accountPayManager.endDateFilter != null)
                              Text(
                                'Data: ${DateFormat('dd/MM/yyyy').format(
                                  accountPayManager.startDateFilter!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  accountPayManager.endDateFilter!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // data de venc
                            if (accountPayManager.startDueDateFilter != null &&
                                accountPayManager.endDueDateFilter != null)
                              Text(
                                'Data Venc: ${DateFormat('dd/MM/yyyy').format(
                                  accountPayManager.startDueDateFilter!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  accountPayManager.endDueDateFilter!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // data pgto
                            if (accountPayManager.startDatePayFilter != null &&
                                accountPayManager.endDatePayFilter != null)
                              Text(
                                'Data Pgto: ${DateFormat('dd/MM/yyyy').format(
                                  accountPayManager.startDatePayFilter!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  accountPayManager.endDatePayFilter!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro forma de pagamento
                            if (accountPayManager.paymentMethodFilter != null)
                              Text(
                                'Forma de pagamento: ${accountPayManager.paymentMethodFilter?.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro nro conta
                            if (accountPayManager.accountPayIdFilter != null)
                              Text(
                                'Número Conta: ${accountPayManager.accountPayIdFilter}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // forncedeor
                            if (accountPayManager.supplierFilter != null)
                              Text(
                                'Fornecedor: ${accountPayManager.supplierFilter?.name}',
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
                            accountPayManager.setAccountPayIdFilter(null);
                            accountPayManager.setSupplierFilter(null);
                            accountPayManager.setStartDate(null);
                            accountPayManager.setEndDate(null);
                            accountPayManager.setStartDatePay(null);
                            accountPayManager.setEndDatePay(null);
                            accountPayManager.setPaymentMethodFilter(null);
                            accountPayManager.setStartDueDate(null);
                            accountPayManager.setEndDueDate(null);
                          },
                        ),
                      ],
                    ),
                  ),
                // verificar se tem nenhum pedido
                if (filteredAccountPay.isEmpty)
                  const Expanded(
                    child: EmptyCard(
                      title: 'Nenhum conta foi realizado ainda!',
                      iconData: Icons.border_clear,
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      // qtde de itens na lista passando o filteredOrders
                      itemCount: filteredAccountPay.length,
                      itemBuilder: (_, index) {
                        return AccountPayTile(
                          // passando o pedido a partir do index, passando filteredOrders index que são os pedidos filtrados se gouver filtros
                          accountPayModel: filteredAccountPay[index],
                          // mostrar os botões de controle de pedido
                          showControls: true,
                        );
                      },
                    ),
                  ),
                // SUMMARY
                AccountPaySummary(accountPayManager: accountPayManager),
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
