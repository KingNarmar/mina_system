# M.I.N.A System — Windows Release Notes

Issue: #60 — Prepare Microsoft Store release notes

Parent epic: #11 — Windows Release Readiness

Last updated: 2026-07-18

Document status: Pre-release reference while Microsoft Store certification is in progress

## 1. Release summary

| Item | Current confirmed value |
| --- | --- |
| Product | M.I.N.A System — Materials Inventory Navigation Assistant |
| Flutter application version | `1.0.0+3` |
| Microsoft Store package version | `1.0.0.0` |
| Windows architecture | x64 |
| Publisher display name | King Narmar |
| Microsoft Store identity | `KingNarmar.M.I.N.ASystem` |
| Certification status | `In certification` |
| Public Microsoft Store URL | Not available |

The Flutter application version and the Microsoft Store package version are separate version fields. They must not be presented as the same numbering value.

This document does not authorize a Production release, a Store submission change, or public download-link activation.

## 2. Release overview

M.I.N.A System is a multi-company materials inventory and custody management solution for warehouses, workshops, maintenance teams, and industrial operations.

The Windows application is designed for desktop administration, operational review, record management, approvals, attachments, reporting, and signed custody documentation.

The current package has been submitted to Microsoft Store certification. It is not yet publicly available, and no public Store link should be published until Microsoft provides an official listing URL and activation is explicitly approved.

## 3. Main product capabilities

### Workers and organization records

- Manage worker records.
- Use organization data such as departments and job titles.
- Search and filter worker records.
- Review worker-related custody and transaction information where available.

### Tools and material records

- Manage tools and material records.
- Use supporting lookup data such as categories and units.
- Search and filter tool records.
- Review tool history and custody information where available.

### Custody transactions

- Record issue transactions.
- Record return transactions.
- Record lost and damaged transaction workflows.
- Track transaction history and open custody balances.
- Apply current validation rules for quantities, selections, and return balances.

### Approvals and supporting documents

- Support approval-related workflows for applicable transaction types.
- Attach supporting images and PDF documents where the workflow allows.
- Review approval state and related records according to the signed-in user's authorized company access and role.

### Photos, attachments, and signatures

- Select photos and images for supported workflows.
- Attach PDF and image files.
- Capture worker signatures using supported pointer or touch input.
- Use signed data in applicable reports and transaction records.

### Reports

- Generate custody and transaction-related reports.
- Preview PDF output where supported.
- Save PDF output where supported.
- Produce signed PDF records for applicable workflows.
- Use Windows printing where supported by the environment and selected print target.

### Search and filters

- Search workers, tools, and transactions.
- Filter supported lists and transaction views.
- Use responsive layouts designed for desktop, tablet, and mobile form factors.

## 4. Demo Mode and Live Mode

### Demo Mode

Demo Mode provides a local demonstration path with sample operational data. It is intended for product evaluation and workflow demonstration without requiring access to a live company workspace.

Demo Mode and Live Mode are separate application paths. Demo information must not be presented as Production customer data.

### Live Mode

Live Mode uses authenticated company access and the configured Supabase backend.

Live company information is company-scoped. Access depends on the authenticated user's active company membership and role. Public material must not claim permissions or capabilities beyond the current implemented and verified role behavior.

## 5. System requirements

The current confirmed package configuration is Windows x64.

Conservative requirements for the first Microsoft Store release are:

- A supported 64-bit Windows environment capable of installing the approved Microsoft Store package.
- Microsoft Store access for installation and Store-managed updates after public approval.
- An internet connection for initial Store installation.
- An internet connection for authentication, password recovery, Live Mode, backend synchronization, uploads, and online data refresh.
- A mouse or compatible pointer device for normal desktop use and mouse-based signature testing.
- Access to a valid Windows printer or print target only when printing is required.
- Sufficient local storage for the application, generated reports, and user-selected attachments.

No minimum processor, RAM, disk-space figure, Windows edition, or Windows build number is claimed until the manual Windows validation matrix establishes verified support boundaries.

Only x64 is currently configured. Compatibility with ARM64 or x86 is not claimed.

## 6. Installation and availability

Current status: `In certification`.

The Windows application is not yet publicly available through Microsoft Store. The official website Windows button must remain disabled until:

- Microsoft certification succeeds;
- an official public Store listing URL exists;
- the URL is verified against the correct product and publisher;
- explicit approval is given to activate the public link.

Do not publish a fake, placeholder, private-only, or draft Microsoft Store URL.

## 7. Updates

The first public Windows release is intended to use Microsoft Store distribution and Store-managed package updates.

Users may need to open Microsoft Store and use its update flow manually, depending on their Windows and Store settings.

The current application does not claim:

