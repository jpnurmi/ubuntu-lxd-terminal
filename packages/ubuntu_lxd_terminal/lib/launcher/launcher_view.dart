import 'package:flutter/material.dart';
import 'package:lxd/lxd.dart';

import '../instances/instance_view.dart';
import 'launcher_dialog.dart';

typedef OnCreateCallback = void Function(LxdRemoteImage image, String? name);

class LauncherView extends StatelessWidget {
  const LauncherView({
    super.key,
    this.onCreate,
    this.onStart,
    this.onStop,
    this.onDelete,
  });

  final OnCreateCallback? onCreate;
  final ValueChanged<String>? onStart;
  final ValueChanged<String>? onStop;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InstanceView(
        onSelect: onStart,
        onDelete: onDelete,
        onStop: onStop,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final options = await showLauncherDialog(context);
          if (options != null) {
            onCreate?.call(options.image, options.name);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
