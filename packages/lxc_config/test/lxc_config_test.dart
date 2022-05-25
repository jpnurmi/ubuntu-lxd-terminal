import 'package:lxc_config/lxc_config.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('yaml', () async {
    final yaml = loadYaml(
      '''
default-remote: local
remotes:
  images:
    addr: https://images.linuxcontainers.org
    protocol: simplestreams
    public: true
  local:
    addr: unix://
    public: false
aliases: {}
''',
    ) as YamlMap;

    expect(yaml.defaultRemote, 'local');
    expect(yaml.remotes, ['images', 'local']);

    expect(yaml.address('images'), 'https://images.linuxcontainers.org');
    expect(yaml.protocol('images'), 'simplestreams');
    expect(yaml.isPublic('images'), true);

    expect(yaml.address('local'), 'unix://');
    expect(yaml.protocol('local'), null);
    expect(yaml.isPublic('local'), false);

    expect(yaml.aliases, isEmpty);
  });
}
