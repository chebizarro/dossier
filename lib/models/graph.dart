import 'node_type.dart';
import 'edge_type.dart';

part 'node.dart';
part 'edge.dart';


class Graph {
  String title;
  String? filePath;
  List<Node> nodes;
  List<Edge> edges;

  Graph({required this.title, this.filePath, List<Node>? nodes, List<Edge>? edges})
      : nodes = nodes ?? [],
        edges = edges ?? [];

  factory Graph.fromJson(Map<String, dynamic> json) {
    return Graph(
      title: json['title'],
      nodes: (json['nodes'] as List)
          .map((nodeJson) => Node.fromJson(nodeJson))
          .toList(),
      edges: (json['edges'] as List)
          .map((edgeJson) => Edge.fromJson(edgeJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'edges': edges.map((edge) => edge.toJson()).toList(),
    };
  }

  void addNode(Node node) {
    nodes.add(node);
  }

  void removeNode(Node node) {
    nodes.remove(node);
    edges.removeWhere((edge) => edge.fromNodeId == node.id || edge.toNodeId == node.id);
  }

  void addEdge(Edge edge) {
    edges.add(edge);
  }

  void removeEdge(Edge edge) {
    edges.remove(edge);
  }
}
