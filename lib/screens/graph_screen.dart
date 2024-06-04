import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/node.dart';
import '../utils/graph_pdf.dart';
import '../models/graph.dart';
import '../models/node_type.dart';
import '../models/edge_type.dart';
import '../utils/preferences.dart';
import '../components/graph_widget.dart';

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

class GraphScreenState extends State<GraphScreen> with TickerProviderStateMixin {
  late Graph _graph;
  NodeType? _selectedNodeType;
  EdgeType? _selectedEdgeType;
  Set<Node> _selectedNodes = {};
  bool _isShiftPressed = false;
  bool _isCtrlPressed = false;
  double _zoomLevel = 1.0;

  late TransformationController _transformationController;
  late AnimationController _animationController;
  late Animation<Matrix4> _animation;

  @override
  void initState() {
    super.initState();
    _graph = widget.initialGraph ?? Graph(title: 'Untitled Graph');
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _transformationController.value = _transformationController.value;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _transformationController.value = _transformationController.value.scaled(details.scale);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: _transformationController.value,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animationController));
    _animationController.forward(from: 0);
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel *= 1.2;
      _transformationController.value = _transformationController.value.scaled(1.2);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel /= 1.2;
      _transformationController.value = _transformationController.value.scaled(1 / 1.2);
    });
  }

  void _handleScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return;
    final scrollDelta = notification.scrollDelta ?? 0.0;
    final scale = 1.0 - scrollDelta / 300.0;
    _transformationController.value = _transformationController.value.scaled(scale);
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
      appBar: AppBar(
        title: Text('Graph'),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: saveGraphAsPdf,
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScroll(notification);
          return true;
        },
        child: InteractiveViewer(
          transformationController: _transformationController,
          onInteractionStart: _handleScaleStart,
          onInteractionUpdate: _handleScaleUpdate,
          onInteractionEnd: _handleScaleEnd,
          boundaryMargin: EdgeInsets.all(100.0),
          minScale: 0.1,
          maxScale: 5.0,
          child: GraphWidget(
            graph: _graph,
            selectedNodes: _selectedNodes,
            isShiftPressed: _isShiftPressed,
            onNodeTap: (node, isShiftPressed) {},
            onNodeDoubleTap: (node) {},
            onNodeDragStart: (node, position) {},
            onNodeDragUpdate: (delta) {},
            onNodeDragEnd: () {},
            onEdgeDoubleTap: (edge) {},
            onEditNodeProperties: (node) {},
            onEditEdgeProperties: (edge) {},
            onAddEdge: (node) {},
            onDeleteNode: (node) {},
            onDeleteEdge: (edge) {},
          ),
        ),
      ),
    );
  }
}
