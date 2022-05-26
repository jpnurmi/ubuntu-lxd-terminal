import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_x/lxd_x.dart';

import 'instance_provider.dart';

class InstanceView extends ConsumerWidget {
  const InstanceView({
    super.key,
    this.selected,
    this.onSelect,
    this.onStop,
    this.onDelete,
  });

  final String? selected;
  final ValueChanged<String>? onSelect;
  final ValueChanged<String>? onStop;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instances = ref.watch(instanceStream);
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

  final List<String>? instances;
  final String? selected;
  final ValueChanged<String>? onSelect;
  final ValueChanged<String>? onStop;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: instances?.length ?? 0,
      itemBuilder: (context, index) {
        final name = instances![index];
        return _InstanceListTile(
          name: name,
          onSelect: onSelect != null ? () => onSelect!(name) : null,
          onStop: onStop != null ? () => onStop!(name) : null,
          onDelete: onDelete != null ? () => onDelete!(name) : null,
        );
      },
    );
  }
}

class _InstanceListTile extends ConsumerWidget {
  const _InstanceListTile({
    required this.name,
    this.onSelect,
    this.onStop,
    this.onDelete,
  });

  final String name;
  final VoidCallback? onSelect;
  final VoidCallback? onStop;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instance = ref.watch(instanceState(name));
    final canStop = onStop != null && instance.valueOrNull?.isRunning == true;
    final canDelete =
        onDelete != null && instance.valueOrNull?.isStopped == true;
    return ListTile(
      title: Text(instance.valueOrNull?.name ?? ''),
      subtitle: Text(instance.valueOrNull?.status ?? ''),
      trailing: canStop
          ? _StopButton(onStop!)
          : canDelete
              ? _DeleteButton(onDelete!)
              : null,
      onTap: onSelect,
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
