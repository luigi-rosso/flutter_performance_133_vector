import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/animation.dart';

import 'animated_procedural_shape.dart';

class ExampleRenderer extends ProceduralShapeRenderer {
  final Path path = Path();
  final Paint paintOuter = Paint()
    ..color = const Color.fromRGBO(0, 155, 255, 1.0);
  final Paint paintStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.02
    ..color = const Color.fromRGBO(0, 0, 0, 1.0);
  final Paint paintInner = Paint()
    ..color = const Color.fromRGBO(255, 255, 255, 1.0);
  double interpolation = 0;

  static Float32List circle = Float32List.fromList([
    0.5,
    0.0,
    0.5 + 0.5 * 0.55,
    0.0,
    1.0,
    0.5 - 0.5 * 0.55,
    1.0,
    0.5,
    1.0,
    0.5 + 0.5 * 0.55,
    0.5 + 0.5 * 0.55,
    1.0,
    0.5,
    1.0,
    0.5 - 0.5 * 0.55,
    1.0,
    0.0,
    0.5 + 0.5 * 0.55,
    0.0,
    0.5,
    0.0,
    0.5 - 0.5 * 0.55,
    0.5 - 0.5 * 0.55,
    0.0,
    0.5,
    0.0,
  ]);

  static Float32List square = Float32List.fromList([
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
    0.0
  ]);

  static Float32List triangle = Float32List.fromList([
    0.5,
    0.0,
    0.5,
    0.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    0.5,
    1.0,
    0.5,
    1.0,
    0.5,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.0,
    1.0,
    0.5,
    0.0,
    0.5,
    0.0
  ]);

  static List<Float32List> shapes = [
    square,
    square,
    triangle,
    triangle,
    circle,
    circle,
  ];

  Float32List renderShape = Float32List(square.length);

  @override
  void advance(double elapsed) {
    interpolation += elapsed * 2.0;

    int shapeIndex = interpolation.floor();
    Float32List from = shapes[shapeIndex % shapes.length];
    Float32List to = shapes[(shapeIndex + 1) % shapes.length];
    // Interpolate
    double f = Curves.easeInOut.transform(interpolation % 1);
    double fi = 1 - f;
    for (int i = 0; i < renderShape.length; i++) {
      renderShape[i] = from[i] * fi + to[i] * f;
    }

    // Update path
    path.reset();
    path.moveTo(renderShape[0], renderShape[1]);
    for (int i = 2; i < renderShape.length; i += 6) {
      path.cubicTo(renderShape[i], renderShape[i + 1], renderShape[i + 2],
          renderShape[i + 3], renderShape[i + 4], renderShape[i + 5]);
    }
    path.close();
  }

  @override
  void render(Size size, Offset offset, Canvas canvas) {
    // bump this value to try more render ops
    int complexity = 1;

    double scale = 1.33333333333;
    for (int i = 0; i < complexity; i++) {
      scale *= 0.75;
      canvas.save();
      canvas.translate(offset.dx + (size.width * (1.0 - scale)) / 2.0,
          offset.dy + (size.height * (1.0 - scale)) / 2.0);
      canvas.scale(size.width * scale, size.height * scale);
      canvas.drawPath(path, paintOuter);
      canvas.drawPath(path, paintStroke);
      canvas.restore();

      scale *= 0.75;
      canvas.save();
      canvas.translate(offset.dx + (size.width * (1.0 - scale)) / 2.0,
          offset.dy + (size.height * (1.0 - scale)) / 2.0);
      canvas.scale(size.width * scale, size.height * scale);
      canvas.drawPath(path, paintInner);
      canvas.drawPath(path, paintStroke);
      canvas.restore();
    }
  }
}
