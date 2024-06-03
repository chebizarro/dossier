import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '../../models/preferences.dart';
import '../components/graph_widget.dart';
import '../../models/graph.dart';
import '../../models/node.dart';
import '../../models/node_type.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class GraphScreen extends StatefulWidget {
  final Preferences preferences;
  final Graph? initialGraph;
  final List<NodeType> nodeTypes;

  GraphScreen({
    required this.preferences,
    this.initialGraph,
    required this.nodeTypes,
  });

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late Graph _graph;
  NodeType? _selectedNodeType;
  Node? _draggingNode;
  Offset? _dragOffset;
  Set<Node> _selectedNodes = {};
  bool _isShiftPressed = false;
  bool _isEditingTitle = false;
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _graph = widget.initialGraph ?? Graph(title: 'Untitled Graph');
    _titleController.text = _graph.title;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _selectNodeType(NodeType nodeType) {
    setState(() {
      _selectedNodeType = nodeType;
    });
    print('Selected node type: ${_selectedNodeType?.label}'); // Debug print
  }

  void _addNodeAtPosition(Offset position) {
    if (_selectedNodeType != null) {
      setState(() {
        final newNode = Node(
          id: DateTime.now().toString(),
          label: _selectedNodeType!.label,
          nodeType: _selectedNodeType!,
          x: position.dx,
          y: position.dy,
        );
        _graph.addNode(newNode);
        _selectedNodes.clear(); // Clear any already selected nodes
        _selectedNodes.add(newNode); // Select the new node by default
        _selectedNodeType = null; // Reset the selected node type
        print('Node added at position: (${position.dx}, ${position.dy})'); // Debug print
      });
    } else {
      print('No node type selected'); // Debug print
    }
  }

  void _onNodeTap(Node node, bool isShiftPressed) {
    setState(() {
      if (isShiftPressed) {
        if (_selectedNodes.contains(node)) {
          _selectedNodes.remove(node);
        } else {
          _selectedNodes.add(node);
        }
      } else {
        _selectedNodes.clear();
        _selectedNodes.add(node);
      }
      print('Selected nodes: ${_selectedNodes.map((n) => n.label).join(', ')}'); // Debug print
    });
  }

  void _onBackgroundTap(TapUpDetails details) {
    setState(() {
      _selectedNodes.clear();
    });
    _addNodeAtPosition(details.localPosition);
  }

  void _onNodeDragStart(Node node, Offset position) {
    if (_selectedNodes.contains(node)) {
      setState(() {
        _draggingNode = node;
        _dragOffset = position;
      });
    }
  }

  void _onNodeDragUpdate(Offset delta) {
    if (_draggingNode != null && _dragOffset != null) {
      setState(() {
        for (var node in _selectedNodes) {
          node.x += delta.dx;
          node.y += delta.dy;
        }
      });
    }
  }

  void _onNodeDragEnd() {
    setState(() {
      _draggingNode = null;
      _dragOffset = null;
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    setState(() {
      _isShiftPressed = event.isShiftPressed;
    });
  }

  Future<void> _saveGraph() async {
    // Allow the user to pick a location and save the file
    final String? pickedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Graph As',
      fileName: '${_graph.title}.json',
    );

    if (pickedPath != null) {
      final pickedFile = File(pickedPath);
      await pickedFile.writeAsString(json.encode(_graph.toJson()));
    }
  }

  Future<void> _openGraph() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      final file = File(path);
      final contents = await file.readAsString();
      setState(() {
        _graph = Graph.fromJson(json.decode(contents), widget.nodeTypes);
        _titleController.text = _graph.title;
      });
    }
  }

  void _editTitle() {
    setState(() {
      _isEditingTitle = true;
    });
  }

  void _saveTitle() {
    setState(() {
      _graph.title = _titleController.text;
      _isEditingTitle = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      appBar: AppBar(
        title: _isEditingTitle
            ? TextField(
                controller: _titleController,
                onSubmitted: (_) => _saveTitle(),
                autofocus: true,
              )
            : GestureDetector(
                onTap: _editTitle,
                child: Text(_graph.title),
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveGraph,
          ),
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _openGraph,
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKey: _handleKeyEvent,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTapUp: _onBackgroundTap,
                child: Container(
                  color: Colors.transparent,
                  child: GraphWidget(
                    graph: _graph,
                    onNodeTap: _onNodeTap,
                    onNodeDragStart: _onNodeDragStart,
                    onNodeDragUpdate: _onNodeDragUpdate,
                    onNodeDragEnd: _onNodeDragEnd,
                    selectedNodes: _selectedNodes,
                    isShiftPressed: _isShiftPressed,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Text(
                _selectedNodes.isNotEmpty
                    ? 'Selected nodes: ${_selectedNodes.map((n) => n.label).join(', ')}'
                    : 'No nodes selected',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        children: widget.nodeTypes.map((nodeType) {
          return FloatingActionButton(
            mini: true,
            onPressed: () => _selectNodeType(nodeType),
            child: Icon(nodeType.icon),
            backgroundColor: nodeType.color,
            heroTag: nodeType.type,
            tooltip: nodeType.label,
          );
        }).toList(),
      ),
    );
  }
}
