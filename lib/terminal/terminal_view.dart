import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';
import 'package:xterm/flutter.dart' as x;
import 'package:xterm/xterm.dart' as x;

import 'terminal_settings.dart';

class TerminalView extends ConsumerWidget {
  const TerminalView({
    super.key,
    required this.instance,
    required this.terminal,
  });

  final LxdInstance instance;
  final x.Terminal terminal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(terminalStyle);
    return FocusScope(
      child: x.TerminalView(
        padding: 2,
        autofocus: true,
        terminal: terminal,
        style: x.TerminalStyle(
          fontSize: style.fontSize,
          fontFamily: [
            style.fontFamily,
            ...x.TerminalStyle.defaultFontFamily,
          ],
        ),
      ),
    );
  }
}
