// Classe para os itens da seção

class SectionItem {
  // Construtor padrao da seção
  SectionItem({
    this.image,
    this.product,
  });
  // Sempre converte os dados do firebase em objeto no construtor para ficar mais prático recuperar os dados
  // Construtor que recebe um map padrão do firebase,
  SectionItem.fromMap(Map<String, dynamic> map) {
    image = map['image'] as String;
    // Buscando id do Prd para vincular na img e abrir o prd
    // product = map['product'] as String;
    product = map['product'];
  }

  // Variaveis
  dynamic image;
  String? product;

  // Clone do item da seção
  SectionItem clone() {
    return SectionItem(
      image: image,
      product: product,
    );
  }

  // toMap criado para retornar um mapa para cada imagem e prod e utilizar na Section
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'product': product,
    };
  }

  // Caso queira printar da o toString
  @override
  String toString() => 'SectionItem(image: $image, product: $product)';
}
