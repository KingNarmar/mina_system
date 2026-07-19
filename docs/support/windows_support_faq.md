# M.I.N.A System — Windows Support and FAQ

Issue: #61 — Prepare support and FAQ documentation

Parent epic: #11 — Windows Release Readiness

Last updated: 2026-07-19

Document status: Pre-release support reference while Microsoft Store certification is in progress

## 1. Purpose

This document provides Windows-focused support and troubleshooting guidance for M.I.N.A System.

It covers the current approved onboarding model, Demo Mode and Live Mode, authentication, company access, reports, attachments, updates, common Windows problems, safe bug reporting, and confirmed support contacts.

This document does not authorize a Production release, a Microsoft Store submission change, a public download link, or a website deployment.

## 2. Current Windows availability

| Item | Current confirmed value |
| --- | --- |
| Product | M.I.N.A System — Materials Inventory Navigation Assistant |
| Flutter application version | `1.0.0+3` |
| Microsoft Store package version | `1.0.0.0` |
| Windows architecture | x64 |
| Certification status | `In certification` |
| Public Microsoft Store URL | Not available |

The Windows application is not yet publicly available through Microsoft Store.

Do not use or share a placeholder, private-only, draft, or unofficial Store URL. The official website Windows button must remain disabled until certification succeeds, an official listing URL exists, the URL is verified, and activation is explicitly approved.

## 3. Confirmed support and legal contacts

### Product support

`support.mina-system@kingnarmar.com`

### Privacy requests

`privacy.mina-system@kingnarmar.com`

### Account deletion requests

`deletion.mina-system@kingnarmar.com`

### Privacy Policy

`https://kingnarmar.com/mina-system/privacy-policy`

### Account Deletion

`https://kingnarmar.com/mina-system/account-deletion`

No support response time, paid support level, service-level agreement, subscription, or pricing promise is defined by this document.

## 4. Installation and launch

### How will users install the Windows application?

The intended first public Windows distribution channel is Microsoft Store.

After certification and public approval, install M.I.N.A System only from the verified official Store listing. No external Production EXE, Portable ZIP, or public non-Store installer is currently approved by this document.

### Why is there no public Windows download button yet?

The current Microsoft Store submission is still `In certification`, and no official public listing URL is available.

The website download button must remain disabled until the Store listing is approved and verified.

### What should I do if Microsoft Store cannot install the app?

After the official listing becomes available:

1. Confirm Windows is using an internet connection.
2. Confirm Microsoft Store is signed in and working normally.
3. Confirm the device is x64. ARM64 and x86 packages are not currently claimed.
4. Install available Windows and Microsoft Store updates.
5. Restart Microsoft Store and try the official listing again.
6. Record the exact error code before contacting support.

Do not download an unofficial package from a third-party website.

### What should I do if the app does not launch?

1. Confirm the installation completed successfully.
2. Restart Windows and launch the app from the Start Menu.
3. Confirm the device is using the supported package architecture, currently x64.
4. Record whether a window appears briefly, remains blank, or closes immediately.
5. Record any Windows error message or Event Viewer reference where safe.
6. Contact support with the bug-report details in this document.

Do not send passwords, tokens, private keys, or unredacted sensitive company data with logs.

### Does the app require Administrator access?

The Microsoft Store installation model should normally manage installation permissions, but complete Standard Windows User testing remains pending under Issue #65.

Do not claim that every workflow has passed Standard User validation until that manual matrix is completed.

## 5. Sign in and company access

### How do I sign in?

Use the **Sign In** action from the welcome screen and enter the credentials for an approved account.

Live Mode requires authenticated access to an active company workspace.

### Can anyone create a company workspace from the Windows app?

No public self-service company creation flow is claimed.

M.I.N.A System workspaces are created through approved company onboarding. A user must be linked to an active company workspace through the approved process.

### What happens when my account has no company access?

The app shows a company-access-required screen when the authenticated account is not linked to an active company workspace.

The current guidance is to:

- contact M.I.N.A System support; or
- ask the company administrator to send an invitation.

The **Request Company Access** action attempts to open the default email application with a support request addressed to `support.mina-system@kingnarmar.com`.

When no email application is available, send the request manually to the same address.

### What information should I include in a company-access request?

Include only the minimum necessary information:

