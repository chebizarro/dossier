import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/graph.dart';

class GraphOperations {
  static Future<String?> saveGraph(Graph graph) async {
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

  static Future<Graph?> loadGraph() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open Graph',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final jsonString = await File(result.files.single.path!).readAsString();
      final jsonMap = jsonDecode(jsonString);
      return Graph.fromJson(jsonMap);
    }
    return null;
  }
}

