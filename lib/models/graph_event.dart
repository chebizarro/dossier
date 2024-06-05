import 'package:equatable/equatable.dart';
import 'graph.dart';

abstract class GraphEvent extends Equatable {
  const GraphEvent();

  @override
  List<Object> get props => [];
}

class AddNode extends GraphEvent {
  final Node node;

  const AddNode(this.node);

  @override
  List<Object> get props => [node];
}

class RemoveNode extends GraphEvent {
  final Node node;

  const RemoveNode(this.node);

  @override
  List<Object> get props => [node];
}

class AddEdge extends GraphEvent {
  final Edge edge;

  const AddEdge(this.edge);

  @override
  List<Object> get props => [edge];
}

class RemoveEdge extends GraphEvent {
  final Edge edge;

  const RemoveEdge(this.edge);

  @override
  List<Object> get props => [edge];
}

class UpdateGraphTitle extends GraphEvent {
  final String title;

  const UpdateGraphTitle(this.title);

  @override
  List<Object> get props => [title];
}

class ToggleGraphView extends GraphEvent {}
