import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';

class CustomShapePainter extends CustomPainter {
  final Shape shape;
  final CDKTheme theme;
  final double centerX;
  final double centerY;

  CustomShapePainter({
    required this.shape,
    required this.theme,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define el tamaño máximo del área del Canvas

    double maxWidth = 2;
    double maxHeight = 2;

    // Calcula el centro absoluto en base al tamaño máximo del área del Canvas
    double absoluteCenterX = (size.width > maxWidth)
        ? maxWidth / 2 + centerX
        : size.width / 2 + centerX;
    double absoluteCenterY = (size.height > maxHeight)
        ? maxHeight / 2 + centerY
        : size.height / 2 + centerY;

    // Calcula las escalas necesarias en los ejes x e y
    double scaleX = maxWidth / size.width;
    double scaleY = maxHeight / size.height;

    // Aplica la transformación de escala
    //canvas.scale(scaleX, scaleY);
    canvas.scale(scaleX, scaleY);

    // Configura el pintor según el tema y otras propiedades
    Paint paint = Paint()
      ..color = theme.colorText
      ..style = PaintingStyle.stroke
      ..strokeWidth = shape.strokeWidth;

    // Dibuja el shape centrado en el área del Canvas
    Path path = Path();
    path.moveTo(absoluteCenterX + shape.vertices[0].dx,
        absoluteCenterY + shape.vertices[0].dy);
    for (int i = 1; i < shape.vertices.length; i++) {
      path.lineTo(absoluteCenterX + shape.vertices[i].dx,
          absoluteCenterY + shape.vertices[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Puedes ajustar esto según sea necesario
  }
}
