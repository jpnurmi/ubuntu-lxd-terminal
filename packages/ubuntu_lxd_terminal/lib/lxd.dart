import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

final lxdClient = Provider((_) => LxdClient());

extension LxdEventX on LxdEvent {
  bool get isOperation => type == LxdEventType.operation;
}

extension LxdInstanceX on LxdInstance {
  bool get isStarted => statusCode == LxdStatusCode.started.value;
  bool get isRunning => statusCode == LxdStatusCode.running.value;
  bool get isStopped => statusCode == LxdStatusCode.stopped.value;
}

extension LxdNetworkAddressX on LxdNetworkAddress {
  bool get isIPv4 => family == 'inet' && !isLinkLocal;
  bool get isIPv6 => family == 'inet6' && !isLinkLocal;
  bool get isLinkLocal => scope == 'link' || scope == 'local';
}

extension LxdNetworkStateX on LxdNetworkState {
  bool get isLoopback => type == 'loopback';

  List<LxdNetworkAddress> get ipv4s {
    return addresses.where((address) => address.isIPv4).toList();
  }

  List<LxdNetworkAddress> get ipv6s {
    return addresses.where((address) => address.isIPv6).toList();
  }
}

extension LxdOperationX on LxdOperation {
  double? get progressValue =>
      (metadata?['progress']?['percentage'] as int?).asProgressValue;
  String? get downloadProgress => metadata?['download_progress'] as String?;
  String? get unpackProgress =>
      metadata?['create_instance_from_image_unpack_progress'] as String?;
}

extension _Percentage on int? {
  double? get asProgressValue => this != null ? this! / 100.0 : null;
}
