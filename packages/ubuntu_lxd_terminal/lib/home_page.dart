import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:movable_tabs/movable_tabs.dart';
import 'package:terminal_view/terminal_view.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'home_controller.dart';
import 'launch_view.dart';
import 'operations/operation_view.dart';
import 'terminal/terminal_settings.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(homeController);
    final current = controller.currentTerminal;

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
                    final terminal = controller.terminal(index)!;
                    return MovableTabButton(
                      selected: index == controller.currentIndex,
                      onPressed: () => controller.currentIndex = index,
                      onClosed: () => controller.closeAt(index),
                      label: terminal.maybeWhen(
                        running: (running) => AnimatedBuilder(
                          animation: running,
                          builder: (context, child) {
                            return Text(running.title ?? 'Terminal');
                          },
                        ),
                        orElse: () => const Text('Terminal'),
                      ),
                    );
                  },
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    splashRadius: 16,
                    iconSize: 16,
                    itemBuilder: (context) => buildMenuItems(context, ref),
                  ),
                  onMoved: controller.move,
                  preferredHeight: Theme.of(context).appBarTheme.toolbarHeight,
                ),
          body: GestureDetector(
            onSecondaryTapDown: (details) {
              showMenu(
                context: context,
                position: RelativeRect.fromSize(
                  details.globalPosition & Size.zero,
                  MediaQuery.of(context).size,
                ),
                items: buildMenuItems(context, ref),
              );
            },
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
              running: (terminal) => TerminalTheme(
                data: ref.watch(terminalTheme),
                child: TerminalView(terminal: terminal),
              ),
              error: (error) => Text('TODO: $error'),
            ),
          ),
        ),
      ),
    );
  }
}

List<PopupMenuEntry> buildMenuItems(BuildContext context, WidgetRef ref) {
  final controller = ref.watch(homeController);
  final running = controller.currentRunning;
  return <PopupMenuEntry>[
    PopupMenuItem(
      onTap: controller.add,
      child: const Text('New Tab'),
    ),
    PopupMenuItem(
      onTap: controller.close,
      enabled: controller.length > 1,
      child: const Text('Close Tab'),
    ),
    const PopupMenuDivider(),
    PopupMenuItem(
      onTap: controller.copy,
      enabled: running?.selectedText?.isNotEmpty == true,
      child: const Text('Copy'),
    ),
    PopupMenuItem(
      onTap: controller.paste,
      enabled: running != null,
      child: const Text('Paste'),
    ),
    PopupMenuItem(
      onTap: controller.selectAll,
      enabled: running != null,
      child: const Text('Select All'),
    ),
  ];
}
