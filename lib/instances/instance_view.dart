import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';

import '../lxd.dart';
import 'instance_store.dart';

class InstanceView extends ConsumerWidget {
  const InstanceView({
    super.key,
    this.selected,
    this.onSelect,
    this.onStop,
    this.onDelete,
  });

  final LxdInstance? selected;
  final ValueChanged<LxdInstance>? onSelect;
  final ValueChanged<LxdInstance>? onStop;
  final ValueChanged<LxdInstance>? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instances = ref.watch(instanceStore);
    return instances.map(
      data: (data) => _InstanceListView(
        instances: data.value,
        selected: selected,
        onSelect: onSelect,
        onStop: onStop,
        onDelete: onDelete,
      ),
      loading: (loading) => _InstanceListView(
        instances: loading.value,
        selected: selected,
        onSelect: onSelect,
        onStop: onStop,
        onDelete: onDelete,
      ),
      error: (error) => Text('TODO: ${error.error}'),
    );
  }
}

class _InstanceListView extends StatelessWidget {
  const _InstanceListView({
    required this.instances,
    this.selected,
    this.onSelect,
    this.onStop,
    this.onDelete,
  });

  final List<LxdInstance>? instances;
  final LxdInstance? selected;
  final ValueChanged<LxdInstance>? onSelect;
  final ValueChanged<LxdInstance>? onStop;
  final ValueChanged<LxdInstance>? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: instances?.length ?? 0,
      itemBuilder: (context, index) {
        final instance = instances![index];
        final canStop = onStop != null && instance.isRunning;
        final canDelete = onDelete != null && instance.isStopped;
        return ListTile(
          title: Text(instance.name),
          subtitle: Text(instance.status),
          trailing: canStop
              ? _StopButton(() => onStop!.call(instance))
              : canDelete
                  ? _DeleteButton(() => onDelete!.call(instance))
                  : null,
          onTap: () => onSelect?.call(instance),
        );
      },
    );
  }
}

class _IconButton extends IconButton {
  const _IconButton({required super.icon, super.onPressed})
      : super(splashRadius: 16, iconSize: 16);
}

class _StopButton extends _IconButton {
  const _StopButton(VoidCallback onPressed)
      : super(icon: const Icon(Icons.stop), onPressed: onPressed);
}

class _DeleteButton extends _IconButton {
  const _DeleteButton(VoidCallback onPressed)
      : super(icon: const Icon(Icons.close), onPressed: onPressed);
}
