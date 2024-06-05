import 'package:equatable/equatable.dart';
import 'graph.dart';

class GraphState extends Equatable {
  final String title;
  final List<Node> nodes;
  final List<Edge> edges;
  final bool showGraphView;

  const GraphState({
    required this.title,
    required this.nodes,
    required this.edges,
    required this.showGraphView,
  });

  GraphState copyWith({
    String? title,
    List<Node>? nodes,
    List<Edge>? edges,
    bool? showGraphView,
  }) {
    return GraphState(
      title: title ?? this.title,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      showGraphView: showGraphView ?? this.showGraphView,
    );
  }

  @override
  List<Object> get props => [title, nodes, edges, showGraphView];
}
