import 'package:flutter/material.dart';
import '../components/prefrences_dialog.dart';
import '../../models/preferences.dart';
import 'graph_screen.dart';
import '../../models/graph.dart';
import '../../models/node_type.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class HomeScreen extends StatefulWidget {
  final Preferences preferences;

  HomeScreen({required this.preferences});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NodeType> _nodeTypes = [];

  @override
  void initState() {
    super.initState();
    _loadNodeTypes();
  }

  Future<void> _loadNodeTypes() async {
    try {
      final String response = await rootBundle.loadString('assets/node_types.json');
      final data = await json.decode(response) as List;
      setState(() {
        _nodeTypes = data.map((json) => NodeType.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading node types: $e');
    }
  }

  Future<void> _openPreferences() async {
    await showDialog(
      context: context,
      builder: (context) {
        return PreferencesDialog(preferences: widget.preferences);
      },
    );
  }

  Future<Graph> _loadGraph(String path) async {
    final file = File(path);
    final contents = await file.readAsString();
    return Graph.fromJson(json.decode(contents), _nodeTypes);
  }

  Future<void> _openGraph() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      Graph graph = await _loadGraph(path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GraphScreen(
            preferences: widget.preferences,
            initialGraph: graph,
            nodeTypes: _nodeTypes,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _openGraph,
              child: Text('Open Graph'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GraphScreen(
                      preferences: widget.preferences,
                      nodeTypes: _nodeTypes,
                    ),
                  ),
                );
              },
              child: Text('New Graph'),
            ),
            ElevatedButton(
              onPressed: _openPreferences,
              child: Text('Preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
