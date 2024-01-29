import 'dart:math';

import 'package:flutter/cupertino.dart';

class Shape {
  Offset position = const Offset(0, 0);
  List<Offset> vertices = [];
  double strokeWidth = 1;
  Color strokeColor = const Color(0xFF000000);

  Shape();

  Color getColor() {
    return strokeColor;
  }

  void setPositionX(double x) {
    position = Offset(x, position.dy);
  }

  void setPositionY(double y) {
    position = Offset(position.dx, y);
  }

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
  }

  Size getBoundingBoxSize() {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (Offset vertex in vertices) {
      minX = min(minX, vertex.dx);
      minY = min(minY, vertex.dy);
      maxX = max(maxX, vertex.dx);
      maxY = max(maxY, vertex.dy);
    }

    double width = maxX - minX;
    double height = maxY - minY;

    return Size(width, height);
  }

  double getCanvasOccupiedSize(Size canvasSize) {
    Size boundingBoxSize = getBoundingBoxSize();

    // Define un tamaño de referencia constante
    double referenceSize = 100.0;

    // Calcula el tamaño ocupado en el canvas en relación con el tamaño de referencia
    double canvasOccupiedSize =
        (boundingBoxSize.width * boundingBoxSize.height) /
            (referenceSize * referenceSize);

    return canvasOccupiedSize;
  }

  void normalizeSize(Size canvasSize) {
    Size boundingBoxSize = getBoundingBoxSize();

    // Verifica si la bounding box tiene dimensiones no nulas
    if (boundingBoxSize.width > 0 && boundingBoxSize.height > 0) {
      // Define el tamaño deseado en el canvas
      double desiredWidth = canvasSize.width / 2;
      double desiredHeight = canvasSize.height / 2;

      // Calcula los factores de escala necesarios para normalizar el tamaño
      double scaleX = desiredWidth / boundingBoxSize.width;
      double scaleY = desiredHeight / boundingBoxSize.height;

      // Aplica la transformación de escala a cada vértice y la posición
      for (int i = 0; i < vertices.length; i++) {
        vertices[i] = Offset(vertices[i].dx * scaleX, vertices[i].dy * scaleY);
      }

      position = Offset(position.dx * scaleX, position.dy * scaleY);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': 'shape_drawing',
      'object': {
        'position': {'dx': position.dx, 'dy': position.dy},
        'vertices': vertices.map((v) => {'dx': v.dx, 'dy': v.dy}).toList(),
        'strokeWidth': strokeWidth,
        'strokeColor': strokeColor.value,
// Guarda el color com un valor enter
      }
    };
  }

  static Shape fromMap(Map<String, dynamic> map) {
    if (map['type'] != 'shape_drawing') {
      throw Exception('Type is not a shape_drawing');
    }

    var objectMap = map['object'] as Map<String, dynamic>;
    var shape = Shape()
      ..setPosition(
          Offset(objectMap['position']['dx'], objectMap['position']['dy']))
      ..setStrokeWidth(objectMap['strokeWidth'])
      ..setStrokeColor(Color(objectMap['strokeColor']));

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }

    return shape;
  }

  void setStrokeColor(Color color) {
    strokeColor = color;
  }
}
