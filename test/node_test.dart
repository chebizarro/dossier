import 'package:flutter_test/flutter_test.dart';
import 'package:dossier/models/node.dart';

void main() {
  group('Node', () {
    test('fromJson should create a Node from a JSON object', () {
      final json = {
        'id': '1',
        'label': 'Test Node',
        'x': 10.0,
        'y': 20.0,
        'properties': {'key': 'value'},
        'attachedFiles': []
      };
      final node = Node.fromJson(json);

      expect(node.id, '1');
      expect(node.label, 'Test Node');
      expect(node.x, 10.0);
      expect(node.y, 20.0);
      expect(node.properties['key'], 'value');
      // expect(node.attachedFiles, []);
    });

    test('toJson should create a JSON object from a Node', () {
      final node = Node(
        id: '1',
        label: 'Test Node',
        x: 10.0,
        y: 20.0,
        properties: {'key': 'value'},
        //attachedFiles: [],
      );
      final json = node.toJson();

      expect(json['id'], '1');
      expect(json['label'], 'Test Node');
      expect(json['x'], 10.0);
      expect(json['y'], 20.0);
      expect(json['properties']['key'], 'value');
      //expect(json['attachedFiles'], []);
    });
  });
}
