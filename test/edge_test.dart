import 'package:flutter_test/flutter_test.dart';
import 'package:dossier/models/edge.dart';

void main() {
  group('Edge', () {
    test('fromJson should create an Edge from a JSON object', () {
      final json = {
        'id': '1',
        'fromNodeId': '2',
        'toNodeId': '3',
        'label': 'Test Edge',
        'properties': {'key': 'value'}
      };
      final edge = Edge.fromJson(json);

      expect(edge.id, '1');
      expect(edge.fromNodeId, '2');
      expect(edge.toNodeId, '3');
      expect(edge.label, 'Test Edge');
      expect(edge.properties['key'], 'value');
    });

    test('toJson should create a JSON object from an Edge', () {
      final edge = Edge(
        id: '1',
        fromNodeId: '2',
        toNodeId: '3',
        label: 'Test Edge',
        properties: {'key': 'value'},
      );
      final json = edge.toJson();

      expect(json['id'], '1');
      expect(json['fromNodeId'], '2');
      expect(json['toNodeId'], '3');
      expect(json['label'], 'Test Edge');
      expect(json['properties']['key'], 'value');
    });
  });
}
