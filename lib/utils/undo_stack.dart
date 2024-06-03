import 'package:flutter/material.dart'; // Ensure Offset is imported from flutter/material.dart
import '../models/graph.dart';
import '../models/node.dart';
import '../models/edge.dart';

abstract class UndoableAction {
  void undo();
  void redo();
}

class UndoStack {
  final List<UndoableAction> _actions = [];
  int _index = -1;

  bool get canUndo => _index >= 0;
  bool get canRedo => _index < _actions.length - 1;

  void push(UndoableAction action) {
    if (_index < _actions.length - 1) {
      _actions.removeRange(_index + 1, _actions.length);
    }
    _actions.add(action);
    _index++;
  }

  void undo() {
    if (canUndo) {
      _actions[_index].undo();
      _index--;
    }
  }

  void redo() {
    if (canRedo) {
      _index++;
      _actions[_index].redo();
    }
  }
}

class AddNodeAction implements UndoableAction {
  final Graph graph;
  final Node node;

  AddNodeAction(this.graph, this.node);

  @override
  void undo() {
    graph.removeNode(node);
  }

  @override
  void redo() {
    graph.addNode(node);
  }
}

class RemoveNodeAction implements UndoableAction {
  final Graph graph;
  final Node node;

  RemoveNodeAction(this.graph, this.node);

  @override
  void undo() {
    graph.addNode(node);
  }

  @override
  void redo() {
    graph.removeNode(node);
  }
}

class AddEdgeAction implements UndoableAction {
  final Graph graph;
  final Edge edge;

  AddEdgeAction(this.graph, this.edge);

  @override
  void undo() {
    graph.removeEdge(edge);
  }

  @override
  void redo() {
    graph.addEdge(edge);
  }
}

class RemoveEdgeAction implements UndoableAction {
  final Graph graph;
  final Edge edge;

  RemoveEdgeAction(this.graph, this.edge);

  @override
  void undo() {
    graph.addEdge(edge);
  }

  @override
  void redo() {
    graph.removeEdge(edge);
  }
}

class MoveNodeAction implements UndoableAction {
  final Node node;
  final Offset oldPosition;
  final Offset newPosition;

  MoveNodeAction(this.node, this.oldPosition, this.newPosition);

  @override
  void undo() {
    node.x = oldPosition.dx;
    node.y = oldPosition.dy;
  }

  @override
  void redo() {
    node.x = newPosition.dx;
    node.y = newPosition.dy;
  }
}
