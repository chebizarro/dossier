part of 'graph.dart';

class Node {
  String id;
  String label;
  double x;
  double y;
  NodeType nodeType;
  Map<String, dynamic> properties;

  Node({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.nodeType,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};

  Node copyWith({
    String? id,
    String? label,
    double? x,
    double? y,
    NodeType? nodeType,
    Map<String, dynamic>? properties,
  }) {
    return Node(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      nodeType: nodeType ?? this.nodeType,
      properties: properties ?? this.properties,
    );
  }

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'],
      label: json['label'],
      x: json['x'],
      y: json['y'],
      nodeType: NodeType.fromJson(json['nodeType']),
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'x': x,
      'y': y,
      'nodeType': nodeType.toJson(),
      'properties': properties,
    };
  }
}
