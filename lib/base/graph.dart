library spatially.base.graph;

import 'package:collection/wrappers.dart';
import 'package:quiver/core.dart';

part 'src/graph/directed_edge.dart';
part 'src/graph/edge.dart';
part 'src/graph/error.dart';
part 'src/graph/label.dart';
part 'src/graph/node.dart';

Iterable wherePresent(Iterable<Optional> optionals) =>
    optionals.expand((opt) => opt.isPresent ? [opt.value] : []);

typedef GraphNode NodeFactory<N,E>(Graph<N,E> graph, Label<N> label);
typedef GraphEdge EdgeFactory<N,E>(Graph<N,E> graph,
                                   Optional<Label<E>> fwdLabel,
                                   Optional<Label<E>> bwdLabel,
                                   GraphNode<N> startNode, GraphNode<N> endNode);

abstract class Graph<N,E> {
  Set<GraphEdge<E>> _edges;
  Set<GraphNode<N>> _nodes;

  NodeFactory<N,E> get nodeFactory;
  EdgeFactory<N,E> get edgeFactory;

  Graph() :
    _edges = new Set<GraphEdge<E>>(),
    _nodes = new Set<GraphNode<N>>();

  UnmodifiableSetView<GraphEdge<E>> get edges => new UnmodifiableSetView(_edges);
  UnmodifiableSetView<GraphNode<N>> get nodes => new UnmodifiableSetView(_nodes);

  Iterable<DirectedEdge<E>> get forwardEdges =>
      wherePresent(_edges.map((e) => e.forwardEdge));
  Iterable<DirectedEdge<E>> get backwardEdges =>
      wherePresent(_edges.map((e) => e.backwardEdge));

  /**
   * Tests whether the graph contains the node with the given label
   */
  bool containsNodeLabel(Label<N> nodeLabel) =>
      _nodes.any((n) => n.label == nodeLabel);

  bool containsNode(GraphNode<N> node) => nodes.contains(node);

  /**
   * Tests whether the graph contains a (forward or backward)
   * edge with the given label.
   */
  bool containsEdge(Label<E> edgeLabel) {
    var optLabel = new Optional.of(edgeLabel);
    return _edges.any((e) => e.forwardEdge == optLabel
                        || e.backwardEdge == optLabel);

  }

  Optional<GraphNode<N>> nodeByLabel(Label<N> nodeLabel) {
    return new Optional.fromNullable(
        _nodes.firstWhere((n) => n.label == nodeLabel, orElse: () => null));
  }
  /**
   * Add a new node to the graph, with the label set to [:nodeLabel:]
   *
   * If the node already exists, returns the existing node.
   * Otherwise returns the newly added node.
   */
  GraphNode<N> addNode(Label<N> nodeLabel) {
    var existing = nodeByLabel(nodeLabel);
    if (existing.isPresent) {
      return existing.value;
    }
    var added = nodeFactory(this, nodeLabel);
    _nodes.add(added);
    return added;
  }

  /**
   * Returns any edge which has the given label in the forward direction
   */
  Optional<DirectedEdge<E>> forwardEdgeByLabel(Label<E> label) {
    return new Optional.fromNullable(forwardEdges.firstWhere((e) => e.label == label, orElse: () => null));
  }

  /**
   * Returns any edge which has the given label in the backward direction
   */
  Optional<DirectedEdge<E>> backwardEdgeByLabel(Label<E> label) {
    return new Optional.fromNullable(backwardEdges.firstWhere((e) => e.label == label, orElse: () => null));
  }

  /**
   * Add a forward directed edge to the graph, with the label set to
   * [:edgeLabel:] *if* the label is unique amongst all the forward labels.
   *
   * The backward edge will be set to an absent value.
   *
   * Throws a [GraphError] if an edge already exists with the same label,
   * but with different start and/or end nodes.
   */
  GraphEdge<E> addForwardEdge(Label<E> edgeLabel, GraphNode<N> startNode, GraphNode<N> endNode) {
    var existing = forwardEdgeByLabel(edgeLabel);
    if (existing.isPresent) {

      _addCheckLabels(edgeLabel,
          existing.value.startNode, startNode,
          existing.value.endNode, endNode,
          isForward: true);

      return existing.value.edge;
    }
    addNode(startNode.label);
    addNode(endNode.label);
    var added = edgeFactory(this, new Optional.of(edgeLabel), new Optional.absent(), startNode, endNode);
    _edges.add(added);
    return added;
  }

