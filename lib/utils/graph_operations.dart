import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/graph.dart';
import '../models/node_type.dart';

Future<String?> saveGraph(Graph graph) async {
  if (graph.filePath != null) {
    final file = File(graph.filePath!);
    await file.writeAsString(json.encode(graph.toJson()));
    return graph.filePath;
  } else {
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Graph',
      fileName: '${graph.title}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path != null) {
      final file = File(path);
      await file.writeAsString(json.encode(graph.toJson()));
      return path;
    }
  }
  return null;
}

Future<Graph?> openGraph(List<NodeType> nodeTypes) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null && result.files.single.path != null) {
    String path = result.files.single.path!;
    final file = File(path);
    final contents = await file.readAsString();
    final graph = Graph.fromJson(json.decode(contents), nodeTypes);
    graph.filePath = path;
    return graph;
  }
  return null;
}