- a custom automatic in-app updater;
- a separate self-updating installer;
- silent background updates controlled by M.I.N.A System;
- an external public installer outside the approved release channel.

Future package versions must use a Microsoft Store package version accepted as newer than the previously submitted version.

## 8. Recorded package validation

PR #57 recorded successful completion of:

- `flutter pub get`;
- `flutter analyze`;
- Windows x64 Production build;
- a limited Windows application launch smoke test;
- MSIX package creation;
- MSIX manifest identity validation;
- Windows App Certification Kit with exit code `0`.

Additional developer verification before PR #68 merge recorded:

- `flutter analyze` with no issues;
- successful Windows release build generation.

These checks prove buildability, package generation, manifest identity, limited launch behavior, and certification-kit completion only. They do not prove every functional workflow on a clean Windows installation.

## 9. Known limitations and pending validation

The following limitations must remain visible until actual Windows evidence changes them:

- Microsoft Store certification is still in progress.
- No official public Microsoft Store URL exists.
- Clean Microsoft Store installation has not yet been recorded through the complete manual matrix.
- Exact supported Windows editions and build versions have not yet been finalized.
- ARM64 and x86 packages are not currently configured.
- Standard Windows User behavior still requires complete manual validation.
- Reinstall, upgrade, uninstall, and Store update behavior require actual package-lifecycle testing.
- High-DPI and multiple display-scaling scenarios require full manual validation.
- Arabic filenames and non-ASCII Windows paths require full manual validation.
- Image selection, PDF attachments, file pickers, report save locations, printing, and mouse signature require full manual validation across the intended environments.
- Offline launch, network loss, reconnect, lock/sleep resume, and session refresh require full manual validation.
- Password reset completion on Windows requires a controlled end-to-end test.
- Multi-company and role restrictions must continue to be verified with controlled accounts and real RLS-backed access checks.
- Automated test coverage is being tracked separately and does not replace Windows runtime testing.

Windows App Certification Kit and GitHub Actions must not be treated as substitutes for clean-machine functional testing.

## 10. Code signing and SmartScreen

The current submitted package is configured for Microsoft Store distribution.

No claim is made that a separate public EXE, Portable ZIP, or non-Store package is Production-signed.

Any future non-Store distribution must have its own reviewed code-signing plan and must disclose potential Microsoft Defender SmartScreen reputation warnings until an appropriate signing and reputation path is established.

Self-signed certificates are suitable only for controlled internal testing and must not be presented as public Production signing.

## 11. Privacy and account deletion

Confirmed public legal pages:

- Privacy Policy: `https://kingnarmar.com/mina-system/privacy-policy`
- Account Deletion: `https://kingnarmar.com/mina-system/account-deletion`

Do not include real passwords, authentication tokens, production keys, private customer data, worker personal data, or signing secrets in public bug reports, screenshots, support documents, or issue comments.

## 12. Support

Product support:

- `support.mina-system@kingnarmar.com`

Privacy requests:

- `privacy.mina-system@kingnarmar.com`

Account deletion requests:

- `deletion.mina-system@kingnarmar.com`

When reporting a Windows issue, include only non-sensitive information such as:

- M.I.N.A System version;
- Microsoft Store package version;
- Windows edition and build;
- x64 architecture confirmation;
- Demo Mode or Live Mode;
- display scaling;
- clear reproduction steps;
- the actual result;
- the expected result;
- redacted screenshots or logs where useful.

## 13. Customer-facing release-note copy

### Initial Windows release

M.I.N.A System brings materials inventory and custody workflows to Windows desktop users.

This release includes worker and tool records, issue and return transactions, lost and damaged workflows, search and filters, approvals and supporting documents, photos and attachments, signature capture, custody tracking, and signed PDF reporting.

Demo Mode is available for product evaluation, while Live Mode supports authenticated company workspaces with company-scoped and role-based access.

The Windows package is currently in Microsoft Store certification and is not yet publicly available.

## 14. Related tracking

- `WINDOWS_RELEASE_READINESS.md` — canonical Windows checklist and evidence model.
- `docs/release/release_metadata.md` — canonical product identity and version mapping.
- Issue #60 — this release-notes task.
- Issue #61 — Windows Support / FAQ.
- Issue #62 — security and release static checks.
- Issue #63 — functional test coverage review.
- Issue #64 — targeted automated tests.
- Issue #65 — manual Windows validation execution.
- Issue #66 — Windows GitHub Actions evaluation.
- Issue #67 — Account and legal UI localization.
- `KingNarmar/king-narmar-website#25` — official Store-link activation after certification approval.

## 15. Release-control statement

These notes describe the current submitted package and the verified product scope. They do not approve:

- a Microsoft Store submission replacement;
- a public Production release;
- a website download-link activation;
- a non-Store installer publication;
- a claim that all Windows runtime tests have passed.
