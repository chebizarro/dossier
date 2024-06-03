import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/edge.dart';

class NodePropertyDialog extends StatefulWidget {
  final Node? node;
  final Edge? edge;
  final ValueChanged<Node>? onSaveNode;
  final ValueChanged<Edge>? onSaveEdge;
  final VoidCallback onUndoAction;

  NodePropertyDialog({
    this.node,
    this.edge,
    this.onSaveNode,
    this.onSaveEdge,
    required this.onUndoAction,
  });

  @override
  _NodePropertyDialogState createState() => _NodePropertyDialogState();
}

class _NodePropertyDialogState extends State<NodePropertyDialog> {
  late TextEditingController _labelController;
  late TextEditingController _propertyController;
  late TextEditingController _edgeLabelController;

  @override
  void initState() {
    super.initState();
    if (widget.node != null) {
      _labelController = TextEditingController(text: widget.node!.label);
      _propertyController = TextEditingController(text: widget.node!.properties['example_property'] ?? '');
    }
    if (widget.edge != null) {
      _edgeLabelController = TextEditingController(text: widget.edge!.label);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _propertyController.dispose();
    _edgeLabelController.dispose();
    super.dispose();
  }

  void _saveNode() {
    widget.onUndoAction();
    setState(() {
      widget.node!.label = _labelController.text;
      widget.node!.properties['example_property'] = _propertyController.text;
    });
    widget.onSaveNode!(widget.node!);
    Navigator.of(context).pop();
  }

  void _saveEdge() {
    widget.onUndoAction();
    setState(() {
      widget.edge!.label = _edgeLabelController.text;
    });
    widget.onSaveEdge!(widget.edge!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.node != null ? 'Edit Node Properties' : 'Edit Edge Properties'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.node != null) ...[
            TextField(
              controller: _labelController,
              decoration: InputDecoration(labelText: 'Label'),
            ),
            TextField(
              controller: _propertyController,
              decoration: InputDecoration(labelText: 'Example Property'),
            ),
          ],
          if (widget.edge != null) ...[
            TextField(
              controller: _edgeLabelController,
              decoration: InputDecoration(labelText: 'Edge Label'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: widget.node != null ? _saveNode : _saveEdge,
          child: Text('Save'),
        ),
      ],
    );
  }
}
