import 'node.dart';
import 'node_type.dart';

class Graph {
  String title;
  List<Node> nodes;

  Graph({required this.title, List<Node>? nodes})
      : nodes = nodes ?? [];

  factory Graph.fromJson(Map<String, dynamic> json, List<NodeType> nodeTypes) {
    Map<String, NodeType> nodeTypeMap = {for (var type in nodeTypes) type.type: type};
    return Graph(
      title: json['title'],
      nodes: (json['nodes'] as List)
          .map((nodeJson) => Node.fromJson(nodeJson, nodeTypeMap[nodeJson['nodeType']]!))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'nodes': nodes.map((node) => node.toJson()).toList(),
    };
  }

  void addNode(Node node) {
    nodes.add(node);
  }

  void removeNode(Node node) {
    nodes.remove(node);
  }
}
