import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '../models/node_type.dart';

class NodeTypeSelector extends StatelessWidget {
  final List<NodeType> nodeTypes;
  final ValueChanged<NodeType> onNodeTypeSelected;

  NodeTypeSelector({required this.nodeTypes, required this.onNodeTypeSelected});

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      type: ExpandableFabType.up,
      children: nodeTypes.map((nodeType) {
        return FloatingActionButton(
          mini: true,
          onPressed: () => onNodeTypeSelected(nodeType),
          child: Icon(nodeType.icon),
          backgroundColor: nodeType.color,
          heroTag: nodeType.type,
          tooltip: nodeType.label,
        );
      }).toList(),
    );
  }
}
