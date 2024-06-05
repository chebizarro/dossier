import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dossier/screens/graph_screen.dart';
import '../packages/dossier_api/lib/src/models/graph.dart';
import '../packages/dossier_api/lib/src/models/node_type.dart';
import '../packages/dossier_api/lib/src/models/edge_type.dart';
import 'package:dossier/utils/preferences.dart';

void main() {
  testWidgets('GraphScreen displays the correct title', (WidgetTester tester) async {
    final graph = Graph(title: 'Test Graph');
    final preferences = Preferences();
    final nodeTypes = <NodeType>[];
    final edgeTypes = <EdgeType>[];

    await tester.pumpWidget(MaterialApp(
      home: GraphScreen(
        preferences: preferences,
        initialGraph: graph,
        nodeTypes: nodeTypes,
        edgeTypes: edgeTypes,
        runTransformer: (input) {},
      ),
    ));

    expect(find.text('Test Graph'), findsOneWidget);
  });
}
