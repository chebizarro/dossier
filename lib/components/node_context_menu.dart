import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/edge.dart';

class NodeContextMenu extends StatelessWidget {
  final Node node;
  final void Function(Node) onEditProperties;
  final void Function(Node) onAddEdge;
  final void Function(Node) onDeleteNode;
  final Edge? edge;
  final void Function(Edge)? onDeleteEdge;
  final void Function(Edge)? onEditEdge;

  NodeContextMenu({
    required this.node,
    required this.onEditProperties,
    required this.onAddEdge,
    required this.onDeleteNode,
    this.edge,
    this.onDeleteEdge,
    this.onEditEdge,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'edit_properties':
            onEditProperties(node);
            break;
          case 'add_edge':
            onAddEdge(node);
            break;
          case 'delete_node':
            onDeleteNode(node);
            break;
          case 'delete_edge':
            if (edge != null && onDeleteEdge != null) {
              onDeleteEdge!(edge!);
            }
            break;
          case 'edit_edge':
            if (edge != null && onEditEdge != null) {
              onEditEdge!(edge!);
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit_properties',
          child: Text('Edit Properties'),
        ),
        PopupMenuItem<String>(
          value: 'add_edge',
          child: Text('Add Edge'),
        ),
        PopupMenuItem<String>(
          value: 'delete_node',
          child: Text('Delete Node'),
        ),
        if (edge != null) ...[
          PopupMenuItem<String>(
            value: 'delete_edge',
            child: Text('Delete Edge'),
          ),
          PopupMenuItem<String>(
            value: 'edit_edge',
            child: Text('Edit Edge'),
          ),
        ],
      ],
    );
  }
}
