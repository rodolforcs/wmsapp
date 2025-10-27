import 'package:flutter/material.dart';

enum StatusDocumento {
  pendente,
  emConferencia,
  conferido,
  finalizado,
  desconhecido;

  static StatusDocumento fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pendente':
        return StatusDocumento.pendente;
      case 'em conferência':
        return StatusDocumento.emConferencia;
      case 'conferido':
        return StatusDocumento.conferido;
      case 'finalizado':
        return StatusDocumento.finalizado;
      default:
        return StatusDocumento.desconhecido;
    }
  }

  String get label {
    switch (this) {
      case StatusDocumento.pendente:
        return 'Pendente';
      case StatusDocumento.emConferencia:
        return 'Em conferência';
      case StatusDocumento.conferido:
        return 'Conferido';
      case StatusDocumento.finalizado:
        return 'Finalizado';
      case StatusDocumento.desconhecido:
        return '';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StatusDocumento.pendente:
        return Colors.orange.shade50;
      case StatusDocumento.emConferencia:
        return Colors.blue.shade50;
      case StatusDocumento.conferido:
        return Colors.green.shade50;
      case StatusDocumento.finalizado:
        return Colors.grey.shade200;
      case StatusDocumento.desconhecido:
        return Colors.grey.shade50;
    }
  }

  Color get textColor {
    switch (this) {
      case StatusDocumento.pendente:
        return Colors.orange.shade700;
      case StatusDocumento.emConferencia:
        return Colors.blue.shade700;
      case StatusDocumento.conferido:
        return Colors.green.shade700;
      case StatusDocumento.finalizado:
        return Colors.grey.shade700;
      case StatusDocumento.desconhecido:
        return Colors.grey.shade700;
    }
  }
}
