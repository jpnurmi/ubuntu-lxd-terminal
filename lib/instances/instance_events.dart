import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

import '../lxd.dart';

final instanceEvents = StreamProvider.autoDispose<LxdEvent>((ref) {
  final client = ref.watch(lxdClient);
  return client.getEvents().where((event) {
    switch (event.type) {
      case LxdEventType.operation:
        final op = LxdOperation.fromJson(event.metadata ?? <String, dynamic>{});
        return op.resources['instances']?.isNotEmpty == true;
      case LxdEventType.logging:
        return event.metadata?['event'] == 'exiting';
      default:
        return false;
    }
  });
});
