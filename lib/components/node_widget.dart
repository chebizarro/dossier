import 'package:flutter/material.dart';
import '../models/node.dart';

class NodeWidget extends StatelessWidget {
  final Node node;
  final bool isSelected;
  final ValueChanged<Node> onNodeTap;
  final ValueChanged<Node> onNodeDoubleTap;

  NodeWidget({
    required this.node,
    required this.isSelected,
    required this.onNodeTap,
    required this.onNodeDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onNodeTap(node),
      onDoubleTap: () => onNodeDoubleTap(node),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blueAccent : node.nodeType.color,
            ),
            padding: EdgeInsets.all(16.0),
            child: Icon(node.nodeType.icon, color: Colors.white),
          ),
          SizedBox(height: 4.0),
          Text(node.label, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
