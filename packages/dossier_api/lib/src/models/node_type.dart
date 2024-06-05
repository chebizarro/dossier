import 'package:flutter/material.dart';

class NodeType {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> properties;

  NodeType({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.properties,
  });

  factory NodeType.fromJson(Map<String, dynamic> json) {
    return NodeType(
      type: json['type'],
      label: json['label'],
      icon: IconData(int.parse(json['icon'], radix: 16),
          fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'label': label,
      'icon': icon.codePoint.toRadixString(16),
      'color': color.value,
      'properties': properties,
    };
  }
}
