# Windows Desktop Release

This document defines the repeatable Phase 1 release flow for the M.I.N.A System Windows x64 application.

## Distribution outputs

The release process produces these assets in `dist/windows/`:

- `MINA-System-Windows-x64-Setup.exe`
- `MINA-System-Windows-x64-Portable.zip`
- `SHA256SUMS.txt`

The installer is the primary distribution method. The ZIP is an installer-free package containing the complete Flutter Windows bundle, not only the application executable.

No GitHub Production Release is created by the workflow. Publishing release assets remains a manual approval gate.

## Prerequisites

Build on a 64-bit Windows machine or a GitHub Actions Windows runner with:

- Flutter `3.41.9` and Dart `3.11.5` or the project-approved equivalent.
- Visual Studio 2022 with the Desktop development with C++ workload.
- Windows 10/11 SDK, including `signtool.exe` when signing.
- Inno Setup 6 or 7, with `ISCC.exe` available on `PATH` or through `ISCC_PATH`.
- PowerShell 7 (`pwsh`).

The application version is read from `pubspec.yaml`. The Phase 1 baseline remains `1.0.0+2`; this release preparation does not change the Android version.

## Required production configuration

Provide the same production Dart defines used by the application environment validator:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `PASSWORD_RESET_REDIRECT_URL`
- `EMAIL_CONFIRMATION_REDIRECT_URL`

All URL values must use HTTPS. Never commit the real publishable key or any signing credential.

Example PowerShell session:

```powershell
$env:SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY = 'YOUR_PRODUCTION_PUBLISHABLE_KEY'
$env:PASSWORD_RESET_REDIRECT_URL = 'https://kingnarmar.com/reset-password'
$env:EMAIL_CONFIRMATION_REDIRECT_URL = 'https://kingnarmar.com/confirm-email'

./scripts/build_windows_release.ps1 -SkipSigning
```

The unsigned command is suitable for pipeline validation only. Do not publish unsigned artifacts as a production release.

## Release script behavior

`scripts/build_windows_release.ps1`:

1. Validates required HTTPS production configuration.
2. Reads the app version from `pubspec.yaml`.
3. Runs dependency resolution, formatting checks, analysis, tests, architecture checks, and the tracked-file secrets scan unless `-SkipValidation` is supplied.
4. Runs `flutter build windows --release` with production Dart defines.
5. Verifies the executable, `flutter_windows.dll`, and Flutter assets directory.
6. Copies the complete generated bundle to clean staging.
7. Adds `README-Windows.txt` with portable usage and runtime guidance.
8. Authenticode-signs staged `.exe` and `.dll` files when signing is enabled.
9. Creates the portable ZIP.
10. Compiles the Inno Setup installer.
11. Uses Inno Setup's SignTool hook to sign Setup and the generated uninstaller when signing is enabled.
12. Generates SHA-256 checksums.

The staging directory is deleted after packaging. Build outputs and certificates are ignored by Git.

## Authenticode signing

Production signing is optional during pipeline preparation but required before a trusted public release decision.

### PFX-based signing

```powershell
$env:WINDOWS_SIGN_PFX_PATH = 'C:\secure\certificate.pfx'
$env:WINDOWS_SIGN_PFX_PASSWORD = 'SET_OUTSIDE_GIT'
$env:WINDOWS_SIGN_TIMESTAMP_URL = 'https://YOUR_RFC3161_TIMESTAMP_SERVICE'
```

### Certificate-store signing

```powershell
$env:WINDOWS_SIGN_CERT_SHA1 = 'CERTIFICATE_THUMBPRINT'
$env:WINDOWS_SIGN_CERT_STORE = 'My' # optional
$env:WINDOWS_SIGN_CERT_STORE_SCOPE = 'machine' # optional
$env:WINDOWS_SIGN_TIMESTAMP_URL = 'https://YOUR_RFC3161_TIMESTAMP_SERVICE'
```

Then run:

```powershell
./scripts/build_windows_release.ps1
```

Signing uses SHA-256 for the file digest and SHA-256 with `/tr` for the RFC3161 timestamp digest. The wrapper verifies each signature after signing.

Do not use a self-signed certificate for public distribution. No production certificate, private key, password, or timestamp credential is stored in this repository.

## Installer behavior

`installer/mina_system.iss` provides:

- 64-bit Windows installation under Program Files.
- Start Menu shortcut and optional Desktop shortcut.
- Uninstaller.
- Stable AppId for reinstall and upgrade behavior.
- Retention of previous directory and tasks.
- Application-close handling during upgrade.
- English and Arabic installer languages.
- Signing hooks for Setup and the uninstaller.

The uninstaller removes installed application files only. There is no `UninstallDelete` rule for application data, so user data in Windows profile directories is not intentionally deleted.

## Portable ZIP

The ZIP contains the complete generated bundle:

- `mina_system.exe`
- `flutter_windows.dll`
- `data/` including `flutter_assets`
- Plugin and native DLLs emitted by Flutter
- Native assets emitted by packages
- `README-Windows.txt`

Users must extract the full ZIP and keep the bundle together. “Portable” describes packaging only; application data still uses normal Windows user-profile locations.

The release process preserves every generated runtime DLL. `README-Windows.txt` tells users to install the Microsoft Visual C++ 2015-2022 Redistributable x64 if Windows reports a missing runtime DLL. The final clean-machine smoke test must confirm actual runtime behavior.

## GitHub Actions validation

`.github/workflows/windows-release.yml` runs on relevant pull requests and manual dispatch. It:

- resolves dependencies;
- checks Dart formatting;
- runs `flutter analyze` and `flutter test`;
- runs architecture and secrets checks;
- builds an Android debug APK as a shared-code regression check;
- builds the Windows release bundle, installer, ZIP, and checksums without signing;
- checks portable bundle structure;
- silently installs, reinstalls, and uninstalls the generated installer;
- uploads unsigned validation artifacts for 14 days.

CI uses compile-only placeholder Dart defines. CI artifacts are not production builds and do not replace production-config runtime testing.

## Inno Setup licensing note

As of July 2026, Inno Setup remains usable without a mandatory purchase, while its publisher requests that qualifying commercial users purchase a commercial license. Current guidance says a license is not expected before an Inno-built installer is ready for production use. No purchase is made or authorized by this phase.

Review the current official terms before the first public commercial release.

## Release gates

Before creating a public GitHub Release:

1. Use confirmed production Supabase configuration.
2. Complete all automated checks.
3. Build signed installer and portable assets, or explicitly approve an unsigned-risk exception.
4. Verify Authenticode signatures and timestamps.
5. Compare generated SHA-256 values with uploaded assets.
6. Complete `docs/release/windows_smoke_test.md` on a clean standard-user machine.
7. Prepare release notes and system requirements.
8. Review SmartScreen risk, especially for a new certificate with limited reputation.
9. Obtain explicit approval before publishing or activating a public download link.

## Update strategy

Version 1 uses manual updates through the latest approved GitHub Release. The stable installer AppId supports installing a newer version over the current installation. Custom auto-update, MSIX, and AppInstaller are outside Phase 1.
