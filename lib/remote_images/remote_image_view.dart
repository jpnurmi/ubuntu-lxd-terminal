import 'package:data_size/data_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

import '../widgets/loading_indicator.dart';
import 'remote_image_store.dart';

class RemoteImageView extends ConsumerWidget {
  const RemoteImageView({
    super.key,
    this.selected,
    this.onSelected,
  });

  final LxdRemoteImage? selected;
  final ValueChanged<LxdRemoteImage>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remoteImages = ref.watch(remoteImageStore);
    return remoteImages.when(
      data: (data) => _RemoteImageListView(
        images: data,
        selected: selected,
        onSelected: onSelected,
      ),
      loading: () => const LoadingIndicator(),
      error: (error, stackTrace) => Text('TODO: $error'),
    );
  }
}

class _RemoteImageListView extends StatelessWidget {
  const _RemoteImageListView({this.images, this.selected, this.onSelected});

  final List<LxdRemoteImage>? images;
  final LxdRemoteImage? selected;
  final ValueChanged<LxdRemoteImage>? onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: images?.length ?? 0,
      itemBuilder: (context, index) {
        final image = images![index];
        return ListTile(
          selected: selected == image,
          title: Text(image.description),
          trailing: Text(image.size.formatByteSize()),
          onTap: () => onSelected?.call(image),
        );
      },
    );
  }
}
