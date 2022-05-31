import 'package:flutter/widgets.dart';
import 'package:lxc_config/lxc_config.dart';
import 'package:lxd/lxd.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'app.dart';
import 'instances/instance_model.dart';
import 'remote_images/remote_image_model.dart';

Future<void> main() async {
  final service = LxdService(LxdClient());
  registerServiceInstance<LxdService>(service);

  final config = await loadLxcConfig();
  registerServiceInstance<LxcConfig>(config);

  final preferences = await SharedPreferences.getInstance();
  registerServiceInstance<SharedPreferences>(preferences);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InstanceModel(service),
        ),
        ChangeNotifierProvider(
          create: (_) => RemoteImageModel(service),
        ),
      ],
      child: const LxdApp(),
    ),
  );
}
