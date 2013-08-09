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

Logger _logger = new Logger("drag_drop");