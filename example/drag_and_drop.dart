library drag_and_drop;

import 'dart:html';
import 'package:drag_drop/drag_drop.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.onRecord.listen((record) => print(record.message));
  Logger.root.level = Level.FINER;

  var source = new DragSource(querySelector(".drag-source"));

  querySelectorAll(".drop-target").forEach((Element e) {
    var target = new DropTarget(e);
    target.accept = (_) => true;
  });
}