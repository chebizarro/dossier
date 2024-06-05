import '../models/node.dart';
import '../models/edge.dart';

abstract class Transformer {
  Future<List<Node>> transform(String input);
  Future<List<Edge>> transformEdges(String input);
  Map<String, dynamic> getPreferences();
  void setPreferences(Map<String, dynamic> preferences);
}
