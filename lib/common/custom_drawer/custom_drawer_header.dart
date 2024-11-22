import 'package:flutter/material.dart';
import 'package:maria_store/models/page/page_manager.dart';
import 'package:maria_store/models/user/user_manager.dart';
import 'package:provider/provider.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),
      height: 180,
      // Consumer para alterar o estado e mostrar o nome ou não do user logado
      child: Consumer<UserManager>(
        builder: (_, userManager, __) {
          return Column(
            // Alinhar filhos conforme eixo espalhar itens
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            // Jogar conteudo para esquerda
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Lojas \nMaria Luiza',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Olá, ${userManager.userApp?.name ?? 'Visitante'}',
                // overflow - Para não estourar qdo nome do user for muito grande
                overflow: TextOverflow.ellipsis,
                // Maximo de linhas
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Botão sair ou entrar
              // ClipRRect para arredondar o efeito de toque no btn
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                // Material para o inkwell funcionar espalahr uma tinta no toque do btn
                child: Material(
                  color: Colors.transparent,
                  // InkWell para ter uma animação no toque detectar toque e alternar as paginas
                  child: InkWell(
                    onTap: () {
                      // Criado isLoggedIn no UserManager para verificar se tem alguem logado e dar ação no botão sair ou entrar
                      if (userManager.isLoggedIn) {
                        // Trocando a tela atual sempre que der o signOut, para não ir para na última tela que encontrar
                        context.read<PageManager>().setPage(0);
                        userManager.signOut();
                      } else {
                        // Ir pra tela de login pushesName pois a rota é nomeada
                        Navigator.of(context).pushNamed('/login');
                      }
                    },
                    // Mostrar texto de sair ou entrar
                    child: Text(
                      userManager.isLoggedIn ? 'Sair' : 'Entre ou cadastre-se >',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
