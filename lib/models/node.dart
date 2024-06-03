import 'node_type.dart';

class Node {
  String id;
  String label;
  NodeType nodeType;
  double x;
  double y;
  Map<String, dynamic> properties;

  Node({
    required this.id,
    required this.label,
    required this.nodeType,
    required this.x,
    required this.y,
    this.properties = const {},
  });

  factory Node.fromJson(Map<String, dynamic> json, NodeType nodeType) {
    return Node(
      id: json['id'],
      label: json['label'],
      nodeType: nodeType,
      x: json['x'],
      y: json['y'],
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'x': x,
      'y': y,
      'properties': properties,
      'nodeType': nodeType.type,
    };
  }
}
