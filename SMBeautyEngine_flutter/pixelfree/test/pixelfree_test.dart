import 'package:flutter_test/flutter_test.dart';
import 'package:pixelfree/pixelfree.dart';
import 'package:pixelfree/pixelfree_platform_interface.dart';
import 'package:pixelfree/pixelfree_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPixelfreePlatform
    with MockPlatformInterfaceMixin
    implements PixelfreePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PixelfreePlatform initialPlatform = PixelfreePlatform.instance;

  test('$MethodChannelPixelfree is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPixelfree>());
  });

  test('getPlatformVersion', () async {
    Pixelfree pixelfreePlugin = Pixelfree();
    MockPixelfreePlatform fakePlatform = MockPixelfreePlatform();
    PixelfreePlatform.instance = fakePlatform;

    expect(await pixelfreePlugin.getPlatformVersion(), '42');
  });
}
