library drag_and_drop;

import 'dart:html';
import 'package:drag_drop/drag_drop.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

void main() {
  
  Logger.root.onRecord.listen(new PrintHandler());
  Logger.root.level = Level.FINER;
  
  var source = new DragSource(query(".drag-source"));
  
  queryAll(".drop-target").forEach((Element e) {
    var target = new DropTarget(
        e,
        accept: (source) => true,
        drop: (source) => print("DROP!")
    );
  });
  
}