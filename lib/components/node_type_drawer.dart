import 'package:flutter/material.dart';
import '../models/node_type.dart';
import '../models/edge_type.dart';

class NodeTypeDrawer extends StatelessWidget {
  final List<NodeType> nodeTypes;
  final List<EdgeType> edgeTypes;
  final ValueChanged<NodeType> onNodeTypeSelected;
  final ValueChanged<EdgeType> onEdgeTypeSelected;

  NodeTypeDrawer({
    required this.nodeTypes,
    required this.edgeTypes,
    required this.onNodeTypeSelected,
    required this.onEdgeTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            child: Text(
              'Add Items',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Node Types'),
                ),
                GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  itemCount: nodeTypes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemBuilder: (context, index) {
                    final nodeType = nodeTypes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onNodeTypeSelected(nodeType);
                      },
                      child: Card(
                        color: nodeType.color,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(nodeType.icon, size: 36, color: Colors.white),
                              Text(nodeType.label, style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Edge Types'),
                ),
                GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  itemCount: edgeTypes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemBuilder: (context, index) {
                    final edgeType = edgeTypes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onEdgeTypeSelected(edgeType);
                      },
                      child: Card(
                        color: Colors.blue, // Change color as needed
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(edgeType.icon, size: 36, color: Colors.white),
                              Text(edgeType.label, style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
