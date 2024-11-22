import 'dart:io';
import 'package:dio/dio.dart';
import 'package:maria_store/models/address/cepaberto_address.dart';

// token do cepAberto - https://www.cepaberto.com/api_key
const token = '2dac0870372af96f89d22117a4eadac1';

class CepAbertoService {
  // função para buscar o CEP no CepAberto, recebendo o cep digitado, especificando que vai retornar um CepAbertoAddress
  Future<CepAbertoAddress?> getAddressFromCep(String cep) async {
    // pegar o cep e eliminar pontos e traços substituindo pontos e traços por vazios
    final cleanCep = cep.replaceAll('.', '').replaceAll('-', '');

    // endpoint da API passando o cep limpo tratado os espaços
    final endpoint = "https://www.cepaberto.com/api/v3/cep?cep=$cleanCep";

    // declarando um novo Dio - package usado para fazer requisições
    final Dio dio = Dio();

    // criando o header da requisição e passando o token - configurando o token do CepAberto para passar o meu token
    dio.options.headers[HttpHeaders.authorizationHeader] = 'Token token=$token';

    try {
      // get passando o endpoint e retornando um map com os dados da requisição
      final response = await dio.get<Map<String, dynamic>>(endpoint);

      // verificando se o response for vazio, retorna erro
      if (response.data?.isEmpty ?? true) {
        return Future.error('CEP Inválido');
      }
      // dados do CEP no CepAberto criado a classe CepAbertoAddress para obter o objeto
      final CepAbertoAddress address = CepAbertoAddress.fromMap(response.data!);

      // retornando o endereço
      return address;

      // especificando o erro
    } on DioException catch (e) {
      return Future.error('Erro ao buscar CEP: $e');
    }
  }
}
