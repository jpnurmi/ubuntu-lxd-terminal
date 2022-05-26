import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_x/lxd_x.dart';

import 'operation_events.dart';
import 'operation_x.dart';

class OperationView extends ConsumerWidget {
  const OperationView({super.key, required this.id, this.onCancel});

  final String id;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final op = ref.watch(instanceOperations(id));
    return Scaffold(
      body: Center(
        child: op.map(
          data: (data) => _OperationView(op: data.value, onCancel: onCancel),
          error: (error) => Text('TODO: ${error.error}'),
          loading: (loading) => _OperationView(op: loading.value),
        ),
      ),
    );
  }
}

class _OperationView extends StatelessWidget {
  const _OperationView({required this.op, this.onCancel});

  final LxdOperation? op;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(
              dimension: 96,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 48),
            Text(
              op?.description ?? 'Preparing...',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: SizedBox(
          height: Theme.of(context).appBarTheme.toolbarHeight,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    op?.downloadProgress ?? op?.unpackProgress ?? 'Please wait',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  if (onCancel != null && op?.mayCancel == true)
                    OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
