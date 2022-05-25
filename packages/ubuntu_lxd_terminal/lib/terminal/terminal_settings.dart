import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/theme/terminal_theme.dart';

class TerminalStyle {
  const TerminalStyle({
    required this.fontSize,
    required this.fontFamily,
  });
  final double fontSize;
  final String fontFamily;
}

final terminalStyle = StateProvider<TerminalStyle>((ref) {
  return const TerminalStyle(
    fontSize: 18,
    fontFamily: 'Ubuntu Mono',
  );
});

// TODO: configurable
const terminalTheme = TerminalTheme(
  cursor: 0xffffffff,
  selection: 0Xffffffff,
  foreground: 0xffffffff,
  background: 0xff380c2a,
  black: 0XFF000000,
  red: 0XFFCD3131,
  green: 0XFF0DBC79,
  yellow: 0XFFE5E510,
  blue: 0XFF2472C8,
  magenta: 0XFFBC3FBC,
  cyan: 0XFF11A8CD,
  white: 0XFFE5E5E5,
  brightBlack: 0XFF666666,
  brightRed: 0XFFF14C4C,
  brightGreen: 0XFF23D18B,
  brightYellow: 0XFFF5F543,
  brightBlue: 0XFF3B8EEA,
  brightMagenta: 0XFFD670D6,
  brightCyan: 0XFF29B8DB,
  brightWhite: 0XFFFFFFFF,
  searchHitBackground: 0XFFFFFF2B,
  searchHitBackgroundCurrent: 0XFF31FF26,
  searchHitForeground: 0XFF000000,
);
