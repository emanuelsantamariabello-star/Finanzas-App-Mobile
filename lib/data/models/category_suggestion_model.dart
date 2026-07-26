class CategorySuggestionModel {
  const CategorySuggestionModel({
    required this.label,
    required this.confidence,
    required this.keywords,
  });

  final String label;
  final double confidence;
  final List<String> keywords;
}
