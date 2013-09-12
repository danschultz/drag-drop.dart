part of drag_drop;

typedef Object _Data();

class DragData {
  Map<String, _Data> _data;

  DragData();

  bool contains(String type) {
    return _data.containsKey(type);
  }

  Object get(String type) {
    var data = _data[type];
    return data != null ? data() : null;
  }

  void set(String type, _Data data) {
    _data[type] = data;
  }
}