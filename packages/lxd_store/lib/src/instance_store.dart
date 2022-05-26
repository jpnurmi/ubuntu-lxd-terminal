import 'dart:async';

import 'package:lxd/lxd.dart';
import 'package:rxdart/rxdart.dart';

import 'lxd_x.dart';

abstract class InstanceStore {
  factory InstanceStore(LxdClient client) => _LxdInstanceStore(client);

  Future<void> init();
  Future<void> dispose();

  List<String>? get instances;
  Stream<List<String>> get stream;

  Stream<String> get onAdded;
  Stream<String> get onRemoved;
  Stream<String> get onUpdated;
}

class _LxdInstanceStore implements InstanceStore {
  _LxdInstanceStore(this._client);

  final LxdClient _client;
  StreamSubscription? _events;
  final _instances = BehaviorSubject<List<String>>();
  final _added = StreamController<String>.broadcast();
  final _removed = StreamController<String>.broadcast();
  final _updated = StreamController<String>.broadcast();

  List<String>? get instances => _instances.valueOrNull;
  Stream<List<String>> get stream => _instances.stream;

  Stream<String> get onAdded => _added.stream;
  Stream<String> get onRemoved => _removed.stream;
  Stream<String> get onUpdated => _updated.stream;

  @override
  Future<void> init() async {
    _instances.add(await _client.getInstances());
    _events ??= _client.getEvents(types: {LxdEventType.operation}).where((ev) {
      return ev.toOperation().instances?.isNotEmpty == true;
    }).listen(_updateInstances);
  }

  @override
  Future<void> dispose() async {
    await _events?.cancel();
    await Future.wait<void>([
      _added.close(),
      _removed.close(),
      _updated.close(),
      _instances.close(),
    ]);
  }

  Future<void> _updateInstances([LxdEvent? event]) async {
    final newInstances = await _client.getInstances();
    final newInstanceSet = Set.of(newInstances);
    final oldInstanceSet = Set.of(instances ?? const <String>[]);

    final added = newInstanceSet.difference(oldInstanceSet);
    for (final instance in added) {
      _added.add(instance);
    }

    final removed = oldInstanceSet.difference(newInstanceSet);
    for (final instance in removed) {
      _removed.add(instance);
    }

    if (event != null) {
      final updated = event.toOperation().instances ?? [];
      for (final instance in updated) {
        final name = instance.split('/').last;
        if (!added.contains(name) &&
            !removed.contains(name) &&
            oldInstanceSet.contains(name)) {
          _updated.add(name);
        }
      }
    }

    _instances.add(newInstances);
  }
}
