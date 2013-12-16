part of drag_drop;

class DragImage {

  final Element element;
  final Point offset;

  String _cursor;
  Point _origin;

  DragImage(this.element, {this.offset: const Point(0, 0), String cursor: "auto"}) {
    _cursor = cursor;
  }

  factory DragImage.clone(Element element, {Point offset: const Point(0, 0), String cursor: "auto"}) {
    return new DragImage(element.clone(true), offset: offset, cursor: cursor);
  }

  Element _elementUnder(Point client) {
    // In order to get the element under the drag image, we need to
    // toggle its visibility.
    element.style.visibility = "hidden";
    var found = document.elementFromPoint(client.x, client.y);
    element.style.visibility = "visible";
    return found;
  }

  void _show(Point origin) {
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
        ..cursor = _cursor
        ..position = 'absolute'
        ..top = '${position.y.toInt()}px'
        ..left = '${position.x.toInt()}px';
  }

  void _hide() {
    element.remove();
  }

}
