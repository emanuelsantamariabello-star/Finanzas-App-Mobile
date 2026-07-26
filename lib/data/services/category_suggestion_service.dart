import 'package:finanzas_app_mobile/data/models/category_suggestion_model.dart';

class CategorySuggestionService {
  static CategorySuggestionModel? suggestExpenseCategory(String note) {
    return _suggest(note, _expenseRules);
  }

  static CategorySuggestionModel? suggestIncomeCategory(String note) {
    return _suggest(note, _incomeRules);
  }

  static CategorySuggestionModel? _suggest(
    String note,
    List<CategorySuggestionModel> rules,
  ) {
    final normalized = _normalize(note);
    if (normalized.isEmpty) return null;

    CategorySuggestionModel? bestMatch;
    var bestScore = 0;

    for (final rule in rules) {
      final score = rule.keywords
          .where((keyword) => normalized.contains(_normalize(keyword)))
          .length;

      if (score > bestScore) {
        bestScore = score;
        bestMatch = rule;
      }
    }

    if (bestMatch == null || bestScore == 0) return null;

    final confidence = bestScore / bestMatch.keywords.length;
    return CategorySuggestionModel(
      label: bestMatch.label,
      confidence: confidence.clamp(0.0, 1.0),
      keywords: bestMatch.keywords,
    );
  }

  static String _normalize(String value) {
    final lower = value.toLowerCase().trim();

    return lower
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  static const List<CategorySuggestionModel> _expenseRules = [
    CategorySuggestionModel(
      label: 'Alimentación',
      confidence: 0,
      keywords: [
        'mercado',
        'supermercado',
        'comida',
        'restaurante',
        'almuerzo',
      ],
    ),
    CategorySuggestionModel(
      label: 'Transporte',
      confidence: 0,
      keywords: ['gasolina', 'uber', 'taxi', 'bus', 'transporte'],
    ),
    CategorySuggestionModel(
      label: 'Hogar',
      confidence: 0,
      keywords: ['arriendo', 'alquiler', 'casa', 'hogar', 'mantenimiento'],
    ),
    CategorySuggestionModel(
      label: 'Servicios',
      confidence: 0,
      keywords: ['luz', 'agua', 'internet', 'telefono', 'servicio'],
    ),
    CategorySuggestionModel(
      label: 'Salud',
      confidence: 0,
      keywords: ['medico', 'medicina', 'salud', 'farmacia', 'clinica'],
    ),
    CategorySuggestionModel(
      label: 'Educación',
      confidence: 0,
      keywords: ['curso', 'universidad', 'colegio', 'matricula', 'educacion'],
    ),
    CategorySuggestionModel(
      label: 'Entretenimiento',
      confidence: 0,
      keywords: ['cine', 'netflix', 'spotify', 'juego', 'salida'],
    ),
  ];

  static const List<CategorySuggestionModel> _incomeRules = [
    CategorySuggestionModel(
      label: 'Salario',
      confidence: 0,
      keywords: ['salario', 'nomina', 'sueldo', 'pago empresa'],
    ),
    CategorySuggestionModel(
      label: 'Freelance',
      confidence: 0,
      keywords: ['cliente', 'proyecto', 'freelance', 'servicio'],
    ),
    CategorySuggestionModel(
      label: 'Ventas',
      confidence: 0,
      keywords: ['venta', 'producto', 'comision', 'pedido'],
    ),
    CategorySuggestionModel(
      label: 'Inversión',
      confidence: 0,
      keywords: ['interes', 'rendimiento', 'inversion', 'dividendo'],
    ),
    CategorySuggestionModel(
      label: 'Reembolso',
      confidence: 0,
      keywords: ['reembolso', 'devolucion', 'ajuste', 'saldo a favor'],
    ),
    CategorySuggestionModel(
      label: 'Regalo',
      confidence: 0,
      keywords: ['regalo', 'bono', 'premio', 'obsequio'],
    ),
  ];
}
