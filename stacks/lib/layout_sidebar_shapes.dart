import 'package:editor_base/custom_shape_painter.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme_notifier.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_design_painter.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({Key? key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'List of shapes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ShapeListWidget(),
          ],
        ),
      ),
    );
  }
}

class ShapeListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Acceder al AppData global
    AppData appData = Provider.of<AppData>(context);

    // Obtener la lista de formas
    List<Shape> shapesList = appData.shapesList;
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    return CupertinoScrollbar(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: shapesList.length,
        itemBuilder: (context, index) {
          final isSelected = appData.shapeSelected == index;

          // Crear una instancia de LayoutDesignPainter para cada forma
          LayoutDesignPainter layoutPainter = LayoutDesignPainter(
            appData: appData,
            theme: CDKTheme(), // Asegúrate de tener un tema válido aquí
            centerX: 0,
            centerY: 0,
          );

          return CupertinoButton(
            onPressed: () {
              if (isSelected) {
                // Si ya está seleccionado, deseleccionar
                appData.setShapeSelected(-1);
              } else {
                // Si no está seleccionado, seleccionar
                appData.setShapeSelected(index);
              }
            },
            padding: EdgeInsets.zero,
            child: Container(
              color: isSelected ? CupertinoColors.activeBlue : null,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shape ${index + 1}',
                        style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? CupertinoColors.white : null),
                      ),
                      // Sustituir el segundo Text con LayoutDesignPainter
                      CustomPaint(
                        painter: CustomShapePainter(
                          shape: appData.shapesList[index],
                          theme: theme,
                          centerX: 0,
                          centerY: 0,
                        ),
                        size: Size(
                            10, 10), // Ajusta el tamaño según sea necesario
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
