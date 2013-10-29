library test_linesegment;

import 'package:unittest/unittest.dart';

import 'package:layers/geometry.dart';

import 'std_tests.dart';

void main() {
  var lseg = new LineSegment(
      new Point(x: 0.0, y: 1.0),
      new Point(x: 1.0, y: 0.0));
  runStandardTests("LineSegment", lseg);
  testEncloses();
  testIntersection();
  testComparePoint();
  testTouches();
}

void testIntersection() {
  var lseg1 = new LineSegment(
      new Point(y: 0.0, x: 0.0),
      new Point(y: 1.0, x: 1.0));
  var lseg2 = new LineSegment(
      new Point(y: 1.0, x: 0.0),
      new Point(y: 0.0, x: 1.0));
  test("test_linesegment: $lseg1 intersects $lseg2",
      () => expect(lseg1.intersection(lseg2), 
                   geometryEquals(new Point(y: 0.5, x: 0.5), 1e-15)));
      
  var lseg3 = new LineSegment(
      new Point(y: 2.0, x: 2.0),
      new Point(y: 3.0, x: 3.0));
  test("test_linesegment: $lseg1 does not intersect $lseg3",
      () => expect(lseg1.intersection(lseg3), isNull));
  
  var lseg4 = new LineSegment(
      new Point(y: 0.00000000000000001, x: 0.0),
      new Point(y: 0.75, x: 0.75));
  var intersectionSegment = 
      new LineSegment(new Point(y: 0.0, x: 0.0), 
                      new Point(y: 0.75, x: 0.75));
  test("test_linesegment: $lseg1 intersects $lseg4",
      () => expect(lseg1.intersection(lseg4),
                   geometryEquals(intersectionSegment, 1e-15)));
  
  var lseg5 = new LineSegment(new Point(x: 2.0, y: 2.0), new Point(x: 2.0, y: 3.0));
  var lseg6 = new LineSegment(new Point(x: 2.0, y: 4.0), new Point(x: 4.0, y: 3.0));
  test("test_linesegment: $lseg5 does not intersect $lseg6",
      () => expect(lseg5.intersection(lseg6), isNull));
  
  var lseg7 = new LineSegment(new Point(x: 2.0, y: 2.0), new Point(x: 2.0, y: 2.0));
  var lseg8 = new LineSegment(new Point(x: 0.0, y: 4.0), new Point(x: 4.0, y: 0.0));

  //Technically this should be invalid data, but we need to support it anyway.
  test("test_linesegment: intersection with empty linestring",
      () => expect(lseg8.intersection(lseg7),
                   geometryEquals(new Point(x: 2.0, y: 2.0), 1e-15)));
}

void testEncloses() {
  var lseg1 = new LineSegment(
      new Point(y: 0.0, x: 0.0),
      new Point(y: 1.0, x: 1.0));
  var p1    = new Point(y: 0.5, x: 0.5);
  test("test_linesegment: $lseg1 encloses $p1",
      () => expect(lseg1.encloses(p1), isTrue));
  var p2    = new Point(y: 2.0, x: 2.0);
  test("test_linesegment: $lseg1 does not enclose $p2",
      () => expect(lseg1.encloses(p2), isFalse));
 
  var lseg2 = new LineSegment(
      new Point(y: 0.25,x : 0.25),
      new Point(y: 0.75,x : 0.75));
  test("test_linesemgnet: $lseg1 encloses $lseg2",
      () => expect(lseg1.encloses(lseg2), isTrue));
  var lseg3 = new LineSegment(
      new Point(x: 0.25, y: 0.25),
      new Point(x: 1.25, y:1.25));
  test("test_linesegment: $lseg1 does not enclose $lseg2",
      () => expect(lseg1.encloses(lseg3), isFalse));

  
}

void testTouches() {
  final lseg1 = new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0));
  
  final p1 = new Point(x: 0.0, y: 0.0);
  final p2 = new Point(x: 0.5, y: 0.5);
  test("test_linesegment: $lseg1 touches $p1",
      () => expect(lseg1.touches(p1), isTrue));
  test("test_linesegment: $lseg1 does not touch $p2",
      () => expect(lseg1.touches(p2), isFalse));
  
  final lseg2 = new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 0.5, y: 0.5));
  final lseg3 = new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 0.0, y: 1.0));
  
  test("test_linesegment: $lseg1 touches $lseg2",
      () => expect(lseg1.touches(lseg2), isTrue));
  test("test_linesemgnet: $lseg1 does not touch $lseg3",
      () => expect(lseg1.touches(lseg3), isFalse));
  
  final lstr1 = new Linestring([new Point(x: 1.0, y: 1.0), new Point(x: 1.0, y: 0.0)]);
  final lstr2 = new Linestring([new Point(x: 2.0, y: 2.0), new Point(x: 1.0, y: 1.0), new Point(x: 1.0, y: 0.0)]);
  test("test_linesegment: $lseg1 touches $lstr1",
      () => expect(lseg1.touches(lstr1), isTrue));
  test("test_linesegment: $lseg1 does not touch $lstr2",
      () => expect(lseg1.touches(lstr2), isFalse));
  
  final tesl1 = new Tessel(new Point(x: -1.0, y: -1.0), new Point(x:-1.0, y:1.0), new Point(x: 1.0, y: -1.0));
  final tesl2 = new Tessel(new Point(x: -1.0, y: -1.0), new Point(x:-1.0, y: 2.2), new Point(x: 2.0, y: -1.0));
  final tesl3 = new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 2.0, y: 0.0), new Point(x: 0.0, y: 2.0));
  final tesl4 = new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0), new Point(x: 1.0, y: 0.0));
  test("test_linesemgnet: $lseg1 touches $tesl1",
      () => expect(lseg1.touches(tesl1), isTrue));
  test("test_linesegment: $lseg1 does not touch $tesl2",
      () => expect(lseg1.touches(tesl2), isFalse));
  test("test_linesegment: $lseg1 does not touch $tesl3 as it encloses the linesegment",
      () => expect(lseg1.touches(tesl3), isFalse));
  test("test_linesegment: $lseg1 touches $tesl4 along an edge",
      () => expect(lseg1.touches(tesl4), isTrue));
}

void testComparePoint() {
  var lseg1 = new LineSegment(
      new Point(y: 0.0, x: 0.0),
      new Point(y: 1.0, x: 1.0));
  var p1 = new Point(y: 1.5, x: 0.5);
  test("test_linesegment: $p1 is to the right of $lseg1",
      () => expect(lseg1.compareToPoint(p1), equals(1)));
  var p2 = new Point(y: 0.5, x: 0.5);
  test("test_linesegment: $p2 is on $lseg1",
      () => expect(lseg1.compareToPoint(p2), equals(0)));
  var p3 = new Point(y: 0.0, x: 1.0);
  test("test_linesegment: $p3 is to the left of $lseg1",
      () => expect(lseg1.compareToPoint(p3), equals(-1)));  
  
  var lseg2 = new LineSegment(
      new Point(y: 1.0, x: 1.0),
      new Point(y: 0.0, x: 0.0));
  test("test_linesegment: $p1 is to the left of $lseg2",
      () => expect(lseg2.compareToPoint(p1), equals(-1)));
}