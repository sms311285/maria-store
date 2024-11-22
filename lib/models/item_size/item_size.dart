// Classe modelo que corresponde aos tamanhos
class ItemSize {
  // Antes Construtor vazio utilizado no SizesForm para add um novo tamanho
  // Agora passando o nome, preco e estoque para clonar os tamanhos
  ItemSize({
    this.name,
    this.price,
    this.stock,
    this.purchasePrice,
  });

  // Sempre converte os dados do firebase em objeto no construtor para ficar mais prático recuperar os dados
  // Construtor fromMap para obter os dados do tamanho
  ItemSize.fromMap(Map<String, dynamic> map) {
    name = map['name'] as String;
    price = map['price'] as num;
    stock = map['stock'] as int;
    purchasePrice = map['purchasePrice'] as num;
  }
  // Variaveis
  String? name;
  num? price;
  num? purchasePrice;
  int? stock;

  // Sempre que tem um obj ItemSize Perguntar sempre se o prd tem estoque
  bool get hasStock => stock! > 0;

  // Clonando os tamanhos para caso descarte as alterações na edição do produto
  ItemSize clone() {
    return ItemSize(
      name: name,
      price: price,
      stock: stock,
      purchasePrice: purchasePrice,
    );
  }

  // Função para retornar um mapa e usar no Product para salvar os dados
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'purchasePrice': purchasePrice,
    };
  }

  // Gerando um toString gera um metodo que retorna um ItemSize
  @override
  String toString() {
    return 'ItemSize{name: $name, price: $price, stock: $stock, purchasePrice: $purchasePrice}';
  }
}
