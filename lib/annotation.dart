import 'dart:ui';

class Annotation {
  Offset point1;
  Offset point2;
  int label;
  Annotation(p1, p2, label) {
    this.point1 = p1;
    this.point2 = p2;
    this.label = label;
  }
}