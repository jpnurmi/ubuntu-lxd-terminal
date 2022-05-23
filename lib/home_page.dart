import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'launch_view.dart';
import 'lxd.dart';
import 'terminal/terminal_store.dart';
import 'terminal/terminal_view.dart';
import 'widgets/loading_indicator.dart';
import 'widgets/movable_tabs.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(terminalStore);
    final current = ref.watch(currentTerminal);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyT,
          control: true,
          shift: true,
          includeRepeats: false,
        ): ref.read(terminalStore.notifier).add,
        if (tabs.length > 1)
          const SingleActivator(
            LogicalKeyboardKey.keyW,
            control: true,
            shift: true,
            includeRepeats: false,
          ): ref.read(terminalStore.notifier).close,
        const SingleActivator(
          LogicalKeyboardKey.pageUp,
          control: true,
        ): ref.read(terminalStore.notifier).prev,
        const SingleActivator(
          LogicalKeyboardKey.pageDown,
          control: true,
        ): ref.read(terminalStore.notifier).next,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: tabs.length <= 1
              ? null
              : MovableTabBar(
                  count: tabs.length,
                  builder: (context, index) {
                    return MovableTabButton(
                      selected: index == ref.watch(currentIndex),
                      onPressed: () =>
                          ref.read(currentIndex.state).state = index,
                      onClosed: () =>
                          ref.read(terminalStore.notifier).closeAt(index),
                      label: const Text('Terminal'), // TODO: title
                    );
                  },
                  onMoved: ref.read(terminalStore.notifier).move,
                  preferredHeight: Theme.of(context).appBarTheme.toolbarHeight,
                ),
          body: current.when(
            none: () => LaunchView(
              onStart: ref.read(terminalStore.notifier).start,
              onCreate: ref.read(terminalStore.notifier).create,
              onDelete: (i) => ref.read(lxdClient).deleteInstance(i.name),
              onStop: (i) => ref.read(lxdClient).stopInstance(i.name),
            ),
            creating: (image, name) => const LoadingIndicator(),
            starting: (instance) => const LoadingIndicator(),
            running: (instance, terminal) => TerminalView(
              instance: instance,
              terminal: terminal,
            ),
            error: (error) => Text('TODO: $error'),
          ),
        ),
      ),
    );
  }
}
