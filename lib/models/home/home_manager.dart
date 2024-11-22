// CLASSE PARA BUSCAR TODAS AS INFORMAÇÕES DA TELA

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/home/section.dart';

// Extender ChangeNotifier para observar as mudanças e edições na home
class HomeManager extends ChangeNotifier {
  // Carregar todas as seções da Home
  HomeManager() {
    _loadSections();
  }

  // Armazenando as seções numa lista de seções
  final List<Section> _sections = [];

  // Lista de seções entquanto estou editando
  List<Section> _editingSections = [];

  // variavel para controlar a edição da home
  bool editing = false;

  // loading para controlar o carregamento
  bool loading = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Buscar todas as seções do firebase e colocar numa lista
  Future<void> _loadSections() async {
    // Obter todas os documentos da Home, obtendo um snapshot (observar mudanças) de forma que as modificações apareça instantaneamente, ordenar pelo campo pos
    firestore.collection('home').orderBy('pos').snapshots().listen(
      (snapshot) {
        // dar um clear na lista para não duplicar as seções
        _sections.clear();
        // Passar por cada um dos documentos das seções que buscou na home
        for (final DocumentSnapshot document in snapshot.docs) {
          // Transformando em um objeto seção passando documento e add sections que é uma lista
          _sections.add(Section.fromDocument(document));
        }
        // Notificar as edições na tela
        notifyListeners();
      },
    );
  }

  // Metodo para add seção
  void addSection(Section section) {
    // Ir na lista de seções que está editando
    _editingSections.add(section);
    notifyListeners();
  }

  // metodo para remover a seção
  void removeSection(Section section) {
    // Ir na lista de seções que está editando
    _editingSections.remove(section);
    notifyListeners();
  }

  void moveUp(Section section) {
    final index = sections.indexOf(section);
    if (index > 0) {
      sections.removeAt(index);
      sections.insert(index - 1, section);
      notifyListeners();
    }
  }

  void moveDown(Section section) {
    final index = sections.indexOf(section);
    if (index < sections.length - 1) {
      sections.removeAt(index);
      sections.insert(index + 1, section);
      notifyListeners();
    }
  }

  // Get para poder acessar as seções de forma publica (Expondo a variavel), se é a seção original ou a de edição conforme declarado as variaveis (privadas) lem cima
  // Dessa forma fica mais facil de trabalhar, mantem a home original enquanto edita para caso descartar as edição não alterar a home
  List<Section> get sections {
    if (editing) {
      return _editingSections;
    } else {
      return _sections;
    }
  }

  // função que será chamada quando entrarmos no modo de edição
  void enterEditing() {
    editing = true;
    // Duplicando a lista de seções fazendo o map e clonando a seção
    _editingSections = _sections.map((s) => s.clone()).toList();
    // Avisando que estamos no modo de edição
    notifyListeners();
  }

  // Função que será chamada quando salvamos o modo de edição
  Future<void> saveEditing() async {
    // assumindo que o campo é valido inicialmente
    bool valid = true;

    // verificar se os dados são válidos, passar por cada seção que estiver editando
    for (final section in _editingSections) {
      // verificar se algum dos campos não é valido seta valid como false
      if (!section.valid()) valid = false;
    }

    // se não for valido retorna a função assism não chega no salvamento
    if (!valid) return;

    loading = true;
    notifyListeners();

    // inicializando a posicao
    int pos = 0;

    // salvamento, passar por cada sessão e pedir pra salvar
    for (final section in _editingSections) {
      await section.save(pos);
      pos++;
    }

    // Passar por todas as seções e verificar se ainda existe uma seção que não foi editada
    for (final section in List.from(_sections)) {
      // Se existir uma seção que não foi editada, deletar - se não tiver nenhum elemento cuho id do elemento é o mesmo id da seção
      if (!_editingSections.any((element) => element.id == section.id)) {
        // Deletar a seção
        await section.delete();
      }
    }

    loading = false;
    editing = false;
    notifyListeners();
  }

  // Função que será chamada quando descartarmos o modo de edição
  void discardEditing() {
    editing = false;
    notifyListeners();
  }
}
