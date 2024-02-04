import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarDocument extends StatefulWidget {
  const LayoutSidebarDocument({Key? key}) : super(key: key);

  @override
  LayoutSidebarDocumentState createState() => LayoutSidebarDocumentState();
}

class LayoutSidebarDocumentState extends State<LayoutSidebarDocument> {
  late AppData appData;

  late TextStyle fontBold;
  late TextStyle font;

  final GlobalKey<CDKDialogPopoverArrowedState> dialogPopoverKey =
      GlobalKey<CDKDialogPopoverArrowedState>();
  final GlobalKey<CDKButtonColorState> backgroundColorKey =
      GlobalKey<CDKButtonColorState>();

  @override
  void initState() {
    super.initState();
    appData = Provider.of<AppData>(context, listen: false);
    fontBold = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildText("Document properties:", fontBold),
              const SizedBox(height: 8),
              _buildNumericFieldRow("Width:", appData.docSize.width,
                  (value) => appData.setDocWidth(value), labelsWidth),
              const SizedBox(height: 8),
              _buildNumericFieldRow("Height:", appData.docSize.height,
                  (value) => appData.setDocHeight(value), labelsWidth),
              const SizedBox(height: 8),
              _buildColorPickerRow("Background color:",
                  appData.valuebackgroundColorNotifier, labelsWidth),
              const SizedBox(height: 16),
              _buildText("File actions:", fontBold),
              const SizedBox(height: 8),
              _buildSaveFileRow("Load File", labelsWidth),
              const SizedBox(height: 8),
              _buildExportAsSVGRow("Export as SVG", labelsWidth),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSaveFileRow(String label, double labelsWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerRight,
          width: labelsWidth,
          child: CDKButton(
            onPressed: () {
              appData.saveFile();
            },
            child: Text(label),
          ),
        ),
      ],
    );
  }

  Widget _buildExportAsSVGRow(String label, double labelsWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerRight,
          width: labelsWidth,
          child: CDKButton(
            onPressed: () {
              appData.exportAsSVG();
            },
            child: Text(label),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericFieldRow(String label, double value,
      ValueChanged<double> onChanged, double labelsWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLabelContainer(labelsWidth, label),
        const SizedBox(width: 4),
        Container(
          alignment: Alignment.centerLeft,
          width: 80,
          child: CDKFieldNumeric(
            value: value,
            min: 1,
            max: 2500,
            units: "px",
            increment: 100,
            decimals: 0,
            onValueChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerRow(String label,
      ValueListenable<Color> colorValueNotifier, double labelsWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLabelContainer(labelsWidth, label),
        const SizedBox(width: 4),
        ValueListenableBuilder<Color>(
          valueListenable: colorValueNotifier,
          builder: (context, value, child) {
            return CDKButtonColor(
              key: backgroundColorKey,
              color: value,
              onPressed: () => _showColorPicker(context),
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
      child: Text(text, style: font),
    );
  }

  Widget _buildText(String text, TextStyle style) {
    return Text(text, style: style);
  }

  void _showColorPicker(BuildContext context) {
    CDKDialogsManager.showPopoverArrowed(
      key: dialogPopoverKey,
      context: context,
      anchorKey: backgroundColorKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder<Color>(
          valueListenable: appData.valuebackgroundColorNotifier,
          builder: (context, value, child) {
            return CDKPickerColor(
              color: value,
              onChanged: (color) {
                appData.valuebackgroundColorNotifier.value = color;
                appData.setBackgroundColor();
              },
            );
          },
        ),
      ),
    );
  }
}