- your name;
- your work email address;
- the company name;
- the name of the company administrator or contact, when known;
- a short explanation of the access needed.

Do not email your password or authentication token.

### Why can I sign in but still not see company data?

Possible reasons include:

- the account is not linked to an active company;
- the membership invitation or activation is incomplete;
- the membership is inactive;
- the selected company context is unavailable;
- the role does not permit the requested action;
- the session needs to refresh after an access change;
- the network connection is unavailable.

Sign out and sign in again after an administrator confirms that access has been activated. Contact support when the problem continues.

### Why can I view a record but not edit or approve it?

Live Mode permissions depend on the authenticated user's active company membership and role.

Do not assume that every signed-in user has management or approval permissions. Contact the company administrator when a required action is unavailable.

## 6. Demo Mode and Live Mode

### What is Demo Mode?

Demo Mode is a local demonstration path with sample operational data. It can be opened from **Explore Demo** without a real company account.

Use Demo Mode for product evaluation, workflow demonstration, and safe practice.

### Is Demo Mode connected to Production company data?

No. Demo Mode and Live Mode are separate application paths.

Demo records must not be presented as real customer or Production data.

### Is Demo Mode data synchronized to the cloud?

Demo Mode is a local demonstration path and is not a substitute for Live Mode synchronization or Production backup.

Do not rely on Demo Mode as the only copy of important information. Clearing application data, uninstalling, reinstalling, or future demo-data changes may affect locally stored demonstration records.

### What is Live Mode?

Live Mode uses authenticated company access and the configured Supabase backend.

Live company information is company-scoped, and access depends on active membership and role permissions.

### Can Demo Mode data be moved automatically into Live Mode?

No automatic Demo-to-Live migration is promised by this document.

Create verified Live Mode records through the approved company workflow rather than treating demo records as Production records.

## 7. Password reset

### How do I request a password reset?

1. Open the login flow.
2. Select the forgot-password action.
3. Enter the email address associated with the account.
4. Select **Send Reset Link**.
5. Check the inbox and spam or junk folder.
6. Follow the instructions in the reset email.

For account-enumeration safety, the app may show a generic confirmation stating that a reset email was sent if an account exists for that address.

### I did not receive the reset email. What should I do?

1. Confirm the email address was entered correctly.
2. Check spam, junk, quarantine, and company email filters.
3. Wait briefly before requesting another message.
4. Confirm the mailbox can receive external email.
5. Request a new reset link when the previous link may have expired.
6. Contact support without sending your password.

### The reset link is invalid or expired. What should I do?

Return to the forgot-password flow and request a new reset email.

Use the newest reset message. Do not forward password-reset links to another person.

### Will support ask for my password?

No. Never send your password, reset link, one-time code, authentication token, or recovery token to support.

## 8. Session persistence and logout

### Will I remain signed in after closing the app?

The application supports authenticated session handling, but the actual result can depend on session validity, backend availability, account status, and future security changes.

When a stored session is valid, the app may restore the authenticated flow. When a session is expired or invalid, sign in again.

### How do I sign out?

Use the available **Sign Out** or **Logout** action in the account or access screen.

Signing out ends the current authenticated session on that installation and returns the user to the welcome or authentication flow.

### What should I do on a shared Windows computer?

- Sign out when work is complete.
- Do not save passwords in an untrusted browser or password prompt.
- Do not leave sensitive reports in shared folders.
- Remove exported files according to company policy.
- Do not share a Windows user account when company policy requires individual accountability.

## 9. Reports, PDF files, and printing

### What reports are available?

The application supports custody and transaction-related reports, including signed PDF output for applicable workflows.

The exact report content depends on the selected record, company data, transaction state, and supported workflow.

### Can I preview a PDF before saving it?

PDF preview is supported where the workflow provides it.

Windows preview behavior still requires full validation across the intended environments under Issue #65.

### Can I save a report to a Windows folder?

Save is supported where the report workflow provides it.

When saving fails:

1. Choose a folder where the current Windows user has write permission.
2. Try a short local path such as the user's Documents folder.
3. Avoid protected system folders.
4. Confirm sufficient disk space.
5. Record the selected path and filename safely for the bug report.

### Can I print reports?

Windows printing is supported where the workflow and selected print target allow it.

When printing fails:

