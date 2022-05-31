import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

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
  return operatingSystems.firstWhereOrNull(
      (os) => str == os.code || str == os.name || str == os.slug);
}

List<OperatingSystem>? _operatingSystems;
Future<List<OperatingSystem>> getOperatingSystems() async {
  _operatingSystems ??= await rootBundle.loadStructuredData(
    'assets/src/os-list.json',
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
