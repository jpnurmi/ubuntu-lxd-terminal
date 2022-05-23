import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

import '../lxd.dart';

const _kDefaultUrl = 'https://cloud-images.ubuntu.com/releases';

final remoteImageUrl = Provider<String>((_) => _kDefaultUrl);
final remoteImageArchitecture = Provider<String>((_) => 'amd64'); // TODO

final remoteImageStore =
    FutureProvider.autoDispose<List<LxdRemoteImage>>((ref) async {
  final client = ref.watch(lxdClient);
  final url = ref.watch(remoteImageUrl);
  final arch = ref.watch(remoteImageArchitecture);
  final images = await client.getRemoteImages(url);
  return images
      .where((image) => image.architecture == arch)
      .fold<Map<String, LxdRemoteImage>>(
        {},
        (releases, image) => releases
          ..update(image.description, (_) => image, ifAbsent: () => image),
      )
      .values
      .toList();
});
