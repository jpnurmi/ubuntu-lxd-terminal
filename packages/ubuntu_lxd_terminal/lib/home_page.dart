import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movable_tabs/movable_tabs.dart';
import 'package:native_context_menu/native_context_menu.dart' as n;

import 'launch_view.dart';
import 'lxd.dart';
import 'operations/operation_view.dart';
import 'terminal/terminal_state.dart';
import 'terminal/terminal_store.dart';
import 'terminal/terminal_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(terminalStore);
    final current = ref.watch(currentTerminal);

    Future<void> onCopy() async {
      if (current is! TerminalRunning) return;
      final data = ClipboardData(text: current.terminal.selectedText);
      return Clipboard.setData(data);
    }

    Future<void> onPaste() async {
      if (current is! TerminalRunning) return;
      final data = await Clipboard.getData('text/plain');
      current.terminal.paste(data?.text ?? '');
    }

    void onSelectAll() {
      if (current is! TerminalRunning) return;
      current.terminal.selectAll();
    }

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
                          ref.read(currentIndex.state).update((_) => index),
                      onClosed: () =>
                          ref.read(terminalStore.notifier).closeAt(index),
                      label: const Text('Terminal'), // TODO: title
                    );
                  },
                  onMoved: ref.read(terminalStore.notifier).move,
                  preferredHeight: Theme.of(context).appBarTheme.toolbarHeight,
                ),
          body: n.ContextMenuRegion(
            onItemSelected: (dynamic item) => item.action?.call(),
            menuItems: <n.MenuItem>[
              if (current is TerminalRunning)
                n.MenuItem(title: 'Copy', action: onCopy),
              if (current is TerminalRunning)
                n.MenuItem(title: 'Paste', action: onPaste),
              if (current is TerminalRunning)
                n.MenuItem(title: 'Select All', action: onSelectAll),
              n.MenuItem(
                  title: 'New Tab',
                  action: ref.read(terminalStore.notifier).add),
              if (tabs.length > 1)
                n.MenuItem(
                    title: 'Close Tab',
                    action: ref.read(terminalStore.notifier).close),
            ],
            child: current.when(
              none: () => LaunchView(
                onStart: ref.read(terminalStore.notifier).start,
                onCreate: ref.read(terminalStore.notifier).create,
                onDelete: ref.read(lxdClient).deleteInstance,
                onStop: ref.read(lxdClient).stopInstance,
              ),
              loading: (op) => OperationView(
                id: op.id,
                onCancel: () => ref.read(lxdClient).cancelOperation(op.id),
              ),
              running: (instance, terminal) => TerminalView(
                instance: instance,
                terminal: terminal,
              ),
              error: (error) => Text('TODO: $error'),
            ),
          ),
        ),
      ),
    );
  }
}
