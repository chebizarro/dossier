import 'package:flutter_bloc/flutter_bloc.dart';
import 'graph_event.dart';
import 'graph_state.dart';
import 'graph.dart';

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  GraphBloc()
      : super(const GraphState(
          title: 'Untitled Graph',
          nodes: [],
          edges: [],
          showGraphView: true,
        )) {
    on<AddNode>((event, emit) {
      final nodes = List<Node>.from(state.nodes)..add(event.node);
      emit(state.copyWith(nodes: nodes));
    });

    on<RemoveNode>((event, emit) {
      final nodes = List<Node>.from(state.nodes)..remove(event.node);
      emit(state.copyWith(nodes: nodes));
    });

    on<AddEdge>((event, emit) {
      final edges = List<Edge>.from(state.edges)..add(event.edge);
      emit(state.copyWith(edges: edges));
    });

    on<RemoveEdge>((event, emit) {
      final edges = List<Edge>.from(state.edges)..remove(event.edge);
      emit(state.copyWith(edges: edges));
    });

    on<UpdateGraphTitle>((event, emit) {
      emit(state.copyWith(title: event.title));
    });

    on<ToggleGraphView>((event, emit) {
      emit(state.copyWith(showGraphView: !state.showGraphView));
    });
  }
}
