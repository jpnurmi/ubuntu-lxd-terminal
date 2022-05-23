import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lxd/lxd.dart';
import 'package:xterm/xterm.dart';

part 'terminal_state.freezed.dart';

@freezed
class TerminalState with _$TerminalState {
  const factory TerminalState.none() = TerminalNone;
  const factory TerminalState.error([String? message]) = TerminalError;
  const factory TerminalState.creating({
    required LxdRemoteImage image,
    required String? name,
  }) = TerminalCreating;
  const factory TerminalState.starting(LxdInstance instance) = TerminalStarting;
  const factory TerminalState.running({
    required LxdInstance instance,
    required Terminal terminal,
  }) = TerminalRunning;
}
