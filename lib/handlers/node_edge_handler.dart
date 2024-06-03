import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../models/graph.dart';
import '../components/node_property_dialog.dart';
import '../utils/undo_stack.dart';

class NodeEdgeHandler {
  Graph _graph;
  final UndoStack undoStack;
  Node? edgeStartNode;

  NodeEdgeHandler({
    required Graph graph,
    required this.undoStack,
  }) : _graph = graph;

  Graph get graph => _graph;

  set graph(Graph newGraph) {
    _graph = newGraph;
  }

  void addNode(Node node) {
    _graph.addNode(node);
    undoStack.addAction(
      UndoAction(
        undo: () {
          _graph.removeNode(node);
        },
        redo: () {
          _graph.addNode(node);
        },
      ),
    );
  }

  void addEdge(Edge edge) {
    _graph.addEdge(edge);
    undoStack.addAction(
      UndoAction(
        undo: () {
          _graph.removeEdge(edge);
        },
        redo: () {
          _graph.addEdge(edge);
        },
      ),
    );
  }

  void handleNodeTap(Node node, Function() refresh) {
    if (edgeStartNode == null) {
      edgeStartNode = node;
    } else {
      final newEdge = Edge(
        id: DateTime.now().toString(),
        fromNodeId: edgeStartNode!.id,
        toNodeId: node.id,
      );
      addEdge(newEdge);
      edgeStartNode = null;
      refresh();
    }
  }

  void handleNodeDoubleTap(Node node, BuildContext context, Function() refresh) {
    final originalNode = Node(
      id: node.id,
      label: node.label,
      nodeType: node.nodeType,
      x: node.x,
      y: node.y,
      properties: Map<String, dynamic>.from(node.properties),
    );

    showDialog(
      context: context,
      builder: (context) {
        return NodePropertyDialog(
          node: node,
          onSaveNode: (updatedNode) {
            _graph.nodes = _graph.nodes.map((n) => n.id == updatedNode.id ? updatedNode : n).toList();
            refresh();
          },
          onUndoAction: () {
            undoStack.addAction(
              UndoAction(
                undo: () {
                  _graph.nodes = _graph.nodes.map((n) => n.id == originalNode.id ? originalNode : n).toList();
                  refresh();
                },
                redo: () {
                  _graph.nodes = _graph.nodes.map((n) => n.id == node.id ? node : n).toList();
                  refresh();
                },
              ),
            );
          },
        );
      },
    );
  }

  void handleEdgeDoubleTap(Edge edge, BuildContext context, Function() refresh) {
    final originalEdge = Edge(
      id: edge.id,
      fromNodeId: edge.fromNodeId,
      toNodeId: edge.toNodeId,
      label: edge.label,
    );

    showDialog(
      context: context,
      builder: (context) {
        return NodePropertyDialog(
          edge: edge,
          onSaveEdge: (updatedEdge) {
            _graph.edges = _graph.edges.map((e) => e.id == updatedEdge.id ? updatedEdge : e).toList();
            refresh();
          },
          onUndoAction: () {
            undoStack.addAction(
              UndoAction(
                undo: () {
                  _graph.edges = _graph.edges.map((e) => e.id == originalEdge.id ? originalEdge : e).toList();
                  refresh();
                },
                redo: () {
                  _graph.edges = _graph.edges.map((e) => e.id == edge.id ? edge : e).toList();
                  refresh();
                },
              ),
            );
          },
        );
      },
    );
  }
}
