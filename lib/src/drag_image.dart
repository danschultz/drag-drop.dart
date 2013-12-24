part of drag_drop;

class DragImage {

  final Element element;
  final Point offset;

  String _cursor;
  Point _origin;

  DragImage(this.element, {this.offset: const Point(0, 0)});

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

  void _show(Point origin, String cursor) {
    _origin = origin + offset;
    element.style.cursor = cursor;
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

  void _hide() {
    element.remove();
  }

}
