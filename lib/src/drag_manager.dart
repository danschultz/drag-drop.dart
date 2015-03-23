part of drag_drop;

DragManager _dragManager = new DragManager();

// TODO: Have DragManager handle the events for DragSource as well. Maybe add _activeSource
class DragManager {
  StreamSubscription _mouseMove;
  StreamSubscription _mouseUp;

  List<DropTarget> _targets = [];

  DragSource _activeSource;
  DropTarget _activeTarget;

  DragManager() {
    globalOnDragStart.listen((event) {
      _activeSource = event.source;
      _mouseMove = window.onMouseMove.listen(_onMouseMove);
      _mouseUp = window.onMouseUp.take(1).listen(_onMouseUp);
    });
  }

  void _onMouseMove(MouseEvent event) {
    _checkTargets(_dragImage._elementUnder(event.client));
  }

  void _onMouseUp(MouseEvent event) {
    _mouseMove.cancel();

    if (_activeTarget != null && _activeTarget.isEnabled) {
      _activeTarget._drop();
      _activeTarget = null;
      _activeSource.stopDrag(true);
    } else {
      _activeSource.stopDrag(false);
    }

    _activeSource = null;
  }

  void _checkTargets(Element element) {
    var hit = _targets.firstWhere((target) => _isHit(target, element), orElse: () => null);

    if (_activeTarget != hit) {
      if (_activeTarget != null) {
        _activeTarget._leave();
      }

      _activeTarget = hit;

      if (hit != null) {
        hit._enter();
      }
    }

    if (hit != null) {
      hit._hover();
    }
  }

  bool _isHit(DropTarget target, Element element) {
    return target.element == element || _doesHitChildElement(target.element, element);
  }

  bool _doesHitChildElement(Element host, Element test) {
    // This manual child testing is slow. We could probably speed this up by adding
    // a config option if the developer wants to test for SVG elements.
    if (browser.isIe && host is svg.SvgElement) {
      return host.children.any((child) {
        return child == test || _doesHitChildElement(child, test);
      });
    } else {
      return host.contains(test);
    }
  }

  void registerTarget(DropTarget target) {
    _targets.add(target);
  }

  void unregisterTarget(DropTarget target) {
    _targets.remove(target);

    if (_activeTarget == target) {
      _activeTarget = null;
    }
  }
}
