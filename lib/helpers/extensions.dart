import 'package:flutter/material.dart';

// extension para o TimeOfDay
extension Extra on TimeOfDay {
  // formatar o timedoay para string formatada hh:mm
  String formatted() {
    // pegando a hora e o minuto e convertendo para string formatada hh:mm
    return '${hour}h${minute.toString().padLeft(2, '0')}';
  }

  // converter o horário em minutos
  int toMinutes() => hour * 60 + minute;
}