1. Confirm a printer or valid Windows print target is installed.
2. Test printing from another application.
3. Confirm the correct printer is selected.
4. Save the PDF first and test printing the saved file.
5. Record the printer or print-target name without exposing private network information.

Complete printing validation remains part of Issue #65.

### Are Arabic filenames and non-ASCII paths supported?

They are intended test scenarios, but complete Windows validation remains pending.

When an Arabic filename or non-ASCII path fails, retry with a simple local English filename and report both the original and fallback path details without exposing sensitive folder names.

## 10. Photos and attachments

### Which attachment types are supported?

Supported workflows can accept photos, image files, and PDF documents.

The exact allowed selection depends on the screen and transaction workflow.

### Why can I not select or upload a file?

Check the following:

- the file type is supported by that workflow;
- the file still exists at the selected path;
- the current Windows user can read the file;
- Live Mode has an active internet connection;
- the account has permission for the operation;
- the filename and path are not causing a compatibility problem;
- the file is not locked exclusively by another application.

Do not repeatedly upload confidential files while troubleshooting. Use a safe test file when possible.

### What details should I provide for an attachment problem?

Provide:

- attachment type, such as JPG, PNG, or PDF;
- approximate file size;
- whether the filename contains Arabic or other non-ASCII characters;
- whether the path is local, synchronized, network-based, or removable storage;
- the action being performed;
- the exact safe error message;
- whether the problem occurs in Demo Mode or Live Mode.

Do not attach the original sensitive file unless support explicitly requests it through an approved secure channel.

## 11. Offline and reconnect behavior

### Can Live Mode work fully offline?

No complete offline-first Live Mode capability is promised.

Authentication, password recovery, backend reads and writes, synchronization, uploads, and online refresh require connectivity.

### What should I do when the connection is lost?

1. Do not repeatedly submit the same transaction.
2. Wait for the connection to return.
3. Confirm the network is working outside the app.
4. Return to the relevant screen or refresh where supported.
5. Check whether the operation completed before submitting again.
6. Sign in again only when the session has expired or the app requests authentication.

### How do I avoid duplicate transactions after reconnecting?

Before repeating an operation, check the transaction list, recent activity, or affected record to confirm whether the first submission succeeded.

When the result is unclear, contact the company administrator or support instead of creating another record immediately.

### Does Demo Mode require an internet connection?

Demo Mode is intended as a local demonstration path and does not require access to a live company workspace. Features that open external legal pages, email applications, or other online resources can still require connectivity.

Complete offline, reconnect, sleep, resume, and session-refresh testing remains pending under Issue #65.

## 12. Microsoft Store updates

### How will the Windows application update?

The intended first public release uses Microsoft Store distribution and Store-managed package updates.

Depending on Windows and Microsoft Store settings, updates may install automatically or the user may need to open Microsoft Store and use its update flow manually.

### Does M.I.N.A System have an automatic in-app updater?

No custom automatic in-app updater is claimed.

The current application also does not claim a separate self-updating installer or silent background updater controlled by M.I.N.A System.

### How can I check for a Store update?

After public availability:

1. Open Microsoft Store.
2. Open the Library or downloads and updates area.
3. Check for available updates.
4. Confirm that the listing is the official M.I.N.A System product published by King Narmar.

Exact labels can vary between Microsoft Store versions.

## 13. Display, scaling, and input

### The interface is too large, too small, or clipped. What should I record?

Record:

- Windows display resolution;
- display scaling, such as 100%, 125%, or 150%;
- whether one or multiple monitors are connected;
- the app window size;
- the affected screen;
- a redacted screenshot.

High-DPI and multiple-scaling validation remains pending under Issue #65.

### Can I use a mouse for signatures?

Mouse or compatible pointer input is an intended Windows signature scenario.

Complete mouse-signature validation across the intended Windows environments remains pending. Report the device type, display scaling, and exact signature behavior when a problem occurs.

## 14. Common troubleshooting checklist

Before reporting a problem:

1. Confirm the current app and package versions.
2. Confirm the device is x64.
3. Confirm whether the problem is in Demo Mode or Live Mode.
4. Confirm the internet connection when using Live Mode.
5. Sign out and sign in again when the issue relates to account or session state.
6. Restart the app.
7. Restart Windows when launch, Store, file-picker, or printer behavior is involved.
8. Try a safe sample record or non-sensitive test file.
9. Record the exact steps and result.
10. Check that repeating the operation will not create a duplicate transaction.

