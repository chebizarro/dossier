import 'package:flutter/material.dart';

class EdgeType {
  final String type;
  final String label;
  final IconData icon;

  EdgeType({
    required this.type,
    required this.label,
    required this.icon,
  });

  factory EdgeType.fromJson(Map<String, dynamic> json) {
    return EdgeType(
      type: json['type'],
      label: json['label'],
      icon: IconData(int.parse(json['icon'], radix: 16), fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'icon': icon.codePoint,
    };
  }
}
