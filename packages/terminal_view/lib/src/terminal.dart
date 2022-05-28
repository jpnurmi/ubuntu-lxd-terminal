import 'package:flutter/foundation.dart';
import 'package:lxd_x/lxd_x.dart';
import 'package:xterm/theme/terminal_theme.dart' as xterm;
import 'package:xterm/theme/terminal_themes.dart' as xterm;
import 'package:xterm/xterm.dart' as xterm;

import 'terminal_backend.dart';
import 'terminal_theme.dart';

class Terminal extends ChangeNotifier {
  Terminal({
    required this.client,
    required this.instance,
    int? maxLines,
    TerminalThemeData? theme,
    this.onExit,
  })  : _maxLines = maxLines,
        _theme = theme;

  final LxdClient client;
  final String instance;
  final VoidCallback? onExit;

  int? _maxLines;
  xterm.Terminal? _xterm;
  TerminalThemeData? _theme;

  xterm.Terminal buildXterm({int? maxLines, TerminalThemeData? theme}) {
    if (_xterm == null || _theme != theme || _maxLines != maxLines) {
      _maxLines = maxLines;
      _theme = theme;
      _xterm = _rebuildXterm(
        maxLines ?? 10000, // TODO
        theme?.palette.toXtermTheme() ?? xterm.TerminalThemes.defaultTheme,
      );
    }
    return _xterm!;
  }

  xterm.Terminal _rebuildXterm(int maxLines, xterm.TerminalTheme theme) {
    return xterm.Terminal(
      backend: LxdTerminalBackend(
        client: client,
        instance: instance,
        onExit: onExit,
      ),
      maxLines: maxLines,
      theme: theme,
      onTitleChange: _setTitle,
    );
  }

  String? _title;
  String? get title => _title;
  void _setTitle(String title) {
    if (_title == title) return;
    _title = title;
    notifyListeners();
  }

  void paste(String data) => _xterm?.paste(data);
  String? get selectedText => _xterm?.selectedText;
  void selectAll() => _xterm?.selectAll();
}

extension _XtermTheme on TerminalPalette {
  xterm.TerminalTheme toXtermTheme() {
    return xterm.TerminalTheme(
      cursor: cursor.value,
      selection: selection.value,
      foreground: foreground.value,
      background: background.value,
      black: black.value,
      red: red.value,
      green: green.value,
      yellow: yellow.value,
      blue: blue.value,
      magenta: magenta.value,
      cyan: cyan.value,
      white: white.value,
      brightBlack: brightBlack.value,
      brightRed: brightRed.value,
      brightGreen: brightGreen.value,
      brightYellow: brightYellow.value,
      brightBlue: brightBlack.value,
      brightMagenta: brightMagenta.value,
      brightCyan: brightCyan.value,
      brightWhite: brightWhite.value,
      searchHitBackground: searchHitBackground.value,
      searchHitBackgroundCurrent: searchHitBackgroundCurrent.value,
      searchHitForeground: searchHitForeground.value,
    );
  }
}



// final terminalStyle = StateProvider<TerminalStyle>((ref) {
//   return const TerminalStyle(
//     fontSize: 18,
//     fontFamily: 'Ubuntu Mono',
//   );
// });


// xterm.TerminalTheme(
//   cursor: theme?.cursor.value 0xffffffff,
//   selection: 0Xffffffff,
//   foreground: 0xffffffff,
//   background: 0xff380c2a,
//   black: 0XFF000000,
//   red: 0XFFCD3131,
//   green: 0XFF0DBC79,
//   yellow: 0XFFE5E510,
//   blue: 0XFF2472C8,
//   magenta: 0XFFBC3FBC,
//   cyan: 0XFF11A8CD,
//   white: 0XFFE5E5E5,
//   brightBlack: 0XFF666666,
//   brightRed: 0XFFF14C4C,
//   brightGreen: 0XFF23D18B,
//   brightYellow: 0XFFF5F543,
//   brightBlue: 0XFF3B8EEA,
//   brightMagenta: 0XFFD670D6,
//   brightCyan: 0XFF29B8DB,
//   brightWhite: 0XFFFFFFFF,
//   searchHitBackground: 0XFFFFFF2B,
//   searchHitBackgroundCurrent: 0XFF31FF26,
//   searchHitForeground: 0XFF000000,
// )
