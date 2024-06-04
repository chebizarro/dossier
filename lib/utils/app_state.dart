import 'package:flutter/material.dart';
import '../models/node_type.dart';
import '../models/edge_type.dart';

class AppState extends InheritedWidget {
  final NodeType? selectedNodeType;
  final EdgeType? selectedEdgeType;
  final Function(NodeType?) onNodeTypeSelected;
  final Function(EdgeType) onEdgeTypeSelected;

  AppState({
    Key? key,
    required Widget child,
    this.selectedNodeType,
    this.selectedEdgeType,
    required this.onNodeTypeSelected,
    required this.onEdgeTypeSelected,
  }) : super(key: key, child: child);

  static AppState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>();
  }

  @override
  bool updateShouldNotify(AppState oldWidget) {
    return selectedNodeType != oldWidget.selectedNodeType ||
        selectedEdgeType != oldWidget.selectedEdgeType;
  }
}
