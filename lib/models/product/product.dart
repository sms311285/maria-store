// Classe para converter o documento em um objeto
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Escondendo o CarouselController do pacote carousel_slider para evitar conflito de nomes devido atualização do flutter
import 'package:flutter/material.dart' hide CarouselController;
import 'package:maria_store/models/item_size/item_size.dart';
import 'package:uuid/uuid.dart';

class Product extends ChangeNotifier {
  // Instanciando firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Instanciando o storage
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Criando uma referencia pegando os dados atuais para salvar, obtendo o documento relativo ao produto (id) que estou editando
  DocumentReference get firestoreRef => firestore.doc('products/$id');

  // Criando a referencia do storage e criando as pastas com id do prd acessando o ref pasta principal
  Reference get storageRef => storage.ref().child('products').child(id!);

  // Variaveis
  String? id;
  String? name;
  String? description;
  String? categoryId;
  // Lista de imagens
  List<String>? images;
  // Lista de tamanhos
  List<ItemSize>? sizes;

  // Variavel para salvar as novas imagens de uma lista dinamica para aceitar tanto de file ou url
  List<dynamic>? newImages;

  // variavel para controlar o exclusão do prd
  bool? deleted;

  // Construtor para tbm criar um clone do prd original para não alterar o prd original qdo editar o prd e descartar
  Product({
    this.id,
    this.name,
    this.categoryId,
    this.description,
    this.images,
    this.sizes,
    this.deleted = false,
  }) {
    // Inicializando as variáveis vazias para na hora de criar um novo produto para não dar erro de null
    images = images ?? []; // Se passar a lista de img insere em image
    sizes = sizes ?? [];
  }

  // Construtor - Sempre converte os dados do firebase em objeto no construtor para ficar mais prático recuperar os dados objeto que contém os dados do Produto
  Product.fromDocument(DocumentSnapshot document) {
    id = document.id;
    name = document['name'] as String;
    categoryId = document['cid'] as String;
    description = document['description'] as String;

    // Recuperando a lista de imagem, lista dinamica
    images = List<String>.from(document['images'] as List<dynamic>);

    // deletar prd passando false fazendo a verificação caso se não houver o campo assume que não está eletado
    deleted = (document['deleted'] ?? false) as bool;

    // Tratando exceções caso o produto não tenha tamanhos
    try {
      // Recuperando a lista de tamanhos passando itemSize vazio jogando dentro do s e transformando em uma lista dinamica
      sizes = (document['sizes'] as List<dynamic>).map((s) => ItemSize.fromMap(s as Map<String, dynamic>)).toList();
    } catch (e) {
      // Retorna uma lista vazia caso o prd não tenha tamanho
      sizes = ([]).map((s) => ItemSize.fromMap(s as Map<String, dynamic>)).toList();
    }
  }

  // Criando loading, carregamento ao salvar igual fez no login
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // Variavel para Selecionar tamanhos
  ItemSize? _selectedSize;
  // Criando get para dar o selectedSize = algo para chamar o notify automatico
  ItemSize? get selectedSize => _selectedSize;
  // Selecionar tamanhos
  set selectedSize(ItemSize? value) {
    _selectedSize = value;
    // Notificando item selecionado
    notifyListeners();
  }

  // Variavel para Selecionar tamanhos para compra
  ItemSize? _selectedSizePurchase;
  // Criando get para dar o selectedSizePurchase = algo para chamar o notify automatico
  ItemSize? get selectedSizePurchase => _selectedSizePurchase;
  // Selecionar tamanhos
  set selectedSizePurchase(ItemSize? valuePurchase) {
    _selectedSizePurchase = valuePurchase;
    // Notificando item selecionado
    notifyListeners();
  }

  // get para verificar qtde itens, total estoque para usar por ex para ativar o btn de add ao carrinho
  int get totalStock {
    int stock = 0;
    // Passando por cada tamanho pegar o estoque do tamanho especifico e add ao estoque geral e retornar o estoque
    for (final size in sizes!) {
      stock += size.stock!;
    }
    return stock;
  }

  // get para verificar se tem estoque e se não está deletado o prd
  bool get hasStock {
    return totalStock > 0 && !deleted!;
  }

  // get para buscar o preço base
  num get basePrice {
    // Pegando o menor preco definindo variavel infinita para comparar os precos e retornar o menor preco geral do item
    num lowest = double.infinity;
    // Passando por cada tamanho pegar o preco do tamanho especifico
    for (final size in sizes!) {
      // verificar os preços e add o menor preco geral
      if (size.price! < lowest) lowest = size.price!;
    }
    // retornar o preco
    return lowest;
  }

  // Função para pegar o tamanho pelo nome, pegar o primeiro que encontrar com o nome que foi passado
  ItemSize? findSize(String name) {
    // Tratando exceções caso o prd não tenha tamanho especifico
    try {
      // Pega o primeiro nome de tamanho do prd que encontrar
      return sizes?.firstWhere((s) => s.name == name);
    } catch (e) {
      return null;
    }
  }

  // Função para exportar a lista de tamanhos, Precisa pegar cada item transformar num mapa e retornar uma lista deste mapa
  List<Map<String, dynamic>> exportSizeList() {
    // toMap criado lá no ItemSize para retornar um mapa para cada tamanho
    return sizes!.map((size) => size.toMap()).toList();
  }

