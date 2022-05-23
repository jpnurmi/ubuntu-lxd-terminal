import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxd/lxd.dart';
import 'package:xterm/xterm.dart';

import '../lxd.dart';
import 'terminal_backend.dart';
import 'terminal_settings.dart';
import 'terminal_state.dart';

final currentIndex = StateProvider<int>((_) => 0);

final currentTerminal = Provider((ref) {
  final index = ref.watch(currentIndex);
  return ref.watch(terminalStore).elementAtOrNull(index) ??
      const TerminalState.none();
});

final terminalStore =
    StateNotifierProvider<TerminalStore, List<TerminalState>>((ref) {
  return TerminalStore(ref.read);
});

class TerminalStore extends StateNotifier<List<TerminalState>> {
  TerminalStore(this._read) : super([const TerminalState.none()]);

  final Reader _read;

  void add([TerminalState terminal = const TerminalState.none()]) {
    state = [...state, terminal];

    _setCurrentIndex(state.length - 1);
  }

  void close() => closeAt(_read(currentIndex));

  void closeAt(int index) {
    state = List.of(state)..removeAt(index);

    final current = _read(currentIndex);
    _setCurrentIndex(current.clamp(0, state.length - 1));
  }

  void move(int from, int to) {
    state = List.of(state)..move(from, to);

    final current = _read(currentIndex);
    if (current == to) {
      _setCurrentIndex(from);
    } else if (current == from) {
      _setCurrentIndex(to);
    }
  }

  void next() {
    final index = _read(currentIndex) + 1;
    _setCurrentIndex(index % state.length);
  }

  void prev() {
    final index = _read(currentIndex) - 1;
    _setCurrentIndex(index < 0 ? state.length - 1 : index);
  }

  Future<void> create(LxdRemoteImage image, [String? name]) async {
    final client = _read(lxdClient);

    _setCurrentState(TerminalState.creating(image: image, name: name));

    final op = await client.createInstance(image: image, name: name);
    await client.waitOperation(op.id);

    name = (op.resources['instances'].single as String).split('/').last;
    return start(await client.getInstance(name));
  }

  Future<void> start(LxdInstance instance) async {
    final client = _read(lxdClient);

    _setCurrentState(TerminalState.starting(instance));

    final op = await client.startInstance(instance.name);
    await client.waitOperation(op.id);

    return run(instance);
  }

  Future<void> run(LxdInstance instance) async {
    final client = _read(lxdClient);

    _setCurrentState(
      TerminalState.running(
        instance: instance,
        terminal: Terminal(
          backend: LxdTerminalBackend(
            client: client,
            instance: instance.name,
            onExit: reset,
          ),
          maxLines: 10000, // TODO: configurable
          theme: terminalTheme,
          onTitleChange: (t) {
            // TODO: update terminal title?
          },
        ),
      ),
    );
  }

  void reset() => _setCurrentState(const TerminalState.none());

  void _setCurrentIndex(int index) {
    _read(currentIndex.state).state = index;
  }

  void _setCurrentState(TerminalState terminal) {
    final index = _read(currentIndex);
    state = List.of(state)..replace(index, terminal);
  }
}

extension ListX<T> on List<T> {
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  void move(int from, int to) {
    final tmp = this[from];
    this[from] = this[to];
    this[to] = tmp;
  }

  void replace(int index, T value) {
    this[index] = value;
  }
}
