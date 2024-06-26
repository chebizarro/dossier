import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/graph_pdf.dart';
import '../utils/preferences.dart';
import '../components/graph_widget.dart';
import '../models/graph.dart';
import '../models/node.dart';
import '../models/node_type.dart';
import '../models/edge.dart';
import '../models/edge_type.dart';
import '../utils/undo_stack.dart';
import '../handlers/node_edge_handler.dart';
import '../handlers/graph_actions.dart';
import '../utils/app_state.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class GraphScreen extends StatefulWidget {
  final Preferences preferences;
  final Graph? initialGraph;
  final List<NodeType> nodeTypes;
  final List<EdgeType> edgeTypes;
  final ValueChanged<bool> onUndoStackChanged;

  GraphScreen({
    required this.preferences,
    this.initialGraph,
    required this.nodeTypes,
    required this.edgeTypes,
    required this.onUndoStackChanged,
    Key? key,
  }) : super(key: key);

  @override
  GraphScreenState createState() => GraphScreenState();
}

class GraphScreenState extends State<GraphScreen> {
  late Graph _graph;
  NodeType? _selectedNodeType;
  EdgeType? _selectedEdgeType;
  Node? _draggingNode;
  Offset? _dragOffset;
  Offset? _initialDragPosition;
  Set<Node> _selectedNodes = {};
  bool _isShiftPressed = false;
  bool _isCtrlPressed = false;
  final UndoStack _undoStack = UndoStack();
  late NodeEdgeHandler _nodeEdgeHandler;
  late GraphActions _graphActions;

  @override
  void initState() {
    super.initState();
    _graph = widget.initialGraph ?? Graph(title: 'Untitled Graph');
    _nodeEdgeHandler = NodeEdgeHandler(graph: _graph, undoStack: _undoStack);
    _graphActions = GraphActions(
      graph: _graph,
      nodeTypes: widget.nodeTypes,
      onClearUndoStack: _clearUndoStack,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    _undoStack.addListener(_notifyUndoStackChanged);
  }

  @override
  void dispose() {
    _undoStack.removeListener(_notifyUndoStackChanged);
    super.dispose();
  }

  void _notifyUndoStackChanged() {
    widget.onUndoStackChanged(_undoStack.canUndo || _undoStack.canRedo);
  }

  void _clearUndoStack() {
    setState(() {
      _undoStack.clear();
      _notifyUndoStackChanged();
    });
  }

  void _addNodeAtPosition(Offset position) {
    final appState = AppState.of(context);
    if (appState?.selectedNodeType != null) {
      final newNode = Node(
        id: DateTime.now().toString(),
        label: appState!.selectedNodeType!.label,
        nodeType: appState.selectedNodeType!,
        x: position.dx,
        y: position.dy,
      );

      setState(() {
        _nodeEdgeHandler.addNode(newNode);
        _selectedNodes.clear();
        _selectedNodes.add(newNode);

        if (!_isCtrlPressed) {
          appState.onNodeTypeSelected(null);
        }
        _notifyUndoStackChanged();
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

  void _onEditEdgeProperties(Edge edge) {
    _nodeEdgeHandler.handleEdgeDoubleTap(edge, context, () => setState(() {}));
  }

  void _onAddEdge() {
    if (_selectedNodes.length == 2) {
      final nodes = _selectedNodes.toList();
      final appState = AppState.of(context);
      if (appState?.selectedEdgeType != null) {
        final newEdge = Edge(
          id: DateTime.now().toString(),
          fromNodeId: nodes[0].id,
          toNodeId: nodes[1].id,
          edgeType: appState!.selectedEdgeType!,
        );
        setState(() {
          _nodeEdgeHandler.addEdge(newEdge);
          appState.onEdgeTypeSelected(newEdge.edgeType);
          _notifyUndoStackChanged();
        });
      } else {
        print('No edge type selected'); // Debug print
      }
    }
  }

  void _onDeleteNode(Node node) {
    setState(() {
      _nodeEdgeHandler.removeNode(node);
      _notifyUndoStackChanged();
    });
  }

  void _deleteSelectedNodes() {
    setState(() {
      for (var node in _selectedNodes) {
        _nodeEdgeHandler.removeNode(node);
      }
      _selectedNodes.clear();
      _notifyUndoStackChanged();
    });
  }

  void _deleteSelectedEdges() {
    // Add logic for deleting edges if necessary
  }

  void _onDelete() {
    _deleteSelectedNodes();
    _deleteSelectedEdges();
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
        _initialDragPosition = Offset(node.x, node.y);
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
    if (_draggingNode != null && _initialDragPosition != null) {
      final newPosition = Offset(_draggingNode!.x, _draggingNode!.y);
      _nodeEdgeHandler.moveNode(_draggingNode!, _initialDragPosition!, newPosition);
      _notifyUndoStackChanged();
    }
    setState(() {
      _draggingNode = null;
      _dragOffset = null;
      _initialDragPosition = null;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    setState(() {
      _isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight);
      _isCtrlPressed = HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          HardwareKeyboard.instance.logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);
    });

    if (event is KeyDownEvent) {
      if (_isCtrlPressed) {
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          undo();
        } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
          redo();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        _deleteSelectedNodes();
      }
    }
  }

  void undo() {
    setState(() {
      _undoStack.undo();
      _notifyUndoStackChanged();
    });
  }

  void redo() {
    setState(() {
      _undoStack.redo();
      _notifyUndoStackChanged();
    });
  }

  void _showContextMenu(BuildContext context, Offset globalPosition) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(globalPosition),
          overlay.localToGlobal(globalPosition),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<void>(
          child: Text('Delete'),
          onTap: _onDelete,
        ),
        if (_selectedNodes.length == 2)
          PopupMenuItem<void>(
            child: Text('Add Edge'),
            onTap: _onAddEdge,
          ),
      ],
    );
  }

  void _onDeleteEdge(Edge edge) {
    setState(() {
      _nodeEdgeHandler.removeEdge(edge);
      _notifyUndoStackChanged();
    });
  }

  Future<void> saveGraphAsPdf() async {
    final pdfGenerator = GraphPdf(_graph);
    final pdfData = await pdfGenerator.generatePdf();

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/graph.pdf");
    await file.writeAsBytes(pdfData);

    // Optionally, open the PDF file using the default PDF viewer
    await Printing.sharePdf(bytes: pdfData, filename: 'graph.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: _handleKeyEvent,
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTapUp: _onBackgroundTap,
                onSecondaryTapUp: (details) {
                  _showContextMenu(context, details.globalPosition);
                },
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
                    onEditEdgeProperties: _onEditEdgeProperties,
                    onAddEdge: _onAddEdge,
                    onDeleteNode: _onDeleteNode,
                    onDeleteEdge: _onDeleteEdge,
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
    );
  }
}
