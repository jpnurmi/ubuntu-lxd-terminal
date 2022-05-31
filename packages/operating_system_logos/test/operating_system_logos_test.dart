import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:operating_system_logos/operating_system_logos.dart';

void main() {
  testWidgets('UBT 16', (tester) async {
    final logo = await findOperatingSystemLogo('UBT', size: 16);
    expect(logo, isA<AssetImage>());

    final image = logo as AssetImage;
    expect(image.assetName, 'assets/src/16x16/UBT.png');
    expect(image.package, 'operating_system_logos');
  });

  testWidgets('Ubuntu 24', (tester) async {
    final logo = await findOperatingSystemLogo('AIX', size: 24);
    expect(logo, isA<AssetImage>());

    final image = logo as AssetImage;
    expect(image.assetName, 'assets/src/24x24/AIX.png');
    expect(image.package, 'operating_system_logos');
  });

  testWidgets('ubuntu 48', (tester) async {
    final logo = await findOperatingSystemLogo('ubuntu', size: 48);
    expect(logo, isA<AssetImage>());

    final image = logo as AssetImage;
    expect(image.assetName, 'assets/src/48x48/UBT.png');
    expect(image.package, 'operating_system_logos');
  });

  testWidgets('unknown', (tester) async {
    expect(await findOperatingSystemLogo('unknown', size: 16), isNull);
  });

  testWidgets('unknown size', (tester) async {
    await expectLater(
        () => findOperatingSystemLogo('ubuntu', size: 0), throwsAssertionError);
  });
}
