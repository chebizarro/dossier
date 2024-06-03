import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/node_type.dart';
import '../models/edge_type.dart';
import '../utils/preferences.dart';
import 'graph_screen.dart';

class HomeScreen extends StatelessWidget {
  final Preferences preferences;

  HomeScreen({required this.preferences});

  Future<List<NodeType>> _loadNodeTypes() async {
    final String response = await rootBundle.loadString('assets/node_types.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => NodeType.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: FutureBuilder<List<NodeType>>(
        future: _loadNodeTypes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading node types'));
          } else {
            final nodeTypes = snapshot.data ?? [];
            // Define edge types (could also be loaded from a JSON file similarly)
            final List<EdgeType> edgeTypes = [
              EdgeType(
                type: 'friend',
                label: 'Friend',
                icon: Icons.people,
                properties: {'example_property': 'example_value'},
              ),
              EdgeType(
                type: 'colleague',
                label: 'Colleague',
                icon: Icons.work,
                properties: {'example_property': 'example_value'},
              ),
              // Add more edge types as needed
            ];

            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GraphScreen(
                        preferences: preferences,
                        nodeTypes: nodeTypes,
                        edgeTypes: edgeTypes,
                      ),
                    ),
                  );
                },
                child: Text('Open Graph Screen'),
              ),
            );
          }
        },
      ),
    );
  }
}
