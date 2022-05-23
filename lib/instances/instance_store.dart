import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

import '../lxd.dart';
import 'instance_events.dart';

final instanceStore = FutureProvider.autoDispose<List<LxdInstance>>((ref) {
  final client = ref.watch(lxdClient);
  ref.watch(instanceEvents);
  return client.getInstances().then((names) async {
    return [
      for (final name in names) await client.getInstance(name),
    ];
  });
});
