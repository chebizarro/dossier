part of 'graph.dart';

class Edge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  String label;
  final EdgeType edgeType;

  Edge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.label = '',
    required this.edgeType,
  });

  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      id: json['id'],
      fromNodeId: json['fromNodeId'],
      toNodeId: json['toNodeId'],
      label: json['label'],
      edgeType: EdgeType.fromJson(json['edgeType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'label': label,
      'edgeType': edgeType.toJson(),
    };
  }
}

