// Cada acció ha d'implementar les funcions undo i redo
import 'dart:ui';

import 'app_data.dart';
import 'util_shape.dart';

abstract class Action {
  void undo();
  void redo();
}

// Gestiona la llista d'accions per poder desfer i refer
class ActionManager {
  List<Action> actions = [];
  int currentIndex = -1;
  //AppData appData = AppData();

  void register(Action action) {
    // Elimina les accions que estan després de l'índex actual
    if (currentIndex < actions.length - 1) {
      actions = actions.sublist(0, currentIndex + 1);
    }
    actions.add(action);
    currentIndex++;
    action.redo();
  }

  void undo() {
    if (currentIndex >= 0) {
      actions[currentIndex].undo();
      currentIndex--;
    }
  }

  void redo() {
    if (currentIndex < actions.length - 1) {
      currentIndex++;
      actions[currentIndex].redo();
    }
  }

  void copy() {
    AppData appData = AppData();
    if (appData.shapeSelected >= 0) {
      appData.copyShape = appData.shapesList[appData.shapeSelected];
      appData.copyToClipboard();
      appData.forceNotifyListeners();
    }
  }
}

class ActionSetShapeColor implements Action {
  final AppData appData;
  final Shape shape;
  final Color previousColor;
  final Color newColor;

  ActionSetShapeColor(
      this.appData, this.shape, this.previousColor, this.newColor);

  @override
  void undo() {
    shape.setStrokeColor(previousColor);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    shape.setStrokeColor(newColor);
    appData.forceNotifyListeners();
  }
}

class ActionSetDocWidth implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocWidth(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(value, appData.docSize.height);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionSetDocHeight implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocHeight(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(appData.docSize.width, value);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionAddNewShape implements Action {
  final AppData appData;
  final Shape newShape;

  ActionAddNewShape(this.appData, this.newShape);

  @override
  void undo() {
    appData.shapesList.remove(newShape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList.add(newShape);
    appData.forceNotifyListeners();
  }
}

class ActionSetPositionShape implements Action {
  final AppData appData;
  final Shape shape;
  final Offset previousPosition;
  final Offset newPosition;

  ActionSetPositionShape(
      this.appData, this.shape, this.previousPosition, this.newPosition);

  @override
  void undo() {
    shape.position = previousPosition;
    //appData.updateShapePosition(previousPosition);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    shape.position = newPosition;
    //appData.updateShapePosition(newPosition);
    appData.forceNotifyListeners();
  }
}

class ActionDeleteShape implements Action {
  final AppData appData;
  final Shape shape;
  final int index;

  ActionDeleteShape(this.appData, this.shape, this.index);

  @override
  void undo() {
    appData.shapesList.insert(index, shape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList.removeAt(index);
    appData.forceNotifyListeners();
  }
}
