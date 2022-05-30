import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lxd/lxd.dart';
import 'package:provider/provider.dart';

import '../remote_images/remote_image_model.dart';
import '../remote_images/remote_image_view.dart';
import '../widgets/loading_indicator.dart';

class LaunchOptions {
  const LaunchOptions({required this.name, required this.image});
  final String? name;
  final LxdRemoteImage image;
}

Future<LaunchOptions?> showLauncherDialog(BuildContext context) async {
  final controller = TextEditingController();
  final selected = ValueNotifier<LxdRemoteImage?>(null);

  final result = await showDialog(
    context: context,
    builder: (context) => AnimatedBuilder(
      animation: selected,
      builder: (context, child) {
        return LauncherDialog(
          controller: controller,
          selected: selected.value,
          onSelected: (value) => selected.value = value,
        );
      },
    ),
  );

  controller.dispose();

  if (result != true) return null;

  return LaunchOptions(name: controller.text, image: selected.value!);
}

class LauncherDialog extends StatelessWidget {
  const LauncherDialog({
    super.key,
    required this.controller,
    required this.selected,
    required this.onSelected,
  });

  final TextEditingController controller;
  final LxdRemoteImage? selected;
  final ValueChanged<LxdRemoteImage?> onSelected;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RemoteImageModel>();
    return AlertDialog(
      title: const Text('Create Instance'),
      content: SizedBox(
        width: 900,
        height: 600,
        child: model.images.map(
          data: (data) => Column(
            children: [
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: RemoteImageView(
                  selected: selected,
                  onSelected: onSelected,
                ),
              ),
            ],
          ),
          loading: (previous) => const LoadingIndicator(),
          error: (error) => Text('TODO: $error'),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed:
              selected != null ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
