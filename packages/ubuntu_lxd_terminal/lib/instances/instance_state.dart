import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_x/lxd_x.dart';

import '../lxd.dart';
import 'instance_events.dart';

final instanceState =
    FutureProvider.autoDispose.family<LxdInstanceState, String>((ref, name) {
  final client = ref.watch(lxdClient);
  ref.watch(instanceEvents);
  return client.getInstanceState(name);
});