  // Criando função para salvar os dados do produto no firebase
  Future<void> save() async {
    // Carregamento
    loading = true;
    // Map padrão do firebase para salvar dados e enviar ao firebase
    final Map<String, dynamic> data = {
      'name': name,
      'cid': categoryId,
      'description': description,
      // Exportar a lista de tamanhos
      'sizes': exportSizeList(),
      'deleted': deleted,
    };

    // Verificar se o prd já existe ou se está criando
    if (id == null) {
      // Criando
      final doc = await firestore.collection('products').add(data);
      // Obtendo o ID do produto que está sendo criado
      id = doc.id;
    } else {
      // Atualizando, pegando a referência (Criada ali em cima) do prd e atualizando os dados
      await firestoreRef.update(data);
    }

    // Declarando o upDate para enviar ao storage e reotnar uma string
    final List<String> updateImages = [];

    // Salvando as imagens
    // Percorrer cada elemento da newImages e verificar se está no images
    for (final newImages in newImages!) {
      // verificar se o image contém o newImage
      if (images!.contains(newImages)) {
        // Se tiver, add no updateImages as String para garantir que é uma string
        updateImages.add(newImages as String);
      } else {
        // IMAGES [URL1, URL2, URL3]
        // NEWIMAGES [URL2, URL3, FILE1, FILE2]
        // UPDATED [URL2, URL3, FURL1, FURL2]

        // MANDA FILE1 PRO STORAGE -> RETORNA FURL1
        // MANDA FILE2 PRO STORAGE -> RETORNA FURL2
        // EXCLUI IMAGEM URL1 DO STORAGE

        // Se não tiver, salvar no storage e pegar o link do file e add no updateImages
        // uuid gerar nomes únicos para os arquivos no firestore, especificando q é um File
        final UploadTask task = storageRef.child(const Uuid().v1()).putFile(newImages as File);
        // Após o comando acima, precisamos excutar a task para subir no storage a imagem
        final TaskSnapshot snapshot = await task.whenComplete(() {});
        // Obter URL para imagem
        final String url = await snapshot.ref.getDownloadURL();
        // De fato atualizando as imagens add a url na lista de imagens
        updateImages.add(url);
      }
    }

    // Remover as imagens lixo do storage as que não estão sendo usadas
    for (final image in images!) {
      // Passar pelas novas imagens e Se não contém a imagem ... remover do storage - image.contains('firebase') inerindo a verificação para o firebase evitando exceções no IOS
      if (!newImages!.contains(image) && image.contains('firebase')) {
        // Tratando as exceções para quando não achar imagem para remover
        try {
          // Obter a referencia para a imagem lá do storage
          final ref = storage.refFromURL(image);
          // Excluir do storage
          await ref.delete();
        } catch (e) {
          Future.error('Falha ao deletar $e');
        }
      }
    }

    // Salvar a lista de url no images
    await firestoreRef.update({'images': updateImages});
    // Copiando o updateImages para o images
    images = updateImages;
    // Parando o carregamento
    loading = false;
  }

  // deletando o produto setando o campo deleted no firebase como true
  void delete() {
    firestoreRef.update({'deleted': true});
  }

  // Criando um clone do produto para caso fizer alterações e voltar a tela, essas serão descartadas e não vai alterar o prd original
  Product clone() {
    return Product(
      id: id,
      name: name,
      categoryId: categoryId,
      description: description,
      // Clonando/Duplicando as imagens
      images: List.from(images!),
      // Clonando os tamanhos, pegando cada um dos tamanhos da lista e clonando e tranformando numa lista
      sizes: sizes?.map((size) => size.clone()).toList(),
      deleted: deleted,
    );
  }

  // DIALOG PARA ABRIR IMG DO PRD do corrossel
  void showImageDialog(BuildContext context, List<String> imageUrls) {
    // usado para controlar a página atual do carrossel usado com dots
    final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

    // Controller para dots do carousel a troca de img
    final CarouselSliderController carouselController = CarouselSliderController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: <Widget>[
              // imagens
              SizedBox(
                height: 400,
                width: 400,
                child: CarouselSlider(
                  carouselController: carouselController,
                  items: imageUrls.map((url) {
                    return Image.network(url);
                  }).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: true,
                    aspectRatio: 1.0,
                    onPageChanged: (index, reason) {
                      currentPageNotifier.value = index;
                    },
                  ),
                ),
              ),

              // btn fechar
              Positioned(
                top: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.close,
                    size: 25,
                  ),
                ),
              ),

              // dots indicator
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: ValueListenableBuilder<int>(
                  valueListenable: currentPageNotifier,
                  builder: (_, currentPage, __) {
                    return DotsIndicator(
                      dotsCount: images?.length ?? 0,
                      position: currentPage,
                      decorator: DotsDecorator(
                        size: const Size.square(9.0),
                        activeSize: const Size(18.0, 9.0),
                        activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      // Tocar nos pontos e rolar a imagem
                      onTap: (page) {
                        carouselController.animateToPage(page.toInt());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, images: $images, sizes: $sizes, categoryId: $categoryId}';
  }
}
