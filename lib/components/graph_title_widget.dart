import 'package:flutter/material.dart';

class GraphTitleWidget extends StatefulWidget {
  final String title;
  final ValueChanged<String> onTitleChanged;

  GraphTitleWidget({required this.title, required this.onTitleChanged});

  @override
  _GraphTitleWidgetState createState() => _GraphTitleWidgetState();
}

class _GraphTitleWidgetState extends State<GraphTitleWidget> {
  bool _isEditingTitle = false;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
  }

  void _editTitle() {
    setState(() {
      _isEditingTitle = true;
    });
  }

  void _saveTitle() {
    setState(() {
      widget.onTitleChanged(_titleController.text);
      _isEditingTitle = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isEditingTitle
        ? TextField(
            controller: _titleController,
            onSubmitted: (_) => _saveTitle(),
            autofocus: true,
          )
        : GestureDetector(
            onTap: _editTitle,
            child: Text(widget.title),
          );
  }
}
