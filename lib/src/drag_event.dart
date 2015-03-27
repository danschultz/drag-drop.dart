part of drag_drop;

class DragEvent {
  bool isDroppable = true;

  final DragSource source;
  MouseEvent _mouseEvent;
  MouseEvent get mouseEvent => _mouseEvent;

  DragEvent(this.source);
}
