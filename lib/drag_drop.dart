library drag_drop;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:svg' as svg;
import 'package:logging/logging.dart';

part 'src/drag_source.dart';
part 'src/drop_target.dart';
part 'src/drag_event.dart';
part 'src/drag_image.dart';
part 'src/drag_data.dart';

bool isDragging = false;

StreamController _globalOnDragStartedController = new StreamController.broadcast(sync: true);
Stream get _globalOnDragStarted => _globalOnDragStartedController.stream;

StreamController _globalOnDragEndController = new StreamController.broadcast(sync: true);
Stream get _globalOnDragEnd => _globalOnDragEndController.stream;

Logger _logger = new Logger("drag_drop");