import 'package:flutter/material.dart';
import '../../packages/dossier_api/lib/src/models/graph.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../utils/undo_stack.dart';
import '../components/node_property_dialog.dart';

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
    showDialog(
      context: context,
      builder: (context) => NodePropertyDialog(
        node: node,
        onSaveNode: (updatedNode) {
          onComplete();
        },
        onUndoAction: () {
          undoStack.push(EditNodePropertyAction(node, 'label', node.label, node.label));
          undoStack.push(EditNodePropertyAction(node, 'example_property', node.properties['example_property'], node.properties['example_property']));
        },
        undoStack: undoStack,
      ),
    ).then((_) => onComplete());
  }

  void handleEdgeDoubleTap(Edge edge, BuildContext context, VoidCallback onComplete) {
    showDialog(
      context: context,
      builder: (context) => NodePropertyDialog(
        edge: edge,
        onSaveEdge: (updatedEdge) {
          onComplete();
        },
        onUndoAction: () {
          undoStack.push(EditEdgePropertyAction(edge, 'label', edge.label, edge.label));
        },
        undoStack: undoStack,
      ),
    ).then((_) => onComplete());
  }
}
