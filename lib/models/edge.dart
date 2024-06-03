class Edge {
  String id;
  String fromNodeId;
  String toNodeId;
  String label;
  Map<String, dynamic> properties;

  Edge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.label = '',
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};

  Edge copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    String? label,
    Map<String, dynamic>? properties,
  }) {
    return Edge(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      label: label ?? this.label,
      properties: properties ?? this.properties,
    );
  }

  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      id: json['id'],
      fromNodeId: json['fromNodeId'],
      toNodeId: json['toNodeId'],
      label: json['label'],
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'label': label,
      'properties': properties,
    };
  }
}
