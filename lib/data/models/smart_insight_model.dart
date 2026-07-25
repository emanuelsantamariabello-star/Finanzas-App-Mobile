import 'package:flutter/material.dart';

class SmartInsightModel {
  const SmartInsightModel({
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
