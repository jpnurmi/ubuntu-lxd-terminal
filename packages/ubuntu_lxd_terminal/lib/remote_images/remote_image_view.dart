import 'package:async_value/async_value.dart';
import 'package:collection/collection.dart';
import 'package:data_size/data_size.dart';
import 'package:flutter/material.dart';
import 'package:lxd/lxd.dart';
import 'package:operating_system_logos/operating_system_logos.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

import '../widgets/loading_indicator.dart';
import 'remote_image_model.dart';

class RemoteImageView extends StatefulWidget {
  const RemoteImageView({
    super.key,
    this.selected,
    this.onSelected,
  });

  final LxdRemoteImage? selected;
  final ValueChanged<LxdRemoteImage>? onSelected;

  @override
  State<RemoteImageView> createState() => _RemoteImageViewState();
}

class _RemoteImageViewState extends State<RemoteImageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemoteImageModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RemoteImageModel>();
    return model.images.map(
      data: (data) {
        return Stack(
          children: [
            _RemoteImageListView(
              images: data.value,
              selected: widget.selected,
              onSelected: widget.onSelected,
            ),
            if (data.isRefreshing) const LoadingIndicator(),
          ],
        );
      },
      loading: (loading) => const LoadingIndicator(),
      error: (error) => Text('TODO: ${error.error}'),
    );
  }
}

class _RemoteImageListView extends StatelessWidget {
  const _RemoteImageListView({this.images, this.selected, this.onSelected});

  final List<LxdRemoteImage>? images;
  final LxdRemoteImage? selected;
  final ValueChanged<LxdRemoteImage>? onSelected;

  String alias(LxdRemoteImage image) {
    return image.aliases.firstOrNull?.split('/').first ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return RoundedListView.builder(
      itemCount: images?.length ?? 0,
      itemBuilder: (context, index) {
        final image = images![index];
        return ListTile(
          selected: selected == image,
          leading: OperatingSystemLogo(name: alias(image), size: 32),
          title: Text(image.description),
          trailing: Text(image.size.formatByteSize()),
          onTap: () => onSelected?.call(image),
        );
      },
    );
  }
}
