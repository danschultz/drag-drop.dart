part of drag_drop;

typedef bool AcceptCallback(DragSource source);
typedef void DropHandler(Object data);

class DropTarget {

  final Element element;

  var _handlers = {};
  Map<String, DropHandler> get handlers => _handlers;
  set handlers(Map<String, DropHandler> value) => _handlers = value != null ? value : {};

  AcceptCallback accept;

  bool _isOver = false;

  bool _isAccepted = false;
  bool get isAccepted => _isAccepted;

  Rect _computedTargetBounds;

  StreamSubscription _mouseMove;
  StreamSubscription _mouseUp;

  DropTarget(this.element) {
    _initializeDragListeners();
  }

  void _initializeDragListeners() {
    _globalOnDragStarted.listen((_) {
      _mouseMove = window.onMouseMove.listen(_onMouseMove);
      _mouseUp = window.onMouseUp.listen(_onMouseUp);
    });

    _globalOnDragEnd.listen((_) {
      _mouseMove.cancel();
      _mouseUp.cancel();
    });

    onDragEnter.listen(_onDragEnter);
    onDragOver.listen(_onDragOver);
    onDragLeave.listen(_onDragLeave);
    onDrop.listen(_onDrop);
  }

  void destroy() {
    _onDragEnterController.close();
    _onDragOverController.close();
    _onDragLeaveController.close();
    _onDropController.close();
  }

  bool _isMouseOverTarget(MouseEvent event) {
    var isOver = false;

    // Do a more precise hit test when the pointer's position is within the
    // bounding box of the target element.
    if (_computedTargetBounds.containsPoint(event.client)) {
      var found = _dragImage._elementUnder(event.client);
      _logger.finest("Element under mouse '$found'");

      // Check if the found element is a child of this target.
      if (!isOver) {
        // If the element is an SVG element, then we need to do a special check,
        // because IE9 doesn't support SvgElement.contains().
        isOver = !(element is svg.SvgElement) ? element.contains(found) : _svgContains(element, found);
      }
    }

    return isOver;
  }

  var _onDragEnterController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragEnter => _onDragEnterController.stream;

  var _onDragOverController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragOver => _onDragOverController.stream;

  var _onDragLeaveController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragLeave => _onDragLeaveController.stream;

  var _onDropController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDrop => _onDropController.stream;

  void _onDragEnter(DragEvent event) {
    _logger.finer("Drag enter");

    var accepted = false;

    // If the accept callback is defined, then honor its result.
    // Otherwise, use the target's default behavior.
    if (accept != null) {
      accepted = accept(event.source);
    } else {
      accepted = event.source.data.keys.any((k) => handlers.containsKey(k));
    }

    if (accepted) {
      _acceptDrag();
    }
  }

  void _onMouseMove(MouseEvent event) {
    if (isDragging) {
      // Cache the target's bounds for faster hit testing.
      if (_computedTargetBounds == null) {
        _computedTargetBounds = element.getBoundingClientRect();
      }

      var wasOver = _isOver;
      _isOver = _isMouseOverTarget(event);

      if (_isOver && !wasOver) {
        _onDragEnterController.add(_dragEvent);
      }

      if (!_isOver && wasOver) {
        _onDragLeaveController.add(_dragEvent);
      }

      if (_isOver && wasOver) {
        _onDragOverController.add(_dragEvent);
      }
    }
  }

  void _onMouseUp(MouseEvent event) {
    if (_isOver) {
      _onDropController.add(_dragEvent);
      _onDragLeaveController.add(_dragEvent);
    }
  }

  void _onDragOver(DragEvent event) {
    _logger.finest("Drag over");
  }

  void _onDragLeave(DragEvent event) {
    _logger.finer("Drag leave");
    _isOver = false;
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

bool _svgContains(svg.SvgElement svgNode, Element element) {
  if (svgNode != element) {
    return svgNode.children.any((c) => _svgContains(c, element));
  }
  return true;
}