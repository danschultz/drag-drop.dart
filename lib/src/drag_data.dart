part of drag_drop;

typedef Object _Data();

class DragData extends HashMap<String, _Data> {
  
  DragData();
  
  bool contains(String type) {
    return containsKey(type);
  }
  
  Object get(String type) {
    var data = this[type];
    return data != null ? data() : null;
  }
  
  void set(String type, _Data data) {
    this[type] = data;
  }
  
}