import 'dart:math';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

class ShapeSet {
  List<Shape> shapes;

  ShapeSet(this.shapes);
  String toSVGString(Size canvasSize) {
    final builder = xml.XmlBuilder();
    builder.processing("xml", "version='1.0' encoding='UTF-8'");
    builder.doctype('html');
    builder.element('html', nest: () {
      builder.element('body', nest: () {
        builder.element('svg', attributes: {
          'width': canvasSize.width.toString(),
          'height': canvasSize.height.toString(),
          'xmlns': 'http://www.w3.org/2000/svg',
        }, nest: () {
          for (var shape in shapes) {
            builder.element('path', attributes: {
              //'cx': shape.position.dx.toString(),
              //'cy': shape.position.dy.toString(),
              'd': shape.toSvgPath(),
              'stroke':
                  '#' + shape.strokeColor.value.toRadixString(16).substring(2),
              'stroke-width': shape.strokeWidth.toString(),
              'fill': 'none',
            });
          }
        });
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }
}
