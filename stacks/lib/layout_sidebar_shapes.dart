import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme_notifier.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'custom_shape_painter.dart';

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
    final appData = Provider.of<AppData>(context);
    final shapesList = appData.shapesList;
    final theme = CDKThemeNotifier.of(context)!.changeNotifier;

    return CupertinoScrollbar(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: shapesList.length,
        itemBuilder: (context, index) {
          return buildShapeItem(context, index, appData, theme);
        },
      ),
    );
  }

  Widget buildShapeItem(
    BuildContext context,
    int index,
    AppData appData,
    CDKTheme theme,
  ) {
    final isSelected = appData.shapeSelected == index;
    //final layoutPainter = LayoutDesignPainter(
    //  appData: appData,
    //  theme: CDKTheme(),
    //  centerX: 0,
    //  centerY: 0,
    //);

    return CupertinoButton(
      onPressed: () => toggleShapeSelection(appData, index),
      padding: EdgeInsets.zero,
      child: buildShapeContainer(index, isSelected, appData, theme),
    );
  }

  Widget buildShapeContainer(
    int index,
    bool isSelected,
    AppData appData,
    CDKTheme theme,
  ) {
    return Container(
      color: isSelected ? CupertinoColors.activeBlue : null,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildShapeName(index, isSelected),
              CustomPaint(
                painter: CustomShapePainter(
                  shape: appData.shapesList[index],
                  theme: theme,
                  centerX: 0,
                  centerY: 0,
                ),
                size: Size(10, 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildShapeName(int index, bool isSelected) {
    return Text(
      'Shape ${index + 1}',
      style: TextStyle(
        fontSize: 16,
        color: isSelected ? CupertinoColors.white : null,
      ),
    );
  }

  void toggleShapeSelection(AppData appData, int index) {
    appData.setShapeSelected(appData.shapeSelected == index ? -1 : index);
  }
}
