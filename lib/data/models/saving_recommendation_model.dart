import 'package:flutter/material.dart';

class SavingRecommendationModel {
  const SavingRecommendationModel({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
}
