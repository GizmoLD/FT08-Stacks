import 'dart:convert';
import 'dart:io';
import 'package:editor_base/shape_set.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'app_click_selector.dart';
import 'app_data_actions.dart';
import 'util_shape.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)
  bool closeShape = false;
  ActionManager actionManager = ActionManager();
  bool isAltOptionKeyPressed = false;
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = Shape();
  Shape copyShape = Shape();
  ValueNotifier<Color> valueShapeColorNotifier = ValueNotifier(CDKTheme.black);
  ValueNotifier<Color> valuebackgroundColorNotifier =
      ValueNotifier(CDKTheme.transparent);

  List<Shape> shapesList = [];
  int shapeSelected = -1;
  int shapeSelectedPrevious = -1;

  bool readyExample = false;
  late dynamic dataExample;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void setZoom(double value) {
    zoom = value.clamp(25, 500);
    notifyListeners();
  }

  void setZoomNormalized(double value) {
    if (value < 0 || value > 1) {
      throw Exception(
          "AppData setZoomNormalized: value must be between 0 and 1");
    }
    if (value < 0.5) {
      double min = 25;
      zoom = zoom = ((value * (100 - min)) / 0.5) + min;
    } else {
      double normalizedValue = (value - 0.51) / (1 - 0.51);
      zoom = normalizedValue * 400 + 100;
    }
    notifyListeners();
  }

  double getZoomNormalized() {
    if (zoom < 100) {
      double min = 25;
      double normalized = (((zoom - min) * 0.5) / (100 - min));
      return normalized;
    } else {
      double normalizedValue = (zoom - 100) / 400;
      return normalizedValue * (1 - 0.51) + 0.51;
    }
  }

  void setDocWidth(double value) {
    double previousWidth = docSize.width;
    actionManager.register(ActionSetDocWidth(this, previousWidth, value));
  }

  void setDocHeight(double value) {
    double previousHeight = docSize.height;
    actionManager.register(ActionSetDocHeight(this, previousHeight, value));
  }

  void setToolSelected(String name) {
    toolSelected = name;
    notifyListeners();
  }

  void setShapeSelected(int index) {
    shapeSelected = index;
    notifyListeners();
  }

// antes solo era void
  Future<void> selectShapeAtPosition(Offset docPosition, Offset localPosition,
      BoxConstraints constraints, Offset center) async {
    //
    //shapeSelectedPrevious = shapeSelected;
    //shapeSelected = -1;
    //
    setShapeSelected(await AppClickSelector.selectShapeAtPosition(
        this, docPosition, localPosition, constraints, center));
  }

  void addNewShape(Offset position) {
    newShape.strokeColor = valueShapeColorNotifier.value;
    newShape.setPosition(position);
    newShape.addPoint(const Offset(0, 0));
    newShape.setClosed(closeShape);
    notifyListeners();
  }

  void addRelativePointToNewShape(Offset point) {
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.vertices.length >= 2) {
      double strokeWidthConfig = newShape.strokeWidth;
      actionManager.register(ActionAddNewShape(this, newShape));
      newShape = Shape();
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    notifyListeners();
  }

  void setShapeColor(Color color) {
    if (shapeSelected >= 0 && shapeSelected < shapesList.length) {
      actionManager.register(ActionSetShapeColor(
          this,
          shapesList[shapeSelected],
          shapesList[shapeSelected].getColor(),
          color));
      shapesList[shapeSelected].strokeColor = color;
      notifyListeners();
    }
  }

  Color getSelectedShapeColor() {
    if (shapeSelected >= 0 && shapeSelected < shapesList.length) {
      return shapesList[shapeSelected].strokeColor;
    } else {
      return Colors.transparent;
    }
  }

  Shape? getSelectedShape() {
    if (shapeSelected >= 0 && shapeSelected < shapesList.length) {
      return shapesList[shapeSelected];
    }
    return null;
  }

  void setBackgroundColor() {
    notifyListeners();
  }

  void setSelectedShapePositionX(double x) {
    if (shapeSelected != -1) {
      getSelectedShape()?.setPositionX(x);
      notifyListeners();
    }
  }

  void setSelectedShapePositionY(double y) {
    if (shapeSelected != -1) {
      getSelectedShape()?.setPositionY(y);
      notifyListeners();
    }
  }

  void setSelectedShapePosition(Offset position) {
    if (shapeSelected != -1) {
      actionManager.register(ActionSetPositionShape(
          this,
          shapesList[shapeSelected],
          shapesList[shapeSelected].position,
          position));
      notifyListeners();
    }
  }

  void updateShapePosition(Offset position) {
    if (shapeSelected != -1) {
      getSelectedShape()?.setPosition(position);
      notifyListeners();
    }
  }

  void copyToClipboard() {
    if (shapeSelected != -1) {
      copyShape = shapesList[shapeSelected];
      Clipboard.setData(ClipboardData(text: copyShape.toMap().toString()));
    }
  }

  void pasteFromClipboard() {
    if (copyShape.vertices.length > 0) {
      Shape shape = Shape.fromMap(copyShape.toMap());
      shape.setPosition(shape.position + const Offset(10, 10));
      actionManager.register(ActionAddNewShape(this, shape));
    }
  }

  void deleteSelectedShape() {
    if (shapeSelected != -1) {
      actionManager.register(
          ActionDeleteShape(this, shapesList[shapeSelected], shapeSelected));
      shapesList.removeAt(shapeSelected);
      shapeSelected = -1;
      notifyListeners();
    }
  }

  void setCloseShape(bool value) {
    closeShape = value;
    if (shapeSelected > -1) {
      shapesList[shapeSelected].closed = value;
      //actionManager.register(ActionChangeClosed(this, shapeSelected, value));
    }
    notifyListeners();
  }

  void saveFile() async {
    final directorio = await getApplicationDocumentsDirectory();
    final rutaArchivo = '${directorio.path}/FT08-STACKS/mi_archivo.json';

    // Crear una lista para almacenar los resultados de toMap().toString()
    List<String> shapeStrings = [];

    // Obtener las representaciones de cadena para cada Shape
    for (Shape shape in shapesList) {
      shapeStrings.add(shape.toMap().toString());
    }

    // Escribir las representaciones de cadena en el archivo
    final File archivo = File(rutaArchivo);
    await archivo.writeAsString(shapeStrings.join('\n'));
    print('Datos guardados con éxito en: ${archivo.path}');
  }

  void exportAsSVG() async {
    // Crear una instancia de ShapeSet con la lista actual de shapes
    ShapeSet shapeSet = ShapeSet(shapesList);

    // Obtener el código SVG como una cadena
    String svgContent = shapeSet.toSVGString(docSize);

    // Obtener el directorio de documentos de la aplicación
    final directory = await getApplicationDocumentsDirectory();

    // Crear la ruta completa del archivo SVG
    final filePath = '${directory.path}/FT08-STACKS/mi_archivo.svg';

    // Escribir el código SVG en el archivo
    await File(filePath).writeAsString(svgContent);

    print('Archivo SVG exportado con éxito en: $filePath');
  }
}
