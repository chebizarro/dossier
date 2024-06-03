import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/graph.dart';
import '../models/node_type.dart';

class GraphActions {
  Graph graph;
  final List<NodeType> nodeTypes;
  final VoidCallback onClearUndoStack;
  String? filePath;

  GraphActions({required this.graph, required this.nodeTypes, required this.onClearUndoStack});

  void updateTitle(String title) {
    graph.title = title;
  }

  Future<void> saveGraph() async {
    final jsonGraph = jsonEncode(graph.toJson());

    if (filePath == null) {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Graph',
        fileName: '${graph.title}.json',
      );

      if (result != null) {
        filePath = result;
      }
    }

    if (filePath != null) {
      final file = File(filePath!);
      await file.writeAsString(jsonGraph);
    }
  }

  Future<void> openGraph(ValueChanged<Graph> onGraphLoaded) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open Graph',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      filePath = result.files.single.path!;
      final file = File(filePath!);
      final jsonGraph = jsonDecode(await file.readAsString());
      final newGraph = Graph.fromJson(jsonGraph, nodeTypes);
      onGraphLoaded(newGraph);
      onClearUndoStack();
    }
  }
}
