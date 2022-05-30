import 'package:flutter/widgets.dart';
import 'package:lxd/lxd.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'app.dart';
import 'instances/instance_model.dart';
import 'remote_images/remote_image_model.dart';

Future<void> main() async {
  registerService<LxdService>(() => LxdService(LxdClient()));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InstanceModel(getService<LxdService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => RemoteImageModel(getService<LxdService>()),
        ),
      ],
      child: const LxdApp(),
    ),
  );
}
