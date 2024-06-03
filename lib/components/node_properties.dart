import 'package:flutter/material.dart';
import '../models/node.dart';

class NodeProperties extends StatelessWidget {
  final Node node;

  NodeProperties({required this.node});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID: ${node.id}'),
        Text('Label: ${node.label}'),
        // Add more properties as needed
      ],
    );
  }
}
