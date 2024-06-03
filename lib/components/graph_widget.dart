import 'package:flutter/material.dart';
import 'node_widget.dart';
import 'edge_widget.dart';
import '../models/graph.dart';
import '../models/node.dart';

class GraphWidget extends StatefulWidget {
  final Graph graph;
  final Function(Node, bool) onNodeTap;
  final Function(Node, Offset) onNodeDragStart;
  final Function(Offset) onNodeDragUpdate;
  final Function() onNodeDragEnd;
  final Set<Node> selectedNodes;
  final bool isShiftPressed;

  GraphWidget({
    required this.graph,
    required this.onNodeTap,
    required this.onNodeDragStart,
    required this.onNodeDragUpdate,
    required this.onNodeDragEnd,
    required this.selectedNodes,
    required this.isShiftPressed,
  });

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  Offset? _selectionStart;
  Offset? _selectionEnd;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _selectionStart = details.localPosition;
      _selectionEnd = _selectionStart;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _selectionEnd = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectionStart != null && _selectionEnd != null) {
      final selectionRect = Rect.fromPoints(_selectionStart!, _selectionEnd!);

      setState(() {
        if (!widget.isShiftPressed) {
          widget.selectedNodes.clear();
        }
        for (var node in widget.graph.nodes) {
          final nodeRect = Rect.fromCenter(
            center: Offset(node.x, node.y),
            width: 50,
            height: 50,
          );
          if (selectionRect.overlaps(nodeRect)) {
            widget.selectedNodes.add(node);
          }
        }
        _selectionStart = null;
        _selectionEnd = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          ...widget.graph.nodes.map((node) => Positioned(
                left: node.x - 25, // Adjusting for half the width of the node
                top: node.y - 25, // Adjusting for half the height of the node
                child: GestureDetector(
                  onTap: () => widget.onNodeTap(node, widget.isShiftPressed),
                  onPanStart: (details) => widget.onNodeDragStart(node, details.localPosition),
                  onPanUpdate: (details) => widget.onNodeDragUpdate(details.delta),
                  onPanEnd: (details) => widget.onNodeDragEnd(),
                  child: NodeWidget(
                    node: node,
                    isSelected: widget.selectedNodes.contains(node),
                  ),
                ),
              )),
          if (_selectionStart != null && _selectionEnd != null)
            Positioned.fromRect(
              rect: Rect.fromPoints(_selectionStart!, _selectionEnd!),
              child: Container(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }
}
