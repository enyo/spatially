library geometry;

import 'dart:math' as math;
import 'dart:collection';

//import 'package:meta/meta.dart';
import 'package:range/range.dart';

//import 'package:tuple/tuple.dart';
import 'utils.dart' as utils;
import 'algorithms.dart' as alg;

part 'src/geometry/bounds.dart';
part 'src/geometry/geometry_collection.dart';
part 'src/geometry/geometry_list.dart';
part 'src/geometry/line_segment.dart';
part 'src/geometry/linestring.dart';
part 'src/geometry/point.dart';
part 'src/geometry/polygon.dart';
part 'src/geometry/ring.dart';
part 'src/geometry/tessel.dart';

part 'src/geometry/multi_point.dart';
part 'src/geometry/multi_linestring.dart';
part 'src/geometry/multi_polygon.dart';

abstract class Geometry {
  
  const Geometry();
  
  /**
   * The minimum [Bounds] object which entirely contains
   * the [Geometry]
   */
  Bounds       get bounds;
  
  /**
   * The minimum distance to the given geometry in coordinate space.
   */
  double distanceTo(Geometry geom);
  
  /**
   * The real-world distance to the given geometry
   */
  // double geodesicDistanceTo(Geometry other);
  
  /**
   * Translate the geometry through the given latitude and longitude
   */
  Geometry translate({dx: 0.0, dy: 0.0});
  
  /**
   * Rotate the geometry through [:amount:] radians about the given [:origin:]
   * If [:origin:] is `null` or not provided, the [:centroid:] of the [Geometry]
   * will be used.
   */
  Geometry rotate(double amount, {Point origin: null});
  
  /**
   * Scale the geometry through a given [:ratio:] relative to the specified [:origin:]
   * If [:origin:] is `null` or not provided, the [:centroid:] of the [Geometry]
   * will be used.
   */
  Geometry scale(double ratio, {Point origin: null});
  
  Point get centroid;
  
  /**
   * The geometry enclosing precisely those points which are
   * enclosed by `this` and enclosed by `geom`.
   * 
   * The possible return types differ between implementations.
   * Check the documentation for the geometry type for further information
   */
  Geometry intersection(Geometry geom);
  Geometry operator &(Geometry geom) => intersection(geom);

  /**
   * The geometry containing precisely the points that are 
   * enclosed by `this` or enclosed by `geom`.
   * 
   * The possible return types differ between implementations
   * Check the documentation for the geometry type for further information
   */
  Geometry union(Geometry geom);
  Geometry operator |(Geometry geom) => union(geom);
  
  /**
   * The geometry containing precisely the points which are 
   * enclosed by `this` and disjoint from [:geom:].
   * 
   * The possible return types differ between implementations.
   * Check the documentation for the geometry type for further information
   */
  Geometry difference(Geometry geom);
  Geometry operator -(Geometry geom) => difference(geom);

  //Relations
  /**
   * Do the [:bounds:] of this intersect the [:bounds:] of [:geom:]? 
   */
  bool boundsIntersects(Geometry geom) => bounds.intersects(geom.bounds);
  /**
   * Does `this` have a non-zero spatial overlap with [:geom:]?
   */
  bool intersects(Geometry geom);
  /**
   * Does `this` have a zero spatial overlap with [:geom:]?
   */
  bool disjoint(Geometry geom) => !intersects(geom);
  /**
   * `true` iff [:geom:] is completely inside `this`
   */
  bool encloses(Geometry geom);
  /**
   * `true` if `this` completely encloses [:geom:]
   */
  bool enclosedBy(Geometry geom)  => geom.encloses(this);
  /**
   * `true` if `this` and `geom` touch at an edge or endpoint
   */
  bool touches(Geometry geom);
  
  /**
   * Returns a simplified geometry. What this method actually does is dependent
   * on the type of the geometry. Check the documentation for the Geometry type
   * for more information.
   */
  Geometry simplify({double tolerance: 1e-15});
  
}

abstract class Nodal extends Geometry {
  /**
   * The [Nodal] geometry as a [Point]
   */
  Point toPoint();
}

abstract class Linear extends Geometry {
  //double get geodesicSpan;
  
  Point get start;
  Point get end;
  
  /**
   * The unitless length of the [Geometry] in the coordinate system
   */
  double get span;
  
  /**
   * The linear geometry as a linestring
   */
  Linestring toLinestring();
  
  /**
   * The linear geometry, reversed spatially
   */
  Linear get reversed;
  
  /**
   * Append a [:node:] to the line, without modifying the result.
   */
  Linestring append(Nodal node);
  /**
   * Concatenates a [Linear] geometry onto the end of this geometry
   * Raises an [InvalidGeometry] if the start point of the line is not
   * equal to the endpoint of the linestring.
   * 
   * If [:tolerance:] is given, the argument's start can be a maximum of [:tolerance:] units 
   * away from the endpoint when matching against `this.end`. 
   * If the endpoints are seperated by a distance less than [:tolerance:], 
   * `this.end` will be used as the connecting point.
   * 
   * If [:reverse:] is `true`, then [:line:] may be reversed in an attempt
   * to ensure that it remains adjacent to the endpoint.
   */
  Linestring concat(Linear line, {bool reverse: false});
}

abstract class Planar extends Geometry {
  
  //double get geodesicArea;
  
  /**
   * The unitless area of the [Geometry] in the coordinate system
   */
  double get area;
  
  /**
   * The line encircling the [Planar] geometry. 
   */
  Linestring get boundary;
  
  Polygon toPolygon();
  
  /**
   * Rotates the boundary of the geometry so the [:i:]th vertex is at
   * position `0`.
   * If [:i:] is not provided, defaults to `1`.
   */
  Planar permute([int i = 1]);
  
  /**
   * Splits the [Planar] into a set of [Tessel]s, which partition the [Planar] geometry.
   */
  Set<Tessel> tesselate();
  
}

abstract class MultiGeometry<T> {
  
}

class InvalidGeometry implements Exception {
  final String msg;
  InvalidGeometry(String this.msg);
  
  String toString() => "Invalid Geometry: $msg";
}