import 'package:flutter/material.dart';
import '../../packages/dossier_api/lib/src/models/graph.dart';

class MiniMap extends StatelessWidget {
  final Graph graph;
  final double scale;

  MiniMap({required this.graph, this.scale = 0.1});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Width of the mini-map
      height: 200, // Height of the mini-map
      color: Colors.white.withOpacity(0.8),
      child: CustomPaint(
        painter: MiniMapPainter(graph: graph, scale: scale),
      ),
    );
  }
}

class MiniMapPainter extends CustomPainter {
  final Graph graph;
  final double scale;

  MiniMapPainter({required this.graph, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Draw nodes
    for (var node in graph.nodes) {
      final scaledX = node.x * scale;
      final scaledY = node.y * scale;
      canvas.drawCircle(Offset(scaledX, scaledY), 3, paint);
    }

    // Draw edges
    for (var edge in graph.edges) {
      final fromNode = graph.nodes.firstWhere((node) => node.id == edge.fromNodeId);
      final toNode = graph.nodes.firstWhere((node) => node.id == edge.toNodeId);

      final fromOffset = Offset(fromNode.x * scale, fromNode.y * scale);
      final toOffset = Offset(toNode.x * scale, toNode.y * scale);

      canvas.drawLine(fromOffset, toOffset, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
