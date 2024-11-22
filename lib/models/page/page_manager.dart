// Objeto para controlar as paginas do app e usar na BaseScreen
import 'package:flutter/material.dart';

class PageManager {
  // Construtor
  PageManager(this._pageController);

  // Criando pageController para recuperar na BaseScreen
  final PageController _pageController;

  // Variável para controlar a pagina iniciando em 0
  int page = 0;

  // Método para mudar a página
  void setPage(int value) {
    // if para validar se já está na pagina que selecionou
    if (value == page) return;
    page = value;
    _pageController.jumpToPage(value);
  }
}
