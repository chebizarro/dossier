import 'package:flutter/material.dart';

class EdgeType {
  final String type;
  final String label;
  final IconData icon;
  final Map<String, dynamic> properties;

  EdgeType({
    required this.type,
    required this.label,
    required this.icon,
    required this.properties,
  });

  factory EdgeType.fromJson(Map<String, dynamic> json) {
    return EdgeType(
      type: json['type'],
      label: json['label'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'icon': icon.codePoint,
      'properties': properties,
    };
  }
}
