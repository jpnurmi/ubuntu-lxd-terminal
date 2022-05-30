import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lxd_service/lxd_service.dart';
import 'package:movable_tabs/movable_tabs.dart';
import 'package:provider/provider.dart';
import 'package:terminal_view/terminal_view.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../launcher/launcher_view.dart';
import '../operations/operation_view.dart';
import '../terminal/terminal_settings.dart';
import 'context_menu.dart';
import 'home_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeModel(getService<LxdService>()),
      child: const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeModel>();
    final current = model.currentTerminal;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyT,
          control: true,
          shift: true,
          includeRepeats: false,
        ): model.add,
        if (model.length > 1)
          const SingleActivator(
            LogicalKeyboardKey.keyW,
            control: true,
            shift: true,
            includeRepeats: false,
          ): model.close,
        const SingleActivator(
          LogicalKeyboardKey.pageUp,
          control: true,
        ): model.prev,
        const SingleActivator(
          LogicalKeyboardKey.pageDown,
          control: true,
        ): model.next,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: model.length <= 1
              ? null
              : MovableTabBar(
                  count: model.length,
                  builder: (context, index) {
                    final terminal = model.terminal(index)!;
                    return MovableTabButton(
                      selected: index == model.currentIndex,
                      onPressed: () => model.currentIndex = index,
                      onClosed: () => model.closeAt(index),
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
                  trailing: ContextMenuButton(
                    current: model.currentRunning,
                    terminals: model.terminals,
                    onNewTab: model.add,
                    onCloseTab: model.close,
                  ),
                  onMoved: model.move,
                  preferredHeight: Theme.of(context).appBarTheme.toolbarHeight,
                ),
          body: ContextMenuArea(
            current: model.currentRunning,
            terminals: model.terminals,
            onNewTab: model.add,
            onCloseTab: model.close,
            child: current.when(
              none: () => LauncherView(
                onStart: model.start,
                onCreate: model.create,
                onDelete: model.delete,
                onStop: model.stop,
              ),
              loading: (op) => OperationView.create(context, op.id),
              running: (terminal) => TerminalTheme(
                data: terminalTheme,
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
