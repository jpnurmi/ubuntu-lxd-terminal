import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_store/lxd_store.dart';
import 'package:lxd_x/lxd_x.dart';

import '../lxd.dart';

final instanceStore = Provider.autoDispose<InstanceStore>((ref) {
  final client = ref.watch(lxdClient);
  ref.onDispose(client.close);
  return InstanceStore(client);
});

final instanceStream = StreamProvider.autoDispose<List<String>>((ref) async* {
  final store = ref.watch(instanceStore);
  ref.onDispose(store.dispose);
  await store.init();
  yield* store.stream;
});

final instanceUpdated =
    StreamProvider.autoDispose.family<String, String>((ref, name) {
  final store = ref.watch(instanceStore);
  return store.onUpdated.where((instance) => instance == name);
});

final instanceState =
    FutureProvider.autoDispose.family<LxdInstance, String>((ref, name) {
  final client = ref.watch(lxdClient);
  ref.watch(instanceUpdated(name));
  return client.getInstance(name);
});
