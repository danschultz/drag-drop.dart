part of drag_drop;

typedef bool AcceptCallback(DragSource source);
typedef void DropHandler(Object data);

class DropTarget {
  final Element element;

  var _handlers = {};
  Map<String, DropHandler> get handlers => _handlers;
  set handlers(Map<String, DropHandler> value) => _handlers = value != null ? value : {};

  AcceptCallback accept;

  bool _isAccepted = false;
  bool get isAccepted => _isAccepted;

  StreamSubscription _mouseMove;
  StreamSubscription _mouseUp;

  var _onDragEnterController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragEnter => _onDragEnterController.stream;

  var _onDragOverController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragOver => _onDragOverController.stream;

  var _onDragLeaveController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragLeave => _onDragLeaveController.stream;

  var _onDropController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDrop => _onDropController.stream;

  DropTarget(this.element) {
    _dragManager.registerTarget(this);

    onDragEnter.listen(_onDragEnter);
    onDragOver.listen(_onDragOver);
    onDragLeave.listen(_onDragLeave);
    onDrop.listen(_onDrop);
  }

  void destroy() {
    _dragManager.unregisterTarget(this);

    _onDragEnterController.close();
    _onDragOverController.close();
    _onDragLeaveController.close();
    _onDropController.close();
  }

  void _enter() {
    _onDragEnterController.add(_dragEvent);
  }

  void _leave() {
    _onDragLeaveController.add(_dragEvent);
  }

  void _hover() {
    _onDragOverController.add(_dragEvent);
  }

  void _drop() {
    _onDropController.add(_dragEvent);
  }

  void _onDragEnter(DragEvent event) {
    _logger.finer("Drag enter");

    var accepted = false;

    // If the accept callback is defined, then honor its result.
    // Otherwise, use the target's default behavior.
    if (accept != null) {
      accepted = accept(event.source);
    } else {
      accepted = event.source.data.types.any((k) => handlers.containsKey(k));
    }

    if (accepted) {
      _acceptDrag();
    }
  }

  void _onDragOver(DragEvent event) {
    _logger.finest("Drag over");
  }

  void _onDragLeave(DragEvent event) {
    _logger.finer("Drag leave");
    _isAccepted = false;
  }

  void _onDrop(DragEvent event) {
    if (_isAccepted) {
      _logger.finer("Drop");
      _applyDrop(event.source);
    }
  }

  void _acceptDrag() {
    _isAccepted = true;
  }

  void _applyDrop(DragSource source) {
    handlers.forEach((type, handler) {
      if (source.data.contains(type)) {
        handler(source.data.get(type));
      }
    });
  }
}