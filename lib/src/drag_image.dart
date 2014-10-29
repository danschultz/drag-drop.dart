part of drag_drop;

typedef Future DragAnimation();

class DragImage {
  final Element element;
  final Point offset;

  Point _origin;
  DragAnimation _cancelAnimation;

  DragImage(this.element, {this.offset: const Point(0, 0), DragAnimation cancelAnimation}) {
    element.classes.add("drag-image");
    _cancelAnimation = cancelAnimation;
  }

  factory DragImage.clone(Element element, {Point offset: const Point(0, 0)}) {
    return new DragImage(element.clone(true), offset: offset);
  }

  Element _elementUnder(Point client) {
    // In order to get the element under the drag image, we need to hide it.
    var previousDisplay = element.style.display;
    element.style.display = "none";
    var found = document.elementFromPoint(client.x, client.y);
    element.style.display = previousDisplay;
    return found;
  }

  void show(Point origin) {
    _origin = origin + offset;
    document.body.append(element);
    _setPosition(_origin);
  }

  void _move(Point delta) {
    _logger.finest("drag image move delta $delta");
    _setPosition(_origin + delta);
  }

  void _setPosition(Point position) {
    element.style
        ..position = 'absolute'
        ..top = '${position.y.toInt()}px'
        ..left = '${position.x.toInt()}px';
  }

  void hide(bool animate) {
    if (_cancelAnimation != null && animate) {
      _cancelAnimation().then((_) => destroy());
    } else {
      destroy();
    }
  }

  void destroy() => element.remove();
}