Do not uninstall the app before recording evidence when local Demo Mode data or the exact failure state may be needed for diagnosis.

## 15. How to report a bug

Send the report to:

`support.mina-system@kingnarmar.com`

Use a clear subject such as:

```text
Windows Bug Report — [short problem summary]
```

Include:

- M.I.N.A System Flutter version;
- Microsoft Store package version;
- Windows edition and build;
- device architecture;
- Demo Mode or Live Mode;
- company role when relevant, without exposing private membership data;
- display resolution and scaling when relevant;
- clear reproduction steps;
- expected result;
- actual result;
- exact safe error message;
- whether the problem is consistent or intermittent;
- screenshot or screen recording where safe;
- attachment type, approximate size, filename character set, and path type when files are involved;
- whether the problem continues after restarting the app;
- whether network loss or reconnect was involved.

### Bug report template

```text
Subject: Windows Bug Report — [summary]

M.I.N.A System version:
Microsoft Store package version:
Windows edition and build:
Architecture:
Demo Mode or Live Mode:
Company role, when relevant:
Display resolution and scaling:

Steps to reproduce:
1.
2.
3.

Expected result:

Actual result:

Error message:

Frequency: Always / Sometimes / Once

Attachment details, when relevant:
- Type:
- Approximate size:
- Filename uses Arabic/non-ASCII characters: Yes / No
- Path type: Local / Synced / Network / Removable

Network or reconnect involved: Yes / No
Restarted the app: Yes / No

Safe screenshot or recording attached: Yes / No
Sensitive data redacted: Yes / No
```

## 16. Information that must not be sent through normal support email

Do not send:

- passwords;
- password-reset links;
- one-time codes;
- authentication or refresh tokens;
- Supabase keys;
- service-role keys;
- `.env` files;
- signing certificates or certificate passwords;
- keystores or private signing data;
- private customer databases;
- unredacted worker identity documents;
- unredacted sensitive company reports;
- confidential attachments unless explicitly required through an approved secure support channel.

Redact sensitive information from screenshots, recordings, logs, paths, and filenames whenever possible.

## 17. Privacy and account deletion

### How do I review the Privacy Policy?

Use:

`https://kingnarmar.com/mina-system/privacy-policy`

### How do I request account deletion?

Use:

`https://kingnarmar.com/mina-system/account-deletion`

or contact:

`deletion.mina-system@kingnarmar.com`

Follow the published verification process. Do not send account passwords or authentication tokens with a deletion request.

## 18. Known support boundaries

The following areas still require complete Windows manual validation and must not be presented as universally passed:

- clean Microsoft Store installation;
- exact supported Windows editions and builds;
- Standard Windows User behavior;
- reinstall, upgrade, uninstall, and Store update lifecycle;
- Arabic filenames and non-ASCII paths;
- High-DPI and multiple display scaling;
- file pickers and attachment selection;
- PDF preview and save locations;
- printing;
- mouse signature;
- offline, reconnect, lock, sleep, and resume behavior;
- password-reset completion on Windows;
- controlled multi-company and role/RLS scenarios.

Windows App Certification Kit, build success, static analysis, and GitHub Actions do not replace clean-machine functional testing.

## 19. Related documentation and tracking

- `WINDOWS_RELEASE_READINESS.md` — canonical Windows checklist and evidence model.
- `docs/release/release_metadata.md` — product identity and version mapping.
- `docs/release/windows_release_notes_1.0.0.md` — current Windows release notes.
- Issue #61 — this Support / FAQ task.
- Issue #62 — targeted security and release static checks.
- Issue #63 — functional test coverage review.
- Issue #64 — targeted automated tests.
- Issue #65 — manual Windows validation execution.
- Issue #66 — Windows GitHub Actions evaluation.
- Issue #67 — Account and legal UI localization.
- `KingNarmar/king-narmar-website#25` — official Store-link activation after certification approval.

## 20. Release-control statement

This document provides support guidance only. It does not approve:

- replacing the current Microsoft Store submission;
- publishing a Production release;
- activating a public Windows download link;
- publishing a non-Store installer;
- claiming that all Windows runtime tests have passed.