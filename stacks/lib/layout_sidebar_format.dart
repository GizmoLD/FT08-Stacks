import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarFormat extends StatelessWidget {
  const LayoutSidebarFormat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final fontBold = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    final font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelsWidth = constraints.maxWidth * 0.5;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildText("Coordinates:", fontBold),
              const SizedBox(height: 8),
              _buildOffsetXRow(labelsWidth, appData),
              const SizedBox(height: 8),
              _buildOffsetYRow(labelsWidth, appData),
              const SizedBox(height: 8),
              _buildText("Stroke and fill:", fontBold),
              const SizedBox(height: 8),
              _buildStrokeWidthRow(labelsWidth, appData),
              const SizedBox(height: 8),
              _buildStrokeColorRow(labelsWidth, appData, context),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildText(String text, TextStyle style) {
    return Text(text, style: style);
  }

  Widget _buildStrokeWidthRow(double labelsWidth, AppData appData) {
    //double strokeWidth = appData.getSelectedShape()?.strokeWidth ?? 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLabelContainer(labelsWidth, "Stroke width:"),
        const SizedBox(width: 4),
        Container(
          alignment: Alignment.centerLeft,
          width: 80,
          child: CDKFieldNumeric(
            //value: appData.newShape?.strokeWidth ?? 0.0,
            value: appData.newShape.strokeWidth,
            //value: strokeWidth,
            min: 0.01,
            max: 100,
            units: "px",
            increment: 0.5,
            decimals: 2,
            onValueChanged: (value) => appData.setNewShapeStrokeWidth(value),
          ),
        ),
      ],
    );
  }

  Widget _buildOffsetXRow(double labelsWidth, AppData appData) {
    double offsetXValue = (appData.shapeSelected == -1)
        ? 0.00
        : appData.getSelectedShape()?.position.dx ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLabelContainer(labelsWidth, "Offset X:"),
        const SizedBox(width: 4),
        Container(
          alignment: Alignment.centerLeft,
          width: 80,
          child: CDKFieldNumeric(
            value: offsetXValue,
            min: -1000,
            max: 1000,
            units: "px",
            increment: 0.5,
            decimals: 2,
            //onValueChanged: (value) {
            //  if (appData.shapeSelected != -1) {
            //    appData.getSelectedShape()?.position.dx;
            //  }
            //}
            onValueChanged: (value) =>
                appData.getSelectedShape()?.setPositionX(value),
          ),
        ),
      ],
    );
  }

  Widget _buildOffsetYRow(double labelsWidth, AppData appData) {
    double offsetXValue = (appData.shapeSelected == -1)
        ? 0.00
        : appData.getSelectedShape()?.position.dy ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLabelContainer(labelsWidth, "Offset Y:"),
        const SizedBox(width: 4),
        Container(
          alignment: Alignment.centerLeft,
          width: 80,
          child: CDKFieldNumeric(
            value: offsetXValue,
            min: -1000,
            max: 1000,
            units: "px",
            increment: 0.5,
            decimals: 2,
            //onValueChanged: (value) {
            //  if (appData.shapeSelected != -1) {
            //    appData.getSelectedShape()?.position.dy;
            //  }
            //}
            onValueChanged: (value) =>
                appData.getSelectedShape()?.setPositionY(value),
          ),
        ),
      ],
    );
  }

  Widget _buildStrokeColorRow(
      double labelsWidth, AppData appData, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLabelContainer(labelsWidth, "Stroke color:"),
        const SizedBox(width: 4),
        ValueListenableBuilder<Color>(
          valueListenable: appData.valueShapeColorNotifier,
          builder: (context, value, child) {
            final initialColor = appData.toolSelected == "pointer_shapes"
                ? appData.getSelectedShapeColor()
                : value;
            final colorKey = GlobalKey<CDKButtonColorState>();
            return CDKButtonColor(
              key: colorKey,
              color: initialColor,
              onPressed: () => _showColorPicker(context, appData, colorKey),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabelContainer(double width, String text) {
    return Container(
      alignment: Alignment.centerRight,
      width: width,
      child: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
    );
  }

  void _showColorPicker(BuildContext context, AppData appData,
      GlobalKey<CDKButtonColorState> colorKey) {
    final popoverKey = GlobalKey<CDKDialogPopoverArrowedState>();

    CDKDialogsManager.showPopoverArrowed(
      key: popoverKey,
      context: context,
      anchorKey: colorKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder<Color>(
          valueListenable: appData.valueShapeColorNotifier,
          builder: (context, value, child) {
            return CDKPickerColor(
              color: value,
              onChanged: (color) {
                appData.valueShapeColorNotifier.value = color;
                if (appData.toolSelected == "pointer_shapes") {
                  appData.setShapeColor(color);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
