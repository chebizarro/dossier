import 'package:flutter/material.dart';
import '../models/graph.dart';
import '../models/node_type.dart';
import '../utils/graph_operations.dart';

class GraphActions {
  Graph _graph;
  final List<NodeType> nodeTypes;

  GraphActions({
    required Graph graph,
    required this.nodeTypes,
  }) : _graph = graph;

  Graph get graph => _graph;

  set graph(Graph newGraph) {
    _graph = newGraph;
  }

  Future<void> saveGraph() async {
    final path = await saveGraphToFile(_graph);
    if (path != null) {
      _graph.filePath = path;
    }
  }

  Future<void> openGraph(Function(Graph) onGraphLoaded) async {
    final graph = await openGraphFromFile(nodeTypes);
    if (graph != null) {
      onGraphLoaded(graph);
    }
  }

  void updateTitle(String title) {
    _graph.title = title;
  }
}
