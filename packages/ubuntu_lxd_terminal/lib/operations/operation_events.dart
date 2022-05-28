import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:lxd_x/lxd_x.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final instanceOperations =
    StreamProvider.autoDispose.family<LxdOperation, String>((ref, id) {
  final service = getService<LxdService>();
  return service
      .getEvents()
      .where((event) => event.isOperation && event.metadata?['id'] == id)
      .map((event) => LxdOperation.fromJson(event.metadata!));
});
