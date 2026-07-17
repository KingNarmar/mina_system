import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Windows release configuration uses approved artifact names', () {
    final installer = File('installer/mina_system.iss').readAsStringSync();
    final buildScript = File(
      'scripts/build_windows_release.ps1',
    ).readAsStringSync();

    expect(installer, contains('MINA-System-Windows-x64-Setup'));
    expect(installer, contains('ArchitecturesAllowed=x64compatible'));
    expect(installer, contains('SignedUninstaller=yes'));
    expect(buildScript, contains('MINA-System-Windows-x64-Portable.zip'));
    expect(buildScript, contains('SHA256SUMS.txt'));
    expect(buildScript, contains('--dart-define=APP_ENV=production'));
  });

  test('Windows release files do not embed signing secrets', () {
    final files = <File>[
      File('installer/mina_system.iss'),
      File('scripts/build_windows_release.ps1'),
      File('scripts/sign_windows_file.ps1'),
    ];

    for (final file in files) {
      final content = file.readAsStringSync();
      expect(content, isNot(contains('BEGIN PRIVATE KEY')));
      expect(content, isNot(contains('WINDOWS_SIGN_PFX_PASSWORD=')));
    }
  });
}
