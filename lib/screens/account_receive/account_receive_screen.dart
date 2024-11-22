import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/models/account_receive/account_receive_manager.dart';
import 'package:maria_store/models/account_receive/account_receive_model.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/models/financial_balance/financial_manager.dart';
import 'package:maria_store/screens/account_receive/components/account_receive_filter.dart';
import 'package:maria_store/screens/account_receive/components/account_receive_summary.dart';
import 'package:maria_store/screens/account_receive/components/account_receive_tile.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AccountReceiveScreen extends StatefulWidget {
  const AccountReceiveScreen({super.key});

  @override
  State<AccountReceiveScreen> createState() => _AccountReceiveScreenState();
}

class _AccountReceiveScreenState extends State<AccountReceiveScreen> {
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
          'Contas à Receber',
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
      body: Consumer<AccountReceiveManager>(
        builder: (_, accountReceiveManager, __) {
          final filteredAccountReceive = accountReceiveManager.filteredAccountReceive;

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
                    children: StatusAccountReceive.values.map((s) {
                      return SizedBox(
                        // Largura para caber 2 por linha
                        width: MediaQuery.of(context).size.width / 2,
                        child: CheckboxListTile(
                          title: Text(AccountReceiveModel.getStatusText(s)),
                          // não ocupar altura muito grande
                          dense: true,
                          // checando se o status = selectAll
                          value: s == StatusAccountReceive.selectAll
                              // verifica se todos os filtros, exceto selectAll, estão selecionados. Se sim, o checkbox de "Selecionar Todos" é marcado.
                              ? accountReceiveManager.statusFilter.length == StatusAccountReceive.values.length - 1
                              // Caso contrário, verifica se o status atual está na lista de filtros statusFilter do accountReceiveManager.
                              : accountReceiveManager.statusFilter.contains(s),
                          // selecionar e deselecionar itens, passando o status e o novo valor
                          onChanged: (v) {
                            // Quando o checkbox de "Selecionar Todos" é alterado (s == StatusAccountReceive.selectAll),
                            // ele chama setAllStatusFilters(true) se for marcado, ou setAllStatusFilters(false) se for desmarcado.
                            if (s == StatusAccountReceive.selectAll) {
                              // se o valor for true setar todos para true e
                              if (v == true) {
                                accountReceiveManager.setAllStatusAccountReceiveFilters(true);
                              } else {
                                // se for false setar todos para false
                                accountReceiveManager.setAllStatusAccountReceiveFilters(false);
                              }
                              // Se qualquer outro status for alterado, ele chama setStatusFilter para ativar ou desativar esse status específico.
                            } else {
                              accountReceiveManager.setStatusFilter(
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
                const AccountReceiveFilters(),

                // espaçamento no rodapé
                const SizedBox(height: 8),
              ],
            ),

            body: Column(
              children: <Widget>[
                // verificar se tem nenhum pedido
                if (accountReceiveManager.userFilter != null ||
                    accountReceiveManager.startDateFilter != null ||
                    accountReceiveManager.endDateFilter != null ||
                    accountReceiveManager.startDateReceiveFilter != null ||
                    accountReceiveManager.endDateReceiveFilter != null ||
                    accountReceiveManager.paymentMethodFilter != null ||
                    accountReceiveManager.startDueDateFilter != null ||
                    accountReceiveManager.endDueDateFilter != null ||
                    accountReceiveManager.accountReceiveIdFilter != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // txt filtro data
                            if (accountReceiveManager.startDateFilter != null &&
                                accountReceiveManager.endDateFilter != null)
                              Text(
                                'Data: ${DateFormat('dd/MM/yyyy').format(
                                  accountReceiveManager.startDateFilter!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  accountReceiveManager.endDateFilter!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // data de venc
                            if (accountReceiveManager.startDueDateFilter != null &&
                                accountReceiveManager.endDueDateFilter != null)
                              Text(
                                'Data Venc: ${DateFormat('dd/MM/yyyy').format(
                                  accountReceiveManager.startDueDateFilter!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  accountReceiveManager.endDueDateFilter!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // data pgto
                            if (accountReceiveManager.startDateReceiveFilter != null &&
                                accountReceiveManager.endDateReceiveFilter != null)
                              Text(
                                'Data Recebimento: ${DateFormat('dd/MM/yyyy').format(
                                  accountReceiveManager.startDateReceiveFilter!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  accountReceiveManager.endDateReceiveFilter!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro forma de pagamento
                            if (accountReceiveManager.paymentMethodFilter != null)
                              Text(
                                'Forma de recebimento: ${accountReceiveManager.paymentMethodFilter?.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro nro conta
                            if (accountReceiveManager.accountReceiveIdFilter != null)
                              Text(
                                'Número Conta: ${accountReceiveManager.accountReceiveIdFilter}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // forncedeor
                            if (accountReceiveManager.userFilter != null)
                              Text(
                                'Cliente: ${accountReceiveManager.userFilter?.name}',
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
                            accountReceiveManager.setAccountReceiveIdFilter(null);
                            accountReceiveManager.setUserFilter(null);
                            accountReceiveManager.setStartDate(null);
                            accountReceiveManager.setEndDate(null);
                            accountReceiveManager.setStartDateReceive(null);
                            accountReceiveManager.setEndDateReceive(null);
                            accountReceiveManager.setPaymentMethodFilter(null);
                            accountReceiveManager.setStartDueDate(null);
                            accountReceiveManager.setEndDueDate(null);
                          },
                        ),
                      ],
                    ),
                  ),
                // verificar se tem nenhum pedido
                if (filteredAccountReceive.isEmpty)
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
                      itemCount: filteredAccountReceive.length,
                      itemBuilder: (_, index) {
                        return AccountReceiveTile(
                          // passando o pedido a partir do index, passando filteredOrders index que são os pedidos filtrados se gouver filtros
                          accountReceiveModel: filteredAccountReceive[index],
                          // mostrar os botões de controle de pedido
                          showControls: true,
                        );
                      },
                    ),
                  ),
                // SUMMARY
                AccountReceiveSummary(accountReceiveManager: accountReceiveManager),
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
