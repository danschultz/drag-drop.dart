part of drag_drop;

typedef DragImage DragImageFactory(Element element, Point pointer);

DragImage _dragImage;
DragEvent _dragEvent;

class DragSource {

  final bool manual;
  bool get auto => !manual;
  final Element element;

  int distance = 5;
  bool enabled = true;
  DragImageFactory feedbackImage;
  final DragData data = new DragData();

  bool _isDestroyed = false;

  StreamSubscription _mouseDrag;
  Point _lastPointerPosition;

  DragSource(this.element, {this.manual: false, this.feedbackImage: null}) {
    if (feedbackImage == null) {
      feedbackImage = (element, pointer) => new DragImage.clone(element);
    }
    _initialize();
    _setupListenersForLogging();
  }

  void _initialize() {
    if (auto) {
      _setupAutoMouseDrag();
      _setupAutoTouchDrag();
    }
  }

  void _setupAutoMouseDrag() {
    var mouseDrag = element.onMouseDown.transform(new StreamTransformer(
        handleData: (MouseEvent md, EventSink s) {
          md.preventDefault();

          var mouseMove = window.onMouseMove.listen((MouseEvent mm) {
            _lastPointerPosition = mm.client;
            return s.add(mm.client.distanceTo(md.client).abs());
          });

          window.onMouseUp.take(1).listen((e) {
            mouseMove.cancel();
            _logger.finest("Detect start drag: Mouse up");
          });
        })
    );

    _mouseDrag = mouseDrag.listen((num delta) {
      if (delta > distance) {
        startDrag();
      }
    });
  }

  void _setupAutoTouchDrag() {
    var touchDrag = element.onTouchStart.transform(new StreamTransformer(
        handleData: (TouchEvent ts, EventSink s) {
          var touchMove = window.onTouchMove.listen((TouchEvent tm) {
            _logger.finest("Touch move");

            var touchPosition = tm.touches.first.client;
            _lastPointerPosition = touchPosition;
            return s.add(touchPosition.distanceTo(ts.touches.first.client).abs());
          });

          window.onTouchEnd.take(1).listen((e) {
            touchMove.cancel();
            _logger.finest("Detect start drag: Touch end");
          });
        })
    );

    _mouseDrag = touchDrag.listen((num delta) {
      if (delta > distance) {
        startDrag();
      }
    });
  }

  var _onDragStartController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragStart => _onDragStartController.stream;

  var _onDragController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDrag => _onDragController.stream;

  var _onDragEndController = new StreamController<DragEvent>.broadcast(sync: true);
  Stream<DragEvent> get onDragEnd => _onDragEndController.stream;

  void destroy() {
    if (_mouseDrag != null) {
      _mouseDrag.cancel();
      _mouseDrag = null;
    }

    _onDragStartController.close();
    _onDragController.close();
    _onDragEndController.close();

    _isDestroyed = true;
  }

  void startDrag([Point pointerPosition]) {
    if (_isDestroyed) {
      throw new StateError("Cannot start a drag on a destroyed drag source.");
    }

    if (!isDragging && enabled) {
      if (manual) {
        if (pointerPosition != null) {
          _lastPointerPosition = pointerPosition;
        } else {
          throw new ArgumentError("Cannot start manual drag without a pointer position");
        }
      }
      _dragEvent = new DragEvent(this);
      _globalOnDragStartedController.add(true);
      _onDragStartController.add(_dragEvent);
      _setupDragListeners();
      _showDragImage();
      isDragging = true;
    }
  }

  void stopDrag() {
    if (isDragging) {
      _cleanupDrag();
      _onDragEndController.add(_dragEvent);
      _globalOnDragEndController.add(true);
    }
  }

  void _showDragImage() {
    _dragImage = feedbackImage(element, _lastPointerPosition);
    _dragImage._show(_lastPointerPosition);
  }

  void _setupDragListeners() {
    var pointerOrigin = _lastPointerPosition;

    window.onMouseMove.takeWhile((e) => isDragging).listen((MouseEvent e) {
      _dragEvent._mouseEvent = e;
      _onDragController.add(_dragEvent);
      _dragImage._move(e.client - pointerOrigin);
    });

    window.onMouseUp.take(1).listen((e) {
      // Drag end should be the last event fired. Fire it at the end of this
      // event loop.
      Timer.run(() => stopDrag());
    });
  }

  void _cleanupDrag() {
    _dragImage._hide();
    _dragImage = null;
    _dragEvent = null;
    isDragging = false;
  }

  void _setupListenersForLogging() {
    onDragStart.listen((e) => _logger.finer("Drag start"));
    onDrag.listen((e) => _logger.finest("Drag"));
    onDragEnd.listen((e) => _logger.finer("Drag end"));
  }

}
