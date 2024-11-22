import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maria_store/common/commons/custom_icon_button.dart';
import 'package:maria_store/common/empty_screen/empty_card.dart';
import 'package:maria_store/models/admin_orders/admin_orders_manager.dart';
import 'package:maria_store/common/custom_drawer/custom_drawer.dart';
import 'package:maria_store/common/order/order_tile.dart';
import 'package:maria_store/models/order/order_model.dart';
import 'package:maria_store/screens/admin_orders/admin_filter_orders.dart';
import 'package:maria_store/screens/admin_orders/admin_orders_summary.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// alteado para StatefulWidget para quando dar o hotreload não parar de abrir o painel de filtros com click apenas arrastando
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
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
          'Todos os Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<AdminOrdersManager>(
        builder: (_, adminOrdersManager, __) {
          // chamado o metodo para filtrar os pedidos para não precisar chamar todas vez já instancia ele numa variavel dessa forma
          final filteredOrders = adminOrdersManager.filteredOrders;

          // retornar o SlidingUpPanel painel de filtros
          return SlidingUpPanel(
            //margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            // controler para poder tocar na barra e subir o painel
            controller: panelController,
            // escurecendo a tela de fundo enquanto o painel estiver aberto
            backdropEnabled: true,
            // bordas do painel de filtros aberto
            borderRadius: radius,
            // altura minima
            minHeight: 40,
            // altura max
            maxHeight: 510,

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

            // painel de filtros
            panel: Column(
              children: <Widget>[
                // detectar o toque e subir ou descer o painel
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
                  // wrpa para organizar em multiplas linhas
                  child: Wrap(
                    // pegando cada um dos status e mapear cada um dos status em um widget Retorna uma lista com todos os valores da enumeração
                    children: StatusOrder.values.map((s) {
                      return SizedBox(
                        // Largura para caber 2 por linha
                        width: MediaQuery.of(context).size.width / 2,
                        child: CheckboxListTile(
                          // pegando o nome dos status da função static da orderModel
                          title: Text(OrderModel.getStatusText(s)),
                          // não ocupar altura muito grande
                          dense: true,
                          // checando se o status = selectAll
                          value: s == StatusOrder.selectAll
                              // verifica se todos os filtros, exceto selectAll, estão selecionados. Se sim, o checkbox de "Selecionar Todos" é marcado.
                              ? adminOrdersManager.statusFilter.length == StatusOrder.values.length - 1
                              // Caso contrário, verifica se o status atual está na lista de filtros statusFilter do adminOrdersManager.
                              : adminOrdersManager.statusFilter.contains(s),
                          // selecionar e deselecionar itens, passando o status e o novo valor
                          onChanged: (v) {
                            // Quando o checkbox de "Selecionar Todos" é alterado (s == StatusOrder.selectAll),
                            // ele chama setAllStatusFilters(true) se for marcado, ou setAllStatusFilters(false) se for desmarcado.
                            if (s == StatusOrder.selectAll) {
                              // se o valor for true setar todos para true e
                              if (v == true) {
                                adminOrdersManager.setAllStatusFiltersOrders(true);
                              } else {
                                // se for false setar todos para false
                                adminOrdersManager.setAllStatusFiltersOrders(false);
                              }
                              // Se qualquer outro status for alterado, ele chama setStatusFilter para ativar ou desativar esse status específico.
                            } else {
                              adminOrdersManager.setStatusFilter(
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
                const AdminFilterOrders(),

                // espaçamento no rodapé
                const SizedBox(height: 8),
              ],
            ),

            // retornar as infos do filtro e os pedidos filtrados
            body: Column(
              children: <Widget>[
                // mostrar os textos de filtro apenas se tiver algum filtro setado
                if (adminOrdersManager.userFilter != null ||
                    adminOrdersManager.startDate != null ||
                    adminOrdersManager.endDate != null ||
                    adminOrdersManager.orderIdFilter != null ||
                    adminOrdersManager.productFilter != null ||
                    adminOrdersManager.sizeFilter != null ||
                    adminOrdersManager.paymentMethodFilter != null ||
                    adminOrdersManager.isDeliveryFilter != null)
                  // padding do texto das infos pedido filtrado
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Textos quando realiza filtro
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // txt filtro data
                            if (adminOrdersManager.startDate != null && adminOrdersManager.endDate != null)
                              Text(
                                'Data: ${DateFormat('dd/MM/yyyy').format(
                                  adminOrdersManager.startDate!,
                                )} até ${DateFormat('dd/MM/yyyy').format(
                                  adminOrdersManager.endDate!,
                                )}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro forma de pagamento
                            if (adminOrdersManager.paymentMethodFilter != null)
                              Text(
                                'Forma de pagamento: ${adminOrdersManager.paymentMethodFilter?.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro pedido
                            if (adminOrdersManager.orderIdFilter != null)
                              Text(
                                'Número Pedido: ${adminOrdersManager.orderIdFilter}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro retirada/entrega
                            if (adminOrdersManager.isDeliveryFilter != null)
                              Text(
                                'Forma de Envio: ${adminOrdersManager.isDeliveryFilter == true ? 'Entrega' : 'Retirada'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro tamanho
                            if (adminOrdersManager.sizeFilter != null)
                              Text(
                                'Tamanho: ${adminOrdersManager.sizeFilter}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro user
                            if (adminOrdersManager.userFilter != null)
                              Text(
                                'Cliente: ${adminOrdersManager.userFilter?.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),

                            // txt filtro produto
                            if (adminOrdersManager.productFilter != null)
                              Text(
                                'Produto: ${adminOrdersManager.productFilter}',
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
                            adminOrdersManager.setUserFilter(null);
                            adminOrdersManager.setStartDate(null);
                            adminOrdersManager.setEndDate(null);
                            adminOrdersManager.setOrderIdFilter(null);
                            adminOrdersManager.setProductFilter(null);
                            adminOrdersManager.setSizeFilter(null);
                            adminOrdersManager.setPaymentMethodFilter(null);
                            adminOrdersManager.setIsDeliveryFilter(null);
                          },
                        ),
                      ],
                    ),
                  ),

                // verificar se tem nenhum pedido
                if (filteredOrders.isEmpty)
                  const Expanded(
                    child: EmptyCard(
                      title: 'Nenhum venda foi realizado ainda!',
                      iconData: Icons.border_clear,
                    ),
                  )
                // se as condições forem atendidas, retornar a lista de pedidos
                else
                  Expanded(
                    child: ListView.builder(
                      // qtde de itens na lista passando o filteredOrders
                      itemCount: filteredOrders.length,
                      itemBuilder: (_, index) {
                        return OrderTile(
                          // passando o pedido a partir do index, passando filteredOrders index que são os pedidos filtrados se gouver filtros
                          order: filteredOrders[index],
                          // mostrar os botões de controle de pedido
                          showControls: true,
                        );
                      },
                    ),
                  ),

                // SUMMARY
                AdminOrdersSummary(adminOrdersManager: adminOrdersManager),
                // SizedeBox para não sobrepor os itens com o painel de filtros no rodapé
                const SizedBox(height: 135),
              ],
            ),
          );
        },
      ),
    );
  }
}
