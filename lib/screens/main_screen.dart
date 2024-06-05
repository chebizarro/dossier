import 'package:flutter/material.dart';
import '../screens/graph_screen.dart';
import '../transformers/rest_api_transformer.dart';
import '../transformers/transformer_interface.dart';
import '../utils/preferences.dart';
import '../../packages/dossier_api/lib/src/models/node_type.dart';
import '../../packages/dossier_api/lib/src/models/edge_type.dart';
import '../../packages/dossier_api/lib/src/models/graph.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../components/node_type_drawer.dart';
import '../utils/app_state.dart';
import '../handlers/graph_actions.dart';

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

  List<GlobalKey<GraphScreenState>> _graphScreenKeys = [];

  NodeType? _selectedNodeType;
  EdgeType? _selectedEdgeType;
  bool _canUndo = false;
  bool _canRedo = false;

  final Transformer _transformer = RestApiTransformer();
  late Map<String, dynamic> _transformerPreferences;

  @override
  void initState() {
    super.initState();
    _preferences = Preferences();
    _loadNodeAndEdgeTypes().then((_) {
      setState(() {
        _tabController = TabController(length: _graphs.length, vsync: this);
      });
    });
    _loadTransformerPreferences();
  }

  void _runTransformer(String input) async {
    final nodes = await _transformer.transform(input);
    final edges = await _transformer.transformEdges(input);

    setState(() {
      final currentGraph = _graphs[_tabController.index];
      currentGraph.nodes.addAll(nodes);
      currentGraph.edges.addAll(edges);
    });
  }

  void _showTransformerPreferencesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final usernameController = TextEditingController(text: _transformerPreferences['username']);
        final passwordController = TextEditingController(text: _transformerPreferences['password']);
        final numEntitiesController = TextEditingController(text: _transformerPreferences['num_entities'].toString());
        final apiUrlController = TextEditingController(text: _transformerPreferences['api_url']);

        return AlertDialog(
          title: Text('Transformer Preferences'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: numEntitiesController,
                decoration: InputDecoration(labelText: 'Number of Entities'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: apiUrlController,
                decoration: InputDecoration(labelText: 'API URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _transformerPreferences['username'] = usernameController.text;
                  _transformerPreferences['password'] = passwordController.text;
                  _transformerPreferences['num_entities'] = int.parse(numEntitiesController.text);
                  _transformerPreferences['api_url'] = apiUrlController.text;
                });
                _saveTransformerPreferences();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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

  Future<void> _loadTransformerPreferences() async {
    final keys = ['username', 'password', 'num_entities', 'api_url'];
    _transformerPreferences = await _preferences.loadPreferences(keys);
    _transformer.setPreferences(_transformerPreferences);
  }

  Future<void> _saveTransformerPreferences() async {
    await _preferences.savePreferences(_transformerPreferences);
  }


  void _addNewGraph() {
    setState(() {
      final graph = Graph(title: 'New Graph ${_graphs.length + 1}');
      _graphs.add(graph);
      _graphScreenKeys.add(GlobalKey<GraphScreenState>());
      _tabController.dispose();
      _tabController = TabController(length: _graphs.length, vsync: this);
      _tabController.animateTo(_graphs.length - 1);
    });
  }

  void _removeGraph(int index) {
    setState(() {
      _graphs.removeAt(index);
      _graphScreenKeys.removeAt(index);
      _tabController.dispose();
      _tabController = TabController(length: _graphs.length, vsync: this);
    });
  }

  Future<void> _saveCurrentGraph() async {
    if (_tabController.index >= 0 && _tabController.index < _graphs.length) {
      final currentGraph = _graphs[_tabController.index];
      final graphActions = GraphActions(
        graph: currentGraph,
        nodeTypes: _nodeTypes,
        onClearUndoStack: () {},
      );
      await graphActions.saveGraph();
    }
  }

  Future<void> _openGraph() async {
    final graphActions = GraphActions(
      graph: Graph(title: 'Untitled Graph'),
      nodeTypes: _nodeTypes,
      onClearUndoStack: () {},
    );
    final graph = await graphActions.openGraph();
    if (graph != null) {
      setState(() {
        _graphs.add(graph);
        _graphScreenKeys.add(GlobalKey<GraphScreenState>());
        _tabController.dispose();
        _tabController = TabController(length: _graphs.length, vsync: this);
        _tabController.animateTo(_graphs.length - 1);
      });
    }
  }

  GraphScreenState? _currentGraphScreenState() {
    if (_tabController.index >= 0 && _tabController.index < _graphScreenKeys.length) {
      return _graphScreenKeys[_tabController.index].currentState;
    }
    return null;
  }

  void _undo() {
    final graphScreenState = _currentGraphScreenState();
    if (graphScreenState != null) {
      graphScreenState.undo();
    }
  }

  void _redo() {
    final graphScreenState = _currentGraphScreenState();
    if (graphScreenState != null) {
      graphScreenState.redo();
    }
  }

  void _saveGraphAsPdf() {
    final graphScreenState = _currentGraphScreenState();
    if (graphScreenState != null) {
      graphScreenState.saveGraphAsPdf();
    }
  }

  void _selectNodeType(NodeType nodeType) {
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

  void _onUndoStackChanged(bool canUndoRedo) {
    setState(() {
      _canUndo = canUndoRedo;
      _canRedo = canUndoRedo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      selectedNodeType: _selectedNodeType,
      selectedEdgeType: _selectedEdgeType,
      onNodeTypeSelected: (nodeType) => _selectNodeType(nodeType!),
      onEdgeTypeSelected: (edgeType) => _selectEdgeType(edgeType!),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Dossier'),
          actions: [
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: _canUndo ? _undo : null,
              color: _canUndo ? Colors.white : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.redo),
              onPressed: _canRedo ? _redo : null,
              color: _canRedo ? Colors.white : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveCurrentGraph,
            ),
            IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: _saveGraphAsPdf,
            ),
            IconButton(
              icon: Icon(Icons.folder_open),
              onPressed: _openGraph,
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addNewGraph,
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: _showTransformerPreferencesDialog,
            ),

          ],
          bottom: _graphs.isNotEmpty
              ? TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: List.generate(_graphs.length, (index) {
                    return Tab(
                      child: Row(
                        children: [
                          Text(_graphs[index].title),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              _removeGraph(index);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
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
                children: _graphs.asMap().entries.map((entry) {
                  int index = entry.key;
                  Graph graph = entry.value;
                  return GraphScreen(
                    key: _graphScreenKeys[index],
                    preferences: _preferences,
                    initialGraph: graph,
                    nodeTypes: _nodeTypes,
                    edgeTypes: _edgeTypes,
                    onUndoStackChanged: _onUndoStackChanged,
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
