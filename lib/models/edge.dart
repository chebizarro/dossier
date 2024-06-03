class Edge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String label;

  Edge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.label = '',
  });

  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      id: json['id'],
      fromNodeId: json['fromNodeId'],
      toNodeId: json['toNodeId'],
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'label': label,
    };
  }
}