  /**
   * Add a backward directed edge to the graph, with the label set to [:edgeLabel:].
   * *if* the label is unique amongst all the forward and backward labels.
   *
   * If the label is unique, the edge with the matching label will be returned,
   * otherwise returns the newly added edge.
   *
   * The forward directed edge will be set to an absent value.
   *
   * Throws a [GraphError] if the label exists in the graph, but with different
   * start and/or end nodes.
   *
   * NOTE: start and end node arguments are reversed from those from addForwardEdge
   * although this should be more intuitive.
   */
  GraphEdge<E> addBackwardEdge(Label<E> edgeLabel, GraphNode<N> endNode, GraphNode<N> startNode) {
    var existing = backwardEdgeByLabel(edgeLabel);
    if (existing.isPresent) {
      _addCheckLabels(edgeLabel,
          existing.value.startNode, startNode,
          existing.value.endNode, endNode,
          isForward: false);
      return existing.value.edge;
    }
    addNode(startNode.label);
    addNode(endNode.label);
    var added = edgeFactory(this, new Optional.absent(), new Optional.of(edgeLabel), endNode, startNode);
    _edges.add(added);
    return added;
  }

  /**
   * Adds an undirected edge to the graph if there are no edges already
   * existing with the given labels.
   *
   * If the labels are not unique, then the edge with the existing label
   * is returned.
   *
   * Throws a [GraphError] if either the forward or backward label
   * exist in the graph but with different start/or end nodes
   *
   * NOTE: `startNode` is the start node of what will become the forward edge.
   * Thus the `startNode` becomes the `endNode` of the backward edge (and vice versa)
   */
  GraphEdge<E> addUndirectedEdge(Label<E> forwardLabel, Label<E> backwardLabel, GraphNode<N> startNode, GraphNode<N> endNode) {
    var fwdExists = forwardEdgeByLabel(forwardLabel);
    if (fwdExists.isPresent) {
      _addCheckLabels(forwardLabel,
                      fwdExists.value.startNode, startNode,
                      fwdExists.value.endNode, endNode,
                      isForward: true);
      //TODO: Add the forward edge if the existing edge is not undirected?
      return fwdExists.value.edge;
    }
    var bwdExists = backwardEdgeByLabel(backwardLabel);
    if (bwdExists.isPresent) {
      _addCheckLabels(backwardLabel,
                      bwdExists.value.startNode, endNode,
                      bwdExists.value.endNode, startNode, //backward label reversed
                      isForward: false);

      return bwdExists.value.edge;
    }
    addNode(startNode.label);
    addNode(endNode.label);
    var edge = edgeFactory(this,
                           new Optional.of(forwardLabel) ,
                           new Optional.of(backwardLabel),
                           startNode,
                           endNode);
    _edges.add(edge);
    return edge;
  }

  bool _removeIsolatedEdges() {
    _edges.removeWhere((e) => !e.forwardEdge.isPresent
                           && !e.backwardEdge.isPresent);
    return true;
  }

  /**
   * Removes the node with the given label (if one exists).
   * Throws a [StateError] if attempting to remove a node when
   * there are edges in the graph which terminate at the node.
   */
  void removeNode(Label<N> nodeLabel) {
    var node = nodeByLabel(nodeLabel);
    node.ifPresent((node) {
      if (node.terminatingEdges.isNotEmpty)
        throw new StateError("Node has terminating edges");
      _nodes.remove(node);
      node._unlink();
    });
  }

  /**
   * Removes the forward edge from the graph, without touching the corresponding
   * backward edge. If there is no complementary edge, the undirected edge is
   * removed from the graph.
   *
   * Returns `true` if an edge was removed from the graph.
   */
  bool removeForwardEdge(Label<E> forwardLabel) {
    Optional<DirectedEdge<E>> fwdEdge = forwardEdgeByLabel(forwardLabel);
    var removedFwd = fwdEdge.transform((e) => e.edge._removeForward());
    return removedFwd.or(false);
  }

  bool removeBackwardEdge(Label<E> backwardLabel) {
    Optional<DirectedEdge<E>> bwdEdge = backwardEdgeByLabel(backwardLabel);
    var removedBwd = bwdEdge.transform((e) => e.edge._removeBackward());
    return removedBwd.or(false);
  }

  bool removeEdge(GraphEdge<E> edge) {
    bool removed = false;
    edge.forwardLabel.ifPresent((lbl) {
      removed = removeForwardEdge(lbl);
    });
    edge.backwardLabel.ifPresent((lbl) {
      removed = removeBackwardEdge(lbl);
    });
    return removed;
  }
}


