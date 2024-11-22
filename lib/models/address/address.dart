// objeto que nunca será modificado se caso quiser alterar api - definindo padrão de endereço aula 99

class Address {
  // construtor nomeado para utilizar esses dados
  Address({
    this.street,
    this.number,
    this.complement,
    this.district,
    this.zipCode,
    this.city,
    this.state,
    this.lat,
    this.long,
  });

  // variaveis
  String? street;
  String? number;
  String? complement;
  String? district;
  String? zipCode;
  String? city;
  String? state;

  double? lat;
  double? long;

  // construtor de copia que pega todos os dados do endereço, para usar por exemplo em userapp para obter os dados
  Address.fromMap(Map<String, dynamic> map) {
    street = map['street'] as String;
    number = map['number'] as String;
    complement = map['complement'] as String;
    district = map['district'] as String;
    zipCode = map['zipCode'] as String;
    city = map['city'] as String;
    state = map['state'] as String;
    lat = map['lat'] as double;
    long = map['long'] as double;
  }

  // mapa de endereço para retornar um mapa para cada campo e utilizar no userapp por exemplo
  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'number': number,
      'complement': complement,
      'district': district,
      'zipCode': zipCode,
      'city': city,
      'state': state,
      'lat': lat,
      'long': long,
    };
  }
}
