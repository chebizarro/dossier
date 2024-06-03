import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '../utils/preferences.dart';
import '../components/graph_widget.dart';
import '../models/graph.dart';
import '../models/node.dart';
import '../models/node_type.dart';
import '../models/edge.dart';
import '../components/graph_title_widget.dart';
import '../components/node_type_selector.dart';
import '../utils/graph_operations.dart';
import '../components/node_property_dialog.dart';
import '../utils/undo_stack.dart';

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
  Node? _edgeStartNode;
  final UndoStack _undoStack = UndoStack();

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
      final newNode = Node(
        id: DateTime.now().toString(),
        label: _selectedNodeType!.label,
        nodeType: _selectedNodeType!,
        x: position.dx,
        y: position.dy,
      );

      setState(() {
        _graph.addNode(newNode);
        _selectedNodes.clear();
        _selectedNodes.add(newNode);
        _selectedNodeType = null;
      });

      _undoStack.addAction(
        UndoAction(
          undo: () {
            setState(() {
              _graph.removeNode(newNode);
            });
          },
          redo: () {
            setState(() {
              _graph.addNode(newNode);
            });
          },
        ),
      );

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showNodePropertyDialog(newNode);
      });
    } else {
      print('No node type selected'); // Debug print
    }
  }

  void _showNodePropertyDialog(Node node) {
    final originalNode = Node(
      id: node.id,
      label: node.label,
      nodeType: node.nodeType,
      x: node.x,
      y: node.y,
      properties: Map<String, dynamic>.from(node.properties),
    );

    showDialog(
      context: context,
      builder: (context) {
        return NodePropertyDialog(
          node: node,
          onSave: (updatedNode) {
            setState(() {
              _graph.nodes = _graph.nodes.map((n) => n.id == updatedNode.id ? updatedNode : n).toList();
            });
          },
          onUndoAction: () {
            _undoStack.addAction(
              UndoAction(
                undo: () {
                  setState(() {
                    _graph.nodes = _graph.nodes.map((n) => n.id == originalNode.id ? originalNode : n).toList();
                  });
                },
                redo: () {
                  setState(() {
                    _graph.nodes = _graph.nodes.map((n) => n.id == node.id ? node : n).toList();
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  void _onNodeTap(Node node, bool isShiftPressed) {
    setState(() {
      if (_edgeStartNode == null) {
        _edgeStartNode = node;
      } else {
        final newEdge = Edge(
          id: DateTime.now().toString(),
          fromNodeId: _edgeStartNode!.id,
          toNodeId: node.id,
        );
        _graph.addEdge(newEdge);
        _undoStack.addAction(
          UndoAction(
            undo: () {
              setState(() {
                _graph.removeEdge(newEdge);
              });
            },
            redo: () {
              setState(() {
                _graph.addEdge(newEdge);
              });
            },
          ),
        );
        _edgeStartNode = null;
      }
    });
  }

  void _onNodeDoubleTap(Node node) {
    _showNodePropertyDialog(node);
  }

  void _onBackgroundTap(TapUpDetails details) {
    setState(() {
      _selectedNodes.clear();
      _edgeStartNode = null;
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
    if (event is RawKeyDownEvent) {
      if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyZ) {
        _undo();
      } else if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyY) {
        _redo();
      }
    }
  }

  void _undo() {
    setState(() {
      _undoStack.undo();
    });
  }

  void _redo() {
    setState(() {
      _undoStack.redo();
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
            icon: Icon(Icons.undo),
            onPressed: _undoStack.canUndo ? _undo : null,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: _undoStack.canRedo ? _redo : null,
          ),
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
                    onNodeDoubleTap: _onNodeDoubleTap,
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
