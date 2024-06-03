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
import '../utils/undo_stack.dart';
import '../handlers/node_edge_handler.dart';
import '../handlers/graph_actions.dart';

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
  final UndoStack _undoStack = UndoStack();
  late NodeEdgeHandler _nodeEdgeHandler;
  late GraphActions _graphActions;

  @override
  void initState() {
    super.initState();
    _graph = widget.initialGraph ?? Graph(title: 'Untitled Graph');
    _nodeEdgeHandler = NodeEdgeHandler(graph: _graph, undoStack: _undoStack);
    _graphActions = GraphActions(graph: _graph, nodeTypes: widget.nodeTypes);
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
        _nodeEdgeHandler.addNode(newNode);
        _selectedNodes.clear();
        _selectedNodes.add(newNode);
        _selectedNodeType = null;
      });

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _nodeEdgeHandler.handleNodeDoubleTap(newNode, context, () => setState(() {}));
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
    });
  }

  void _onNodeDoubleTap(Node node) {
    _nodeEdgeHandler.handleNodeDoubleTap(node, context, () => setState(() {}));
  }

  void _onEdgeDoubleTap(Edge edge) {
    _nodeEdgeHandler.handleEdgeDoubleTap(edge, context, () => setState(() {}));
  }

  void _onEditNodeProperties(Node node) {
    _nodeEdgeHandler.handleNodeDoubleTap(node, context, () => setState(() {}));
  }

  void _onAddEdge(Node node) {
    setState(() {
      if (_nodeEdgeHandler.edgeStartNode == null) {
        _nodeEdgeHandler.edgeStartNode = node;
      } else {
        final newEdge = Edge(
          id: DateTime.now().toString(),
          fromNodeId: _nodeEdgeHandler.edgeStartNode!.id,
          toNodeId: node.id,
        );
        _nodeEdgeHandler.addEdge(newEdge);
        _nodeEdgeHandler.edgeStartNode = null;
      }
    });
  }

  void _onDeleteNode(Node node) {
    setState(() {
      _graph.removeNode(node);
    });
  }

  void _onDeleteEdge(Edge edge) {
    setState(() {
      _graph.removeEdge(edge);
    });
  }

  void _onEditEdge(Edge edge) {
    _nodeEdgeHandler.handleEdgeDoubleTap(edge, context, () => setState(() {}));
  }

  void _onBackgroundTap(TapUpDetails details) {
    setState(() {
      _selectedNodes.clear();
      _nodeEdgeHandler.edgeStartNode = null;
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

  void _handleKeyEvent(KeyEvent event) {
    setState(() {
      _isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
    });

    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight)) {
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          _undo();
        } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
          _redo();
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      appBar: AppBar(
        title: GraphTitleWidget(
          title: _graph.title,
          onTitleChanged: (title) {
            setState(() {
              _graphActions.updateTitle(title);
            });
          },
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
            onPressed: () async {
              await _graphActions.saveGraph();
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: () async {
              await _graphActions.openGraph((graph) {
                setState(() {
                  _graph = graph;
                  _nodeEdgeHandler.graph = graph;
                  _graphActions.graph = graph;
                });
              });
            },
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: _handleKeyEvent,
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
                    onEdgeDoubleTap: _onEdgeDoubleTap,
                    onEditNodeProperties: _onEditNodeProperties,
                    onAddEdge: _onAddEdge,
                    onDeleteNode: _onDeleteNode,
                    onDeleteEdge: _onDeleteEdge,
                    onEditEdge: _onEditEdge,
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
