import 'package:flutter/material.dart';
import '../models/node.dart';

class NodePropertyDialog extends StatefulWidget {
  final Node node;
  final ValueChanged<Node> onSave;

  NodePropertyDialog({required this.node, required this.onSave});

  @override
  _NodePropertyDialogState createState() => _NodePropertyDialogState();
}

class _NodePropertyDialogState extends State<NodePropertyDialog> {
  late TextEditingController _labelController;
  late TextEditingController _propertyController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.node.label);
    _propertyController = TextEditingController(text: widget.node.properties['example_property'] ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _propertyController.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      widget.node.label = _labelController.text;
      widget.node.properties['example_property'] = _propertyController.text;
    });
    widget.onSave(widget.node);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Node Properties'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            decoration: InputDecoration(labelText: 'Label'),
          ),
          TextField(
            controller: _propertyController,
            decoration: InputDecoration(labelText: 'Example Property'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _save,
          child: Text('Save'),
        ),
      ],
    );
  }
}
