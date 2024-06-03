import 'package:flutter/material.dart';
import '../models/graph.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../utils/undo_stack.dart';

class NodeEdgeHandler {
  Graph graph;
  final UndoStack undoStack;
  Node? edgeStartNode;

  NodeEdgeHandler({required this.graph, required this.undoStack});

  void addNode(Node node) {
    graph.addNode(node);
    undoStack.push(AddNodeAction(graph, node));
  }

  void removeNode(Node node) {
    graph.removeNode(node);
    undoStack.push(RemoveNodeAction(graph, node));
  }

  void addEdge(Edge edge) {
    graph.addEdge(edge);
    undoStack.push(AddEdgeAction(graph, edge));
  }

  void removeEdge(Edge edge) {
    graph.removeEdge(edge);
    undoStack.push(RemoveEdgeAction(graph, edge));
  }

  void moveNode(Node node, Offset oldPosition, Offset newPosition) {
    node.x = newPosition.dx;
    node.y = newPosition.dy;
    undoStack.push(MoveNodeAction(node, oldPosition, newPosition));
  }

  void handleNodeDoubleTap(Node node, BuildContext context, VoidCallback onComplete) {
    // Logic to handle double tap for editing properties
  }

  void handleEdgeDoubleTap(Edge edge, BuildContext context, VoidCallback onComplete) {
    // Logic to handle double tap for editing properties
  }

  void handleNodeTap(Node node, VoidCallback onComplete) {
    // Logic to handle node tap
  }
}
