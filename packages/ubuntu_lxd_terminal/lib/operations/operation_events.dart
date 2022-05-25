import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

import '../lxd.dart';

final instanceOperations =
    StreamProvider.autoDispose.family<LxdOperation, String>((ref, id) {
  final client = ref.watch(lxdClient);
  return client
      .getEvents()
      .where((event) => event.isOperation && event.metadata?['id'] == id)
      .map((event) => LxdOperation.fromJson(event.metadata!));
});
