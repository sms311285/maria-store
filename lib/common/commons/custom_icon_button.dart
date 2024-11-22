import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.iconData,
    required this.color,
    required this.onTap,
    this.colorInk,
    this.size,
  });

  // passando icone e cor e onTap por parametro para receber no CartTile
  final IconData iconData;
  final Color color;
  final VoidCallback? onTap;
  final Color? colorInk;
  final double? size;

  @override
  Widget build(BuildContext context) {
    // ClipRRect para arredondar o efeito de toque no btn
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      // Material para o inkwell funcionar espalahr uma tinta no toque do btn
      child: Material(
        // Cor do efeito de fundo
        color: colorInk ?? Colors.transparent,
        // Inkwell para ter animação qdo o btn for tocado
        child: InkWell(
          onTap: onTap,
          // padding para não ficar colado com outros widgets
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              iconData,
              // Alterando a cor dos ícones para mover pra cima e para baixo se a posição já for a primeira ou a última não deixar mover mais pra cima ou pra baixo
              color: onTap != null ? color : Colors.grey[400],
              size: size ?? 24,
            ),
          ),
        ),
      ),
    );
  }
}
