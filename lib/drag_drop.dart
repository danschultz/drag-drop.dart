library drag_drop;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:svg' as svg;
import 'package:browser_detect/browser_detect.dart';
import 'package:logging/logging.dart';

part 'src/drag_source.dart';
part 'src/drop_target.dart';
part 'src/drag_event.dart';
part 'src/drag_image.dart';
part 'src/drag_data.dart';
part 'src/drag_manager.dart';

bool isDragging = false;

StreamController _globalOnDragStartController = new StreamController.broadcast(sync: true);
Stream get globalOnDragStart => _globalOnDragStartController.stream;

StreamController _globalOnDragEndController = new StreamController.broadcast(sync: true);
Stream get globalOnDragEnd => _globalOnDragEndController.stream;

Logger _logger = new Logger("drag_drop");