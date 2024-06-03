import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/node.dart';

class NodeWidget extends StatefulWidget {
  final Node node;
  final bool isSelected;

  NodeWidget({required this.node, required this.isSelected});

  @override
  _NodeWidgetState createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  bool _isEditing = false;
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.node.label;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _onEditingComplete();
    }
  }

  void _onDoubleTap() {
    setState(() {
      _isEditing = true;
      _controller.text = widget.node.label;
    });
    _focusNode.requestFocus();
  }

  void _onEditingComplete() {
    if (_isEditing) {
      setState(() {
        widget.node.label = _controller.text;
        _isEditing = false;
      });
    }
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _onEditingComplete();
        _focusNode.unfocus(); // Explicitly unfocus to avoid potential loops
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50, // Define the width of the node
          height: 50, // Define the height of the node
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: widget.isSelected ? Colors.orange : widget.node.nodeType.color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(widget.node.nodeType.icon, color: Colors.white),
          ),
        ),
        GestureDetector(
          onDoubleTap: _onDoubleTap,
          child: _isEditing
              ? Container(
                  width: 60,
                  child: RawKeyboardListener(
                    focusNode: _focusNode,
                    onKey: _onKey,
                    child: TextField(
                      controller: _controller,
                      onEditingComplete: _onEditingComplete,
                      autofocus: true,
                    ),
                  ),
                )
              : Text(
                  widget.node.label,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}
