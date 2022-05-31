import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class OperatingSystemLogo extends StatefulWidget {
  const OperatingSystemLogo({
    super.key,
    required this.name,
    required this.size,
  });

  final String name;
  final int size;

  @override
  State<OperatingSystemLogo> createState() => _OperatingSystemLogoState();
}

class _OperatingSystemLogoState extends State<OperatingSystemLogo> {
  static final _cache = <int, ImageProvider<Object>?>{};
  ImageProvider<Object>? _logo;

  @override
  void initState() {
    super.initState();
    _updateLogo();
  }

  void _updateLogo() {
    final key = Object.hash(widget.name, widget.size);
    _logo = _cache[key];

    if (!_cache.containsKey(key)) {
      findOperatingSystemLogo(widget.name, size: widget.size).then((logo) {
        _cache[key] = logo;
        if (mounted) {
          setState(() => _logo = logo);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_logo != null) {
      return Image(image: _logo!);
    } else {
      return SizedBox.square(dimension: widget.size.toDouble());
    }
  }

  @override
  void didUpdateWidget(covariant OperatingSystemLogo oldWidget) {
    if (widget.name != oldWidget.name || widget.size != oldWidget.size) {
      _updateLogo();
    }
    super.didUpdateWidget(oldWidget);
  }
}

Future<ImageProvider<Object>?> findOperatingSystemLogo(
  String name, {
  required int size,
}) async {
  assert(size == 16 ||
      size == 24 ||
      size == 32 ||
      size == 48 ||
      size == 64 ||
      size == 128);

  final os = await findOperatingSystem(name);
  if (os == null) return null;

  return AssetImage(
    'assets/src/${size}x$size/${os.code}.png',
    package: 'operating_system_logos',
  );
}

Future<OperatingSystem?> findOperatingSystem(String str) async {
  final operatingSystems = await getOperatingSystems();
  const aliases = {
    'archlinux': 'arch-linux',
    'opensuse': 'suse',
  };
  final alias = aliases[str] ?? str;
  return operatingSystems.firstWhereOrNull(
      (os) => alias == os.code || alias == os.name || alias == os.slug);
}

List<OperatingSystem>? _operatingSystems;
Future<List<OperatingSystem>> getOperatingSystems() async {
  _operatingSystems ??= await rootBundle.loadStructuredData(
    'packages/operating_system_logos/assets/src/os-list.json',
    (data) async => (jsonDecode(data) as List)
        .map((json) => OperatingSystem.fromJson(json as Map<String, dynamic>))
        .toList(),
  );
  return _operatingSystems!;
}

@immutable
class OperatingSystem {
  const OperatingSystem({
    required this.code,
    required this.name,
    required this.slug,
  });

  final String code;
  final String name;
  final String slug;

  factory OperatingSystem.fromJson(Map<String, dynamic> json) {
    return OperatingSystem(
      code: json['code'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'slug': slug};
  }

  @override
  String toString() => 'OperatingSystem(code: $code, name: $name, slug: $slug)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OperatingSystem &&
        other.code == code &&
        other.name == name &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(code, name, slug);
}
