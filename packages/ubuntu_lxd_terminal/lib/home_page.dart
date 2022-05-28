import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:movable_tabs/movable_tabs.dart';
import 'package:native_context_menu/native_context_menu.dart' as n;
import 'package:ubuntu_service/ubuntu_service.dart';

import 'home_controller.dart';
import 'launch_view.dart';
import 'operations/operation_view.dart';
import 'terminal/terminal_state.dart';
import 'terminal/terminal_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(homeController);
    final current = controller.currentTerminal ?? const TerminalState.none();

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyT,
          control: true,
          shift: true,
          includeRepeats: false,
        ): controller.add,
        if (controller.length > 1)
          const SingleActivator(
            LogicalKeyboardKey.keyW,
            control: true,
            shift: true,
            includeRepeats: false,
          ): controller.close,
        const SingleActivator(
          LogicalKeyboardKey.pageUp,
          control: true,
        ): controller.prev,
        const SingleActivator(
          LogicalKeyboardKey.pageDown,
          control: true,
        ): controller.next,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: controller.length <= 1
              ? null
              : MovableTabBar(
                  count: controller.length,
                  builder: (context, index) {
                    return MovableTabButton(
                      selected: index == controller.currentIndex,
                      onPressed: () => controller.currentIndex = index,
                      onClosed: () => controller.closeAt(index),
                      label: const Text('Terminal'), // TODO: title
                    );
                  },
                  onMoved: controller.move,
                  preferredHeight: Theme.of(context).appBarTheme.toolbarHeight,
                ),
          body: n.ContextMenuRegion(
            onItemSelected: (dynamic item) => item.action?.call(),
            menuItems: <n.MenuItem>[
              if (current is TerminalRunning)
                n.MenuItem(title: 'Copy', action: controller.copy),
              if (current is TerminalRunning)
                n.MenuItem(title: 'Paste', action: controller.paste),
              if (current is TerminalRunning)
                n.MenuItem(title: 'Select All', action: controller.selectAll),
              n.MenuItem(title: 'New Tab', action: controller.add),
              if (controller.length > 1)
                n.MenuItem(title: 'Close Tab', action: controller.close),
            ],
            child: current.when(
              none: () => LaunchView(
                onStart: controller.start,
                onCreate: controller.create,
                onDelete: getService<LxdService>().deleteInstance,
                onStop: getService<LxdService>().stopInstance,
              ),
              loading: (op) => OperationView(
                id: op.id,
                onCancel: () => getService<LxdService>().cancelOperation(op.id),
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
