import 'package:lxd/lxd.dart';

extension LxdEventX on LxdEvent {
  bool get isOperation => type == LxdEventType.operation;
  LxdOperation toOperation() {
    return LxdOperation.fromJson(metadata ?? <String, dynamic>{});
  }
}

extension LxdOperationX on LxdOperation {
  List<String>? get instances => (resources['instances'] as List?)
      ?.cast<String>()
      .map((path) => path.split('/').last)
      .toList();
}
