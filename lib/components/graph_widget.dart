import 'package:flutter/material.dart';
import '../models/graph.dart';
import '../models/node.dart';
import '../models/edge.dart';
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
  final void Function(Edge) onEdgeDoubleTap;
  final void Function(Node) onEditNodeProperties;
  final void Function(Node) onAddEdge;
  final void Function(Node) onDeleteNode;
  final void Function(Edge) onDeleteEdge;
  final void Function(Edge) onEditEdgeProperties;

  GraphWidget({
    required this.graph,
    required this.selectedNodes,
    required this.isShiftPressed,
    required this.onNodeTap,
    required this.onNodeDoubleTap,
    required this.onNodeDragStart,
    required this.onNodeDragUpdate,
    required this.onNodeDragEnd,
    required this.onEdgeDoubleTap,
    required this.onEditNodeProperties,
    required this.onAddEdge,
    required this.onDeleteNode,
    required this.onDeleteEdge,
    required this.onEditEdgeProperties,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition, details.localPosition);
      },
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: EdgePainter(graph, onEdgeDoubleTap),
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
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset globalPosition, Offset localPosition) {
    for (var node in graph.nodes) {
      if (_isPointInNode(localPosition, node)) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            globalPosition.dx,
            globalPosition.dy,
            globalPosition.dx,
            globalPosition.dy,
          ),
          items: [
            PopupMenuItem<String>(
              value: 'edit_properties',
              child: Text('Edit Properties'),
              onTap: () => onEditNodeProperties(node),
            ),
            PopupMenuItem<String>(
              value: 'add_edge',
              child: Text('Add Edge'),
              onTap: () => onAddEdge(node),
            ),
            PopupMenuItem<String>(
              value: 'delete_node',
              child: Text('Delete Node'),
              onTap: () => onDeleteNode(node),
            ),
          ],
        );
        return;
      }
    }
    for (var edge in graph.edges) {
      final fromNode = graph.nodes.firstWhere((node) => node.id == edge.fromNodeId);
      final toNode = graph.nodes.firstWhere((node) => node.id == edge.toNodeId);
      if (_isPointOnLineSegment(localPosition, Offset(fromNode.x, fromNode.y), Offset(toNode.x, toNode.y))) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            globalPosition.dx,
            globalPosition.dy,
            globalPosition.dx,
            globalPosition.dy,
          ),
          items: [
            PopupMenuItem<String>(
              value: 'edit_edge',
              child: Text('Edit Edge'),
              onTap: () => onEditEdgeProperties(edge),
            ),
            PopupMenuItem<String>(
              value: 'delete_edge',
              child: Text('Delete Edge'),
              onTap: () => onDeleteEdge(edge),
            ),
          ],
        );
        return;
      }
    }
  }

  bool _isPointInNode(Offset point, Node node) {
    final double radius = 24.0; // Adjust radius to match node size
    final dx = point.dx - (node.x + radius); // Correct the position to be at the center of the node
    final dy = point.dy - (node.y + radius); // Correct the position to be at the center of the node
    return dx * dx + dy * dy <= radius * radius;
  }

  bool _isPointOnLineSegment(Offset p, Offset a, Offset b) {
    const double tolerance = 5.0; // Adjust tolerance as needed
    final double crossProduct = (p.dy - a.dy) * (b.dx - a.dx) - (p.dx - a.dx) * (b.dy - a.dy);
    if (crossProduct.abs() > tolerance) return false;

    final double dotProduct = (p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy);
    if (dotProduct < 0) return false;

    final double squaredLengthBA = (b.dx - a.dx) * (b.dx - a.dx) + (b.dy - a.dy) * (b.dy - a.dy);
    if (dotProduct > squaredLengthBA) return false;

    return true;
  }
}

class EdgePainter extends CustomPainter {
  final Graph graph;
  final void Function(Edge) onEdgeDoubleTap;

  EdgePainter(this.graph, this.onEdgeDoubleTap);

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

      // Draw the label near the middle of the edge
      final labelOffset = Offset((fromOffset.dx + toOffset.dx) / 2, (fromOffset.dy + toOffset.dy) / 2);
      final textPainter = TextPainter(
        text: TextSpan(
          text: edge.label,
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
