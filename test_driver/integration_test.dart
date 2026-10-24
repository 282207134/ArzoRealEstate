import 'dart:convert';
import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final directory = await Directory('docs/screenshots').create(recursive: true);
  final sdkRoot =
      Platform.environment['ANDROID_SDK_ROOT'] ??
      Platform.environment['ANDROID_HOME'] ??
      '${Platform.environment['LOCALAPPDATA']}/Android/Sdk';
  final adb = '$sdkRoot/platform-tools/adb${Platform.isWindows ? '.exe' : ''}';
  final device = Platform.environment['ARZO_DEVICE'] ?? 'emulator-5556';
  await integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      if (data == null) return;
      final remote = data['captureDirectory'] as String?;
      final names = (data['captureNames'] as List? ?? []).cast<String>();
      for (final name in names) {
        final result = await Process.run(adb, [
          '-s',
          device,
          'exec-out',
          'run-as',
          'com.arzo.arzo_real_estate',
          'cat',
          '$remote/$name.png',
        ], stdoutEncoding: null);
        if (result.exitCode != 0) {
          throw StateError('Cannot export $name: ${result.stderr}');
        }
        await File(
          '${directory.path}/$name.png',
        ).writeAsBytes(result.stdout as List<int>);
      }
      await File(
        'build/integration-summary.json',
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    },
  );
}
