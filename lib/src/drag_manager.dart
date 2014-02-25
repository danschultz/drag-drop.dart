part of drag_drop;

DragManager _dragManager = new DragManager();

class DragManager {
  StreamSubscription _mouseMove;

  List<DropTarget> _targets = [];
  DropTarget _activeTarget;

  DragManager() {
    globalOnDragStart.listen((event) {
      _mouseMove = window.onMouseMove.listen(_onMouseMove);
    });

    globalOnDragEnd.listen((_) {
      _mouseMove.cancel();
      if (_activeTarget != null) {
        _activeTarget._drop();
        _activeTarget = null;
      }
    });
  }

  void _onMouseMove(MouseEvent event) {
    _checkTargets(_dragImage._elementUnder(event.client));
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
  }
}
