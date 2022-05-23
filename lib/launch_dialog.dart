import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

import '../remote_images/remote_image_store.dart';
import '../remote_images/remote_image_view.dart';
import '../widgets/loading_indicator.dart';

final selectedImage = StateProvider<LxdRemoteImage?>((ref) => null);

final nameController = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(controller.dispose);
  return controller;
});

class LaunchOptions {
  const LaunchOptions({required this.name, required this.image});
  final String? name;
  final LxdRemoteImage image;
}

Future<LaunchOptions?> showLaunchDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => const LaunchDialog(),
  );
}

class LaunchDialog extends ConsumerWidget {
  const LaunchDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedImage);
    final images = ref.watch(remoteImageStore);

    return AlertDialog(
      title: const Text('Create Instance'),
      content: SizedBox(
        width: 900,
        height: 600,
        child: images.map(
          data: (data) => Column(
            children: [
              TextFormField(
                controller: ref.watch(nameController),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 24),
              Expanded(
                // TODO: RoundedContainer/ListView
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.5),
                    child: Material(
                      color: Colors.transparent,
                      child: RemoteImageView(
                        selected: selected,
                        onSelected: (image) {
                          ref.read(selectedImage.state).state = image;
                        },
                      ),
                    ),
                  ),
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
          onPressed: selected != null
              ? () => Navigator.of(context).pop(
                    LaunchOptions(
                      name: ref.watch(nameController).value.text,
                      image: selected,
                    ),
                  )
              : null,
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
