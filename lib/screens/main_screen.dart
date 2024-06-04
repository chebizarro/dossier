import 'package:flutter/material.dart';
import '../screens/graph_screen.dart';
import '../utils/preferences.dart';
import '../models/node_type.dart';
import '../models/edge_type.dart';
import '../models/graph.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../components/node_type_drawer.dart';
import '../utils/app_state.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Graph> _graphs = [];
  late Preferences _preferences;
  List<NodeType> _nodeTypes = [];
  List<EdgeType> _edgeTypes = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  NodeType? _selectedNodeType;
  EdgeType? _selectedEdgeType;

  @override
  void initState() {
    super.initState();
    _preferences = Preferences(startMaximized: false);
    _loadNodeAndEdgeTypes().then((_) {
      setState(() {
        _tabController = TabController(length: _graphs.length, vsync: this);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNodeAndEdgeTypes() async {
    final nodeTypesJson = await rootBundle.loadString('assets/node_types.json');
    final edgeTypesJson = await rootBundle.loadString('assets/edge_types.json');
    
    final List<dynamic> nodeTypesData = jsonDecode(nodeTypesJson);
    final List<dynamic> edgeTypesData = jsonDecode(edgeTypesJson);
    
    setState(() {
      _nodeTypes = nodeTypesData.map((data) => NodeType.fromJson(data)).toList();
      _edgeTypes = edgeTypesData.map((data) => EdgeType.fromJson(data)).toList();
    });
  }

  void _addNewGraph() {
    setState(() {
      _graphs.add(Graph(title: 'New Graph ${_graphs.length + 1}'));
      _tabController.dispose();
      _tabController = TabController(length: _graphs.length, vsync: this);
      _tabController.animateTo(_graphs.length - 1);
    });
  }

  void _removeGraph(int index) {
    setState(() {
      _graphs.removeAt(index);
      _tabController.dispose();
      _tabController = TabController(length: _graphs.length, vsync: this);
    });
  }

  Future<void> _saveCurrentGraph() async {
    if (_tabController.index >= 0 && _tabController.index < _graphs.length) {
      final currentGraph = _graphs[_tabController.index];
      // Implement your save logic here
    }
  }

  Future<void> _openGraph() async {
    // Implement your open logic here
  }

  void _undo() {
    if (_tabController.index >= 0 && _tabController.index < _graphs.length) {
      final currentGraph = _graphs[_tabController.index];
      // Implement your undo logic here for the currentGraph
    }
  }

  void _redo() {
    if (_tabController.index >= 0 && _tabController.index < _graphs.length) {
      final currentGraph = _graphs[_tabController.index];
      // Implement your redo logic here for the currentGraph
    }
  }

  void _selectNodeType(NodeType? nodeType) {
    setState(() {
      _selectedNodeType = nodeType;
      _selectedEdgeType = null;
    });
  }

  void _selectEdgeType(EdgeType edgeType) {
    setState(() {
      _selectedNodeType = null;
      _selectedEdgeType = edgeType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      selectedNodeType: _selectedNodeType,
      selectedEdgeType: _selectedEdgeType,
      onNodeTypeSelected: _selectNodeType,
      onEdgeTypeSelected: _selectEdgeType,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Dossier'),
          actions: [
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: _undo,
            ),
            IconButton(
              icon: Icon(Icons.redo),
              onPressed: _redo,
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveCurrentGraph,
            ),
            IconButton(
              icon: Icon(Icons.folder_open),
              onPressed: _openGraph,
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addNewGraph,
            ),
          ],
          bottom: _graphs.isNotEmpty
              ? TabBar(
                  controller: _tabController,
                  tabs: _graphs.map((graph) => Tab(text: graph.title)).toList(),
                )
              : null,
        ),
        drawer: NodeTypeDrawer(
          nodeTypes: _nodeTypes,
          edgeTypes: _edgeTypes,
          onNodeTypeSelected: _selectNodeType,
          onEdgeTypeSelected: _selectEdgeType,
        ),
        body: _graphs.isNotEmpty
            ? TabBarView(
                controller: _tabController,
                children: _graphs.map((graph) {
                  return GraphScreen(
                    preferences: _preferences,
                    initialGraph: graph,
                    nodeTypes: _nodeTypes,
                    edgeTypes: _edgeTypes,
                  );
                }).toList(),
              )
            : Center(
                child: Text('No graphs open. Click the + button to add a new graph.'),
              ),
      ),
    );
  }
}
