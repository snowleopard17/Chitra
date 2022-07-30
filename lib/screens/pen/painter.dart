import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class painter extends CustomPainter {
  final List<Offset> offsets;
  bool draw;
  painter(this.offsets, this.draw) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..isAntiAlias = true
      ..strokeWidth = 6.0;
    for (var i = 0; i < offsets.length; i++) {
      canvas.drawPoints(PointMode.points, [offsets[i]], paint);
    }
    if (draw) {
      joinLines(canvas, size, paint);
    }
  }

  @override
  void joinLines(Canvas canvas, Size size, paint) {
    print(size);
    for (var i = 0; i < offsets.length - 1; i++) {
      canvas.drawLine(offsets[i], offsets[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(painter delegate) {
    return true;
  }
}
