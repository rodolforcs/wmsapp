import 'package:intl/intl.dart';

// ============================================================================
// NÚMERO UTILS - Formatação centralizada de números
// ============================================================================

class FormatNumeroUtils {
  // Previne instanciação
  FormatNumeroUtils._();

  /// Número padrão de casas decimais para quantidades
  static const int quantidadeDecimaisPadrao = 4;

  /// Formata double para string brasileira com casas decimais customizáveis
  ///
  /// Exemplos:
  /// ```dart
  /// formatarQuantidade(5.0)        // "5,0000" (padrão 4 casas)
  /// formatarQuantidade(5.0, 2)     // "5,00"
  /// formatarQuantidade(5.123, 6)   // "5,123000"
  /// ```
  static String formatarQuantidade(
    double valor, [
    int decimais = quantidadeDecimaisPadrao,
  ]) {
    final formato = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: decimais,
    );
    return formato.format(valor).trim();
  }

  /// Formata double ou retorna vazio se zero
  static String formatarQuantidadeOrEmpty(
    double valor, [
    int decimais = quantidadeDecimaisPadrao,
  ]) {
    return valor > 0 ? formatarQuantidade(valor, decimais) : '';
  }

  /// Converte string brasileira para double (ex: "5,0000" → 5.0)
  static double? parseQuantidade(String texto) {
    if (texto.isEmpty) return 0.0;

    // Normaliza: remove separador de milhar e troca vírgula por ponto
    final normalizado = texto
        .replaceAll('.', '') // Remove pontos (separador de milhar)
        .replaceAll(',', '.'); // Troca vírgula por ponto (decimal)

    return double.tryParse(normalizado);
  }

  /// Retorna regex para validar entrada com N casas decimais
  ///
  /// Exemplos:
  /// ```dart
  /// getQuantidadeRegex(2)  // RegExp(r'^\d*,?\d{0,2}')
  /// getQuantidadeRegex(4)  // RegExp(r'^\d*,?\d{0,4}')
  /// ```
  static RegExp getQuantidadeRegex([int decimais = quantidadeDecimaisPadrao]) {
    return RegExp(r'^\d*,?\d{0,' + decimais.toString() + r'}');
  }

  /// Retorna hint para N casas decimais
  ///
  /// Exemplos:
  /// ```dart
  /// getQuantidadeHint(2)  // "0,00"
  /// getQuantidadeHint(4)  // "0,0000"
  /// ```
  static String getQuantidadeHint([int decimais = quantidadeDecimaisPadrao]) {
    return '0,${'0' * decimais}';
  }

  /// Regex padrão para quantidade (4 casas decimais)
  static final RegExp quantidadeRegex = getQuantidadeRegex();

  /// Hint padrão para campos de quantidade
  static const String quantidadeHint = '0,0000';

  /// Largura padrão para células de quantidade
  static const double quantidadeCellWidth = 120.0;
}

// ============================================================================
// EXTENSIONS - Atalhos para facilitar uso
// ============================================================================

extension DoubleQuantidadeExtension on double {
  /// Formata como quantidade brasileira
  ///
  /// Exemplos:
  /// ```dart
  /// 5.0.toQuantidade()     // "5,0000"
  /// 5.0.toQuantidade(2)    // "5,00"
  /// ```
  String toQuantidade([
    int decimais = FormatNumeroUtils.quantidadeDecimaisPadrao,
  ]) {
    return FormatNumeroUtils.formatarQuantidade(this, decimais);
  }
}

extension StringQuantidadeExtension on String {
  /// Parse de string brasileira para double
  ///
  /// Exemplo:
  /// ```dart
  /// "5,0000".toQuantidadeDouble()  // 5.0
  /// ```
  double? toQuantidadeDouble() {
    return FormatNumeroUtils.parseQuantidade(this);
  }
}
