# Windows Release Manual Smoke Test

Record the Windows edition/build, CPU architecture, account type, display scale, artifact hashes, tester, and date. Do not mark an item passed unless it was actually executed.

## Artifact integrity and trust

- Confirm the installer, portable ZIP, and `SHA256SUMS.txt` names are exact.
- Recalculate SHA-256 for both assets and compare with the checksum file.
- Verify Authenticode on the application executable, relevant PE files, installer, and uninstaller.
- Confirm the signature chains to the intended production certificate and includes a valid RFC3161 timestamp.
- Record any SmartScreen warning and the exact publisher shown.

## Installer lifecycle

- Install from a clean Windows 10 x64 machine.
- Install from a clean Windows 11 x64 machine when available.
- Confirm Program Files destination.
- Confirm Start Menu shortcut.
- Confirm optional Desktop shortcut behavior.
- Launch after installation.
- Reinstall the same version.
- Install a newer test version over an older one.
- Confirm user data remains available after upgrade.
- Uninstall from Windows Settings.
- Confirm application files are removed.
- Confirm user data is not deleted unexpectedly.
- Reinstall after uninstall.
- Repeat with a standard Windows user, including the administrator credential prompt.

## Portable package

- Extract the complete ZIP to an ASCII path.
- Extract to a path containing Arabic/non-ASCII characters.
- Extract to a long nested path.
- Launch only after extraction.
- Confirm moving the extracted folder does not break startup.
- Confirm running the EXE without its `data` directory fails safely and does not corrupt data.

## Core application

- Launch.
- Authentication with a valid approved company user.
- Invalid login handling.
- Logout.
- Session persistence after closing and reopening.
- Password reset link flow.
- Demo Mode launch.
- Demo seed data.
- Demo changes persist after restart.
- Demo reset restores the expected seed state.
- Workers: list, search, filter, create, edit, deactivate/delete according to permissions.
- Tools: list, search, filter, create, edit, stock/custody behavior.
- Transactions: issue, return, lost, damaged, validation, transaction types, search, filters.
- Approvals: pending, approve/reject, permissions, audit behavior.

## Files, signatures, and reports

- Select JPG, JPEG, PNG, WEBP, and PDF files.
- Select files with Arabic filenames.
- Select files from non-ASCII and long paths.
- Confirm Windows camera option is not incorrectly offered.
- Capture signature with a mouse.
- Clear and redraw the signature.
- Generate unsigned and signed reports.
- Preview PDF.
- Save PDF to ASCII, Arabic/non-ASCII, and long paths.
- Print to Microsoft Print to PDF and a physical printer when available.
- Test share behavior where Windows/plugin support is available; record unsupported behavior accurately.

## Display and accessibility

- Test 100%, 125%, 150%, and 200% display scaling where available.
- Test common laptop and external-monitor resolutions.
- Test keyboard navigation and visible focus.
- Test English and Arabic layouts and text direction.
- Confirm no clipped dialogs or inaccessible controls.

## Connectivity and links

- Launch online.
- Disable network while signed in and verify safe errors.
- Reconnect and confirm refresh/recovery.
- Test a slow or unstable connection.
- Open Privacy Policy.
- Open Account Deletion.
- Confirm all production links use HTTPS and no placeholder links appear.

## Completion record

Document:

- Passed items.
- Failed items with screenshots/logs.
- Items not executed and why.
- Blocking defects.
- Non-blocking limitations.
- Final recommendation: reject, internal-only, release candidate, or approved for public release.
