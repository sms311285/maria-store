// objeto do endereço da API CepAberto
class CepAbertoAddress {
  // variaveis
  final double altitude;
  final String cep;
  final double latitude;
  final double longitude;
  final String? logradouro;
  final String? bairro;
  final Cidade cidade;
  final Estado estado;

  // metodo que pega o mapa e transforma em todos os dados da cidade - construtor para pegar os dados da API e criar o CepAbertoAddress - String, dynamic dados que ele retorna
  CepAbertoAddress.fromMap(Map<String, dynamic> map)
      // : outra maneira de criar construtor qdo chama o construtor ele já coloca todos dados nos campos
      : altitude = map['altitude'] as double,
        cep = map['cep'] as String,
        latitude = double.tryParse(map['latitude'] as String) ?? 0.0,
        longitude = double.tryParse(map['longitude'] as String) ?? 0.0,
        logradouro = map['logradouro'] as String?,
        bairro = map['bairro'] as String?,
        // especificando o map da cidade e estado
        cidade = Cidade.fromMap(map['cidade'] as Map<String, dynamic>),
        estado = Estado.fromMap(map['estado'] as Map<String, dynamic>);

  // printando o construtor
  @override
  String toString() {
    return 'CepAbertoAddress{altitude: $altitude, cep: $cep, latitude: $latitude, longitude: $longitude, logradouro: $logradouro, bairro: $bairro, cidade: $cidade, estado: $estado}';
  }
}

// classe cidade, map da cidade
class Cidade {
  final int? ddd;
  final String ibge;
  final String nome;

  // declarando o construtor
  Cidade.fromMap(Map<String, dynamic> map)
      : ddd = map['ddd'] as int?,
        ibge = map['ibge'] as String,
        nome = map['nome'] as String;

  @override
  String toString() {
    return 'Cidade{ddd: $ddd, ibge: $ibge, nome: $nome}';
  }
}

// classe estado map do estado
class Estado {
  final String sigla;

  // declarando o construtor
  Estado.fromMap(Map<String, dynamic> map) : sigla = map['sigla'] as String;

  @override
  String toString() {
    return 'Estado{sigla: $sigla}';
  }
}
