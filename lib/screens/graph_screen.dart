import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '../utils/preferences.dart';
import '../components/graph_widget.dart';
import '../models/graph.dart';
import '../models/node.dart';
import '../models/node_type.dart';
import '../components/graph_title_widget.dart';
import '../components/node_type_selector.dart';
import '../utils/graph_operations.dart';

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

  @override
  void initState() {
    super.initState();
    _graph = widget.initialGraph ?? Graph(title: 'Untitled Graph');
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
    final path = await saveGraph(_graph);
    if (path != null) {
      setState(() {
        _graph.filePath = path;
      });
    }
  }

  Future<void> _openGraph() async {
    final graph = await openGraph(widget.nodeTypes);
    if (graph != null) {
      setState(() {
        _graph = graph;
      });
    }
  }

  void _updateTitle(String title) {
    setState(() {
      _graph.title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      appBar: AppBar(
        title: GraphTitleWidget(
          title: _graph.title,
          onTitleChanged: _updateTitle,
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
      floatingActionButton: NodeTypeSelector(
        nodeTypes: widget.nodeTypes,
        onNodeTypeSelected: _selectNodeType,
      ),
    );
  }
}
