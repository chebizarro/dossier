import 'package:flutter/material.dart';
import '../models/graph_state.dart';
import '../models/graph.dart';

class GraphWidget extends StatelessWidget {
  final GraphState graphState;

  GraphWidget({required this.graphState});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle graph interaction
      },
      child: CustomPaint(
        painter: GraphPainter(graphState),
        child: Container(),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final GraphState graphState;

  GraphPainter(this.graphState);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw nodes and edges
    for (var node in graphState.nodes) {
      // Draw nodes
    }

    for (var edge in graphState.edges) {
      // Draw edges
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
