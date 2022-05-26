import 'dart:async';

import 'package:lxd_store/lxd_store.dart';
import 'package:lxd_x/lxd_x.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'instance_store_test.mocks.dart';

@GenerateMocks([LxdClient])
void main() {
  test('init', () async {
    final client = MockLxdClient();
    final events = StreamController<LxdEvent>();
    when(client.getEvents(types: {LxdEventType.operation}))
        .thenAnswer((_) => events.stream);
    when(client.getInstances()).thenAnswer((_) async => ['foo']);

    final store = InstanceStore(client);
    expect(store.instances, isNull);

    await store.init();
    verify(client.getEvents(types: {LxdEventType.operation})).called(1);
    verify(client.getInstances()).called(1);

    expect(store.instances, ['foo']);
    expect(store.stream, emits(['foo']));

    expect(store.onAdded, neverEmits(anything));
    expect(store.onRemoved, neverEmits(anything));
    expect(store.onUpdated, neverEmits(anything));

    await store.dispose();
  });

  test('add', () async {
    final client = MockLxdClient();
    final events = StreamController<LxdEvent>();
    when(client.getEvents(types: {LxdEventType.operation}))
        .thenAnswer((_) => events.stream);
    when(client.getInstances()).thenAnswer((_) async => ['foo']);

    final store = InstanceStore(client);
    await store.init();

    when(client.getInstances()).thenAnswer((_) async => ['foo', 'bar']);

    events.add(LxdEvent(
      type: LxdEventType.operation,
      metadata: testOperation(instances: ['bar']).toJson(),
      timestamp: DateTime.now(),
    ));

    await expectLater(store.onAdded, emits('bar'));
    expect(store.onRemoved, neverEmits(anything));
    expect(store.onUpdated, neverEmits(anything));

    expect(store.instances, ['foo', 'bar']);
    expect(store.stream, emits(['foo', 'bar']));

    await store.dispose();
  });

  test('remove', () async {
    final client = MockLxdClient();
    final events = StreamController<LxdEvent>();
    when(client.getEvents(types: {LxdEventType.operation}))
        .thenAnswer((_) => events.stream);
    when(client.getInstances()).thenAnswer((_) async => ['foo', 'bar']);

    final store = InstanceStore(client);
    await store.init();

    when(client.getInstances()).thenAnswer((_) async => ['bar']);

    events.add(LxdEvent(
      type: LxdEventType.operation,
      metadata: testOperation(instances: ['foo']).toJson(),
      timestamp: DateTime.now(),
    ));

    expect(store.onAdded, neverEmits(anything));
    await expectLater(store.onRemoved, emits('foo'));
    expect(store.onUpdated, neverEmits(anything));

    expect(store.instances, ['bar']);
    expect(store.stream, emits(['bar']));

    await store.dispose();
  });

  test('update', () async {
    final client = MockLxdClient();
    final events = StreamController<LxdEvent>();
    when(client.getEvents(types: {LxdEventType.operation}))
        .thenAnswer((_) => events.stream);
    when(client.getInstances()).thenAnswer((_) async => ['foo', 'bar', 'baz']);

    final store = InstanceStore(client);
    await store.init();

    when(client.getInstances()).thenAnswer((_) async => ['foo', 'bar', 'baz']);

    events.add(LxdEvent(
      type: LxdEventType.operation,
      metadata: testOperation(instances: ['bar']).toJson(),
      timestamp: DateTime.now(),
    ));

    expect(store.onAdded, neverEmits(anything));
    expect(store.onRemoved, neverEmits(anything));
    await expectLater(store.onUpdated, emits('bar'));

    expect(store.instances, ['foo', 'bar', 'baz']);
    expect(store.stream, emits(['foo', 'bar', 'baz']));

    await store.dispose();
  });
}

LxdOperation testOperation({List<String>? instances}) {
  return LxdOperation(
    createdAt: DateTime.now(),
    description: '',
    error: '',
    id: '',
    location: '',
    mayCancel: false,
    metadata: null,
    resources: {'instances': instances ?? []},
    status: '',
    statusCode: 200,
    type: LxdOperationType.task,
    updatedAt: DateTime.now(),
  );
}
