import 'package:flutter/material.dart';
import '../models/graph.dart';
import '../models/node.dart';

class NodeTableView extends StatelessWidget {
  final Graph graph;

  NodeTableView({required this.graph});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Label')),
        DataColumn(label: Text('X')),
        DataColumn(label: Text('Y')),
      ],
      rows: graph.nodes.map((node) {
        return DataRow(
          cells: [
            DataCell(Text(node.id)),
            DataCell(Text(node.label)),
            DataCell(Text(node.x.toString())),
            DataCell(Text(node.y.toString())),
          ],
        );
      }).toList(),
    );
  }
}
