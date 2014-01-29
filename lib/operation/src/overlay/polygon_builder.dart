//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.

part of spatially.operation.overlay;


class _PolygonBuilder extends _OverlayBuilder {
  _PolygonBuilder(graph, overlayType) : super._(graph, overlayType);

  Geometry build() {
    // TODO: implement build
  }

  Ring _maximalEdgeRing(GeometryGraph graph) {
    for (var edge in graph.edges.toList(growable:false)) {
      var onLocations = edge.locations.map((l) => l.on);
      if (!_inOverlay(onLocations)) {
        graph.removeEdge(edge);
      }
    }
  }
}