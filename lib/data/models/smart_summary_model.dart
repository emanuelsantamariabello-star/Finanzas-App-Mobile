import 'package:flutter/material.dart';

class SmartSummaryModel {
  const SmartSummaryModel({
    required this.title,
    required this.message,
    required this.highlight,
    required this.icon,
    required this.color,
    required this.chips,
  });

  final String title;
  final String message;
  final String highlight;
  final IconData icon;
  final Color color;
  final List<String> chips;
}
