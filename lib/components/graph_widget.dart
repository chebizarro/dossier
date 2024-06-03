import 'package:flutter/material.dart';
import '../models/graph.dart';
import '../models/node.dart';
import 'node_widget.dart';

class GraphWidget extends StatelessWidget {
  final Graph graph;
  final Set<Node> selectedNodes;
  final bool isShiftPressed;
  final void Function(Node, bool) onNodeTap;
  final void Function(Node) onNodeDoubleTap;
  final void Function(Node, Offset) onNodeDragStart;
  final void Function(Offset) onNodeDragUpdate;
  final void Function() onNodeDragEnd;

  GraphWidget({
    required this.graph,
    required this.selectedNodes,
    required this.isShiftPressed,
    required this.onNodeTap,
    required this.onNodeDoubleTap,
    required this.onNodeDragStart,
    required this.onNodeDragUpdate,
    required this.onNodeDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: EdgePainter(graph),
        ),
        ...graph.nodes.map((node) {
          final isSelected = selectedNodes.contains(node);
          return Positioned(
            left: node.x,
            top: node.y,
            child: Draggable<Node>(
              data: node,
              onDragStarted: () => onNodeDragStart(node, Offset(node.x, node.y)),
              onDraggableCanceled: (_, __) => onNodeDragEnd(),
              onDragUpdate: (details) => onNodeDragUpdate(details.delta),
              feedback: Material(
                child: NodeWidget(
                  node: node,
                  isSelected: isSelected,
                  onNodeTap: (node) {},
                  onNodeDoubleTap: (node) {},
                ),
              ),
              child: NodeWidget(
                node: node,
                isSelected: isSelected,
                onNodeTap: (node) => onNodeTap(node, isShiftPressed),
                onNodeDoubleTap: onNodeDoubleTap,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class EdgePainter extends CustomPainter {
  final Graph graph;

  EdgePainter(this.graph);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    for (var edge in graph.edges) {
      final fromNode = graph.nodes.firstWhere((node) => node.id == edge.fromNodeId);
      final toNode = graph.nodes.firstWhere((node) => node.id == edge.toNodeId);

      final fromOffset = Offset(fromNode.x + 24, fromNode.y + 24);
      final toOffset = Offset(toNode.x + 24, toNode.y + 24);

      canvas.drawLine(fromOffset, toOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
