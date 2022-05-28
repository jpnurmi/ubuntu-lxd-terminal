import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'app.dart';

Future<void> main() async {
  registerService<LxdService>(LxdService.new);
  runApp(const ProviderScope(child: LxdApp()));
}
