import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:maria_store/models/address/address.dart';
import 'package:maria_store/helpers/extensions.dart';

//PARA PERSONALIZAR A CADA DIA DA SEMANA VER AULA 142 minuto 4
// enumerador dos status
enum StoreStatus { closed, open, closing }

class StoresModel {
  // campos da loja
  String? id;
  String? name;
  String? image;
  String? phone;
  Address? address;
  // declarando o opening map de horários
  Map<String, Map<String, TimeOfDay>?>? opening;
  StoreStatus? status;

  // get para obter o telefone formatado
  String get cleanPhone => phone!.replaceAll(RegExp(r"[^\d]"), "");

  // construtor padrão
  StoresModel({
    this.id,
    this.name,
    this.image,
    this.phone,
    this.address,
    this.opening,
    this.status,
  });

  StoresModel clone() {
    return StoresModel(
      id: id,
      name: name,
      image: image,
      phone: phone,
      address: address,
      opening: opening,
      status: status,
    );
  }

  // construtor para obter os dados da loja do firebase
  StoresModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    name = doc['name'] as String;
    image = doc['image'] as String;
    phone = doc['phone'] as String;
    // pegando o construtor do endereço
    address = Address.fromMap(doc['address'] as Map<String, dynamic>);

    // pegando os horários e convertendo em um stringDynamic
    opening = (doc['opening'] as Map<String, dynamic>).map(
      (key, value) {
        // variavel para intepretar o que é passado no horário
        final timesString = value as String?;

        // verificando se o horário existe e se ele não é vazio
        if (timesString != null && timesString.isNotEmpty) {
          // dando um split para formatar o horário conforme está no firebase com dois pontos e traço
          // Quando for criar o cadastro de loja talvez tenha q ter o campo de hora e o campo de minuto para depois juntar tudo aula 139 Criando obj Loja
          final splitted = timesString.split(RegExp(r"[:-]"));

          // criando o map e retornando o horário abertura e o horário de fechamento
          return MapEntry(key, {
            // separar o horario de abertura com o de fechamento - TimeOfDay nativo do flutter pega o 1, 2, 3 e 4 item
            "from": TimeOfDay(
              hour: int.parse(splitted[0]),
              minute: int.parse(splitted[1]),
            ),
            "to": TimeOfDay(
              hour: int.parse(splitted[2]),
              minute: int.parse(splitted[3]),
            ),
          });
        } else {
          // caso o horário seja vazio, retornar null para o horário
          return MapEntry(key, null);
        }
      },
    );
    // chamando o get para atualizar o status
    updateStatus();
  }

  // criando o get do endereço e formatado
  String get addressText =>
      '${address?.street}, ${address?.number}${address!.complement!.isNotEmpty ? ' - ${address?.complement}' : ''}\n'
      '${address?.district}, ${address?.city}/${address?.state} - ${address?.zipCode}';

  // PARA PERSONALIZAR A CADA DIA DA SEMANA VER AULA 142
  // Formatando o texto de informações dos horarios
  String get openingText {
    return 'Seg-Sex: ${formattedPeriod(opening?['monfri'])}\n'
        'Sab: ${formattedPeriod(opening?['saturday'])}\n'
        'Dom: ${formattedPeriod(opening?['sunday'])}';
  }

  // formatando os períodos recebendo o mapa de periodos e formatar
  String formattedPeriod(Map<String, TimeOfDay>? period) {
    // verificando se é nulo caso não tiver horario em algum dia da semana on sunday e saturday
    if (period == null) return "Fechada";
    // retornando o horário formatado de abertura e o horário de fechamento chamando formatted do extensions em helpers
    return '${period['from']?.formatted()}-${period['to']?.formatted()}';
  }

  // verificações para status da loja
  void updateStatus() {
    // pegando o dia da semana
    final weekDay = DateTime.now().weekday;

    // verificando o horário e atualizando o status da loja dentro de um mapa de 1 a 5 dia da semana 6 e 7 final de semana
    Map<String, TimeOfDay>? period;

    // verificando se o dia da semana estiver entre 1 e 5
    if (weekDay >= 1 && weekDay <= 5) {
      // pegando o horário de abertura e de fechamento
      period = opening?['monfri'];
      // verificando se o dia da semana for 6 ou 7
    } else if (weekDay == 6) {
      // pegando o horário de abertura e de fechamento no sabado
      period = opening?['saturday'];
    } else {
      // pegando o horário de abertura e de fechamento no domiingo
      period = opening?['sunday'];
    }

    // obter o ohorario atual
    final now = TimeOfDay.now();

    // verificando se o horário atual estiver dentro do horário de abertura e de fechamento
    if (period == null) {
      // se o horário estiver fora do horário de abertura e de fechamento
      status = StoreStatus.closed;
      // verificando se o horário de abertura for menor que o horário atual e o horário de fechamento for maior que o horário atual
    } else if (period['from']!.toMinutes() < now.toMinutes() && period['to']!.toMinutes() - 15 > now.toMinutes()) {
      // se o horário estiver dentro do horário de abertura e de fechamento
      status = StoreStatus.open;
      // verificando se o horário de abertura for maior que o horário atual e o horário de fechamento for menor que o horário atual
    } else if (period['from']!.toMinutes() < now.toMinutes() && period['to']!.toMinutes() > now.toMinutes()) {
      // se o horário estiver dentro do horário de abertura e de fechamento
      status = StoreStatus.closing;
    } else {
      // se o horário estiver fora do horário de abertura e de fechamento
      status = StoreStatus.closed;
    }
  }

  // retornando o status da loja pegando o enumerador e transformando para o texto
  String get statusText {
    switch (status) {
      case StoreStatus.closed:
        return 'Fechada';
      case StoreStatus.open:
        return 'Aberta';
      case StoreStatus.closing:
        return 'Fechando';
      default:
        return '';
    }
  }
}
