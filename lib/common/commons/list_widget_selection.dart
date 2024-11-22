import 'package:flutter/material.dart';

class ListWidgetSelection extends StatelessWidget {
  const ListWidgetSelection({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onPressed,
    this.image,
    this.isSale,
  });

  final String category;
  final bool isSelected;
  final String? image;
  final VoidCallback onPressed;
  final bool? isSale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Align(
        alignment: Alignment.center,
        child: Container(
          // height: 40,
          height: isSelected ? 40 : 35,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? Colors.white.withAlpha(450) : Colors.white.withAlpha(50),
            // color: isSelected ? Colors.white.withAlpha(450) : Colors.transparent,
          ),
          child: Row(
            children: <Widget>[
              if (image != null)
                Image.network(
                  image!,
                  width: isSelected ? 30 : 25,
                  height: isSelected ? 30 : 25,
                  fit: BoxFit.cover,
                ),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white.withAlpha(430),
                  fontWeight: FontWeight.bold,
                  fontSize: isSelected ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
