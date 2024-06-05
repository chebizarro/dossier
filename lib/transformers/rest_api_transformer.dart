import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/graph.dart';
import 'transformer_interface.dart';

class RestApiTransformer implements Transformer {
  Map<String, dynamic> _preferences = {
    'username': '',
    'password': '',
    'num_entities': 10,
    'api_url': 'https://example.com/api'
  };

  @override
  Future<List<Node>> transform(String input) async {
    final response = await http.post(
      Uri.parse(_preferences['api_url']),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('${_preferences['username']}:${_preferences['password']}'))}',
      },
      body: jsonEncode(<String, String>{'input': input, 'num_entities': _preferences['num_entities'].toString()}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Node.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nodes');
    }
  }

  @override
  Future<List<Edge>> transformEdges(String input) async {
    final response = await http.post(
      Uri.parse(_preferences['api_url']),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${base64Encode(utf8.encode('${_preferences['username']}:${_preferences['password']}'))}',
      },
      body: jsonEncode(<String, String>{'input': input, 'num_entities': _preferences['num_entities'].toString()}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Edge.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load edges');
    }
  }

  @override
  Map<String, dynamic> getPreferences() {
    return _preferences;
  }

  @override
  void setPreferences(Map<String, dynamic> preferences) {
    _preferences = preferences;
  }
}
