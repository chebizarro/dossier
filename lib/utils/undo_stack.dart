class UndoAction {
  final void Function() undo;
  final void Function() redo;

  UndoAction({required this.undo, required this.redo});
}

class UndoStack {
  final List<UndoAction> _actions = [];
  int _currentIndex = -1;

  bool get canUndo => _currentIndex >= 0;
  bool get canRedo => _currentIndex < _actions.length - 1;

  void addAction(UndoAction action) {
    if (_currentIndex < _actions.length - 1) {
      _actions.removeRange(_currentIndex + 1, _actions.length);
    }
    _actions.add(action);
    _currentIndex++;
  }

  void undo() {
    if (canUndo) {
      _actions[_currentIndex].undo();
      _currentIndex--;
    }
  }

  void redo() {
    if (canRedo) {
      _currentIndex++;
      _actions[_currentIndex].redo();
    }
  }
}
