import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/node.dart';
import '../models/edge.dart';
import 'transformer_interface.dart';

class GraphQLTransformer implements Transformer {
  Map<String, dynamic> _preferences = {
    'api_url': 'https://example.com/graphql',
    'username': '',
    'password': '',
    'query': '''
      query FetchData(\$input: String!) {
        fetchData(input: \$input) {
          nodes {
            id
            label
          }
          edges {
            fromNodeId
            toNodeId
            label
          }
        }
      }
    '''
  };

  @override
  Future<List<Node>> transform(String input) async {
    final HttpLink httpLink = HttpLink(
      _preferences['api_url'],
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer ${_preferences['password']}',
    );

    final Link link = authLink.concat(httpLink);

    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );

    final QueryOptions options = QueryOptions(
      document: gql(_preferences['query']),
      variables: <String, dynamic>{
        'input': input,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception('Failed to load data: ${result.exception.toString()}');
    }

    final List<dynamic> nodesData = result.data?['fetchData']['nodes'] ?? [];
    return nodesData.map((json) => Node.fromJson(json)).toList();
  }

  @override
  Future<List<Edge>> transformEdges(String input) async {
    final HttpLink httpLink = HttpLink(
      _preferences['api_url'],
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer ${_preferences['password']}',
    );

    final Link link = authLink.concat(httpLink);

    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );

    final QueryOptions options = QueryOptions(
      document: gql(_preferences['query']),
      variables: <String, dynamic>{
        'input': input,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception('Failed to load data: ${result.exception.toString()}');
    }

    final List<dynamic> edgesData = result.data?['fetchData']['edges'] ?? [];
    return edgesData.map((json) => Edge.fromJson(json)).toList();
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
