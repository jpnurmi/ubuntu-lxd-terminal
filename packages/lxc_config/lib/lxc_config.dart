library lxc_config;

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

extension LxcConfig on YamlMap {
  String? get defaultRemote => this['default-remote'] as String?;
  List<String>? get remotes =>
      (this['remotes'] as YamlMap?)?.keys.toList().cast() ?? [];
  String? address(String remote) => this['remotes'][remote]['addr'] as String?;
  String? protocol(String remote) =>
      this['remotes'][remote]['protocol'] as String?;
  bool? isPublic(String remote) => this['remotes'][remote]['public'] as bool?;
  Map<String, String>? get aliases => (this['aliases'] as YamlMap?)?.cast();
}

Future<String?> locateLxcConfig({
  @visibleForTesting Map<String, String>? environment,
}) async {
  final env = environment ?? Platform.environment;
  final dirs = [
    env['LXD_CONF'],
    p.join(env['HOME']!, 'snap', 'lxd', 'common', 'config'),
    p.join(env['HOME']!, '.config', 'lxc'),
  ].whereType<String>();
  for (final dir in dirs) {
    final file = File(p.join(dir, 'config.yml'));
    if (file.existsSync()) return file.path;
  }
  return null;
}
