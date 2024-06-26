import 'package:flutter/material.dart';
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
  final List<VoidCallback> _listeners = [];

  bool get canUndo => _index >= 0;
  bool get canRedo => _index < _actions.length - 1;

  void push(UndoableAction action) {
    if (_index < _actions.length - 1) {
      _actions.removeRange(_index + 1, _actions.length);
    }
    _actions.add(action);
    _index++;
    _notifyListeners();
  }

  void undo() {
    if (canUndo) {
      _actions[_index].undo();
      _index--;
      _notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _index++;
      _actions[_index].redo();
      _notifyListeners();
    }
  }

  void clear() {
    _actions.clear();
    _index = -1;
    _notifyListeners();
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
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

class EditNodePropertyAction implements UndoableAction {
  final Node node;
  final String propertyName;
  final dynamic oldValue;
  final dynamic newValue;

  EditNodePropertyAction(this.node, this.propertyName, this.oldValue, this.newValue);

  @override
  void undo() {
    node.properties[propertyName] = oldValue;
  }

  @override
  void redo() {
    node.properties[propertyName] = newValue;
  }
}

class EditEdgePropertyAction implements UndoableAction {
  final Edge edge;
  final String propertyName;
  final dynamic oldValue;
  final dynamic newValue;

  EditEdgePropertyAction(this.edge, this.propertyName, this.oldValue, this.newValue);

  @override
  void undo() {
    //edge.properties[propertyName] = oldValue;
  }

  @override
  void redo() {
    //edge.properties[propertyName] = newValue;
  }
}
