import 'package:finanzas_app_mobile/data/services/category_suggestion_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategorySuggestionService', () {
    test('sugiere alimentación para una compra de supermercado', () {
      final suggestion = CategorySuggestionService.suggestExpenseCategory(
        'Compra semanal en supermercado',
      );

      expect(suggestion?.label, 'Alimentación');
      expect(suggestion?.confidence, greaterThan(0));
    });

    test('normaliza tildes al sugerir una categoría de ingreso', () {
      final suggestion = CategorySuggestionService.suggestIncomeCategory(
        'Pago de nómina',
      );

      expect(suggestion?.label, 'Salario');
    });

    test('no sugiere categoría cuando no reconoce la descripción', () {
      final suggestion = CategorySuggestionService.suggestExpenseCategory(
        'Movimiento sin coincidencias conocidas',
      );

      expect(suggestion, isNull);
    });
  });
}
