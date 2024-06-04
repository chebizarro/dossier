import 'package:flutter/material.dart';
import '../models/graph.dart';
import '../models/node_type.dart';
import '../utils/graph_operations.dart';

class GraphActions {
  final Graph graph;
  final List<NodeType> nodeTypes;
  final VoidCallback onClearUndoStack;

  GraphActions({
    required this.graph,
    required this.nodeTypes,
    required this.onClearUndoStack,
  });

  Future<void> saveGraph() async {
    await GraphOperations.saveGraph(graph);
  }

  Future<Graph?> openGraph() async {
    return await GraphOperations.loadGraph();
  }
}
