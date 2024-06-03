import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/graph.dart';
import '../models/node_type.dart';

// Function to save the graph to a file
Future<String?> saveGraphToFile(Graph graph) async {
  final filePath = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Graph',
    fileName: '${graph.title}.json',
    allowedExtensions: ['json'],
    type: FileType.custom,
  );

  if (filePath != null) {
    final file = File(filePath);
    await file.writeAsString(jsonEncode(graph.toJson()));
  }

  return filePath;
}

// Function to open a graph from a file
Future<Graph?> openGraphFromFile(List<NodeType> nodeTypes) async {
  final result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Open Graph',
    allowedExtensions: ['json'],
    type: FileType.custom,
  );

  if (result != null && result.files.isNotEmpty) {
    final file = File(result.files.single.path!);
    final jsonData = await file.readAsString();
    return Graph.fromJson(jsonDecode(jsonData), nodeTypes);
  }

  return null;
}
