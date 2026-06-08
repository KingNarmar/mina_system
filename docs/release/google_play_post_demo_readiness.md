# Google Play Post-Demo Release Readiness

Issue: #12 — Prepare Google Play release checklist  
Related completed issue: #46 — Local Demo Workspace  
Step: 12.8A — Post-demo Google Play readiness and pending developer account approval  
Last updated: 2026-06-08

## Purpose

This document records the Google Play release readiness state after completing the Local Demo Workspace.

It is intentionally focused on what remains after the demo work, so already-completed release and demo work is not repeated as pending work.

## Current Play Console Account Status

Current status provided by the developer:

```text
Google Play Developer account is not fully active yet.
Address approval / verification is still pending.
```

Release decision:

```text
Do not attempt Production submission while developer account approval is pending.
Do not apply for Production access until the account is fully approved and the required testing path is complete.
```

Notes:

- Local documentation, store listing preparation, screenshot planning, and local build preparation can continue.
- Production submission must remain blocked until Play Console account verification is complete.
- If the account is treated as a new personal developer account, closed testing requirements must be handled before applying for Production access.

## Already Completed / Do Not Repeat As Pending

The following items are already documented or implemented and should not be treated as missing unless a later verification fails.

### Product identity and app metadata

| Item | Current status |
| --- | --- |
| Product name | Done: Mina System |
| Meaning | Done: Materials Inventory Navigation Assistant |
| Android application ID | Done: `com.minasystem.app` |
| Android namespace | Done: `com.minasystem.app` |
| Android package/version source | Done through Flutter / Android Gradle configuration |
| Current version in `pubspec.yaml` | `1.0.0+1` |
| Public support email | Done: `support.mina-system@kingnarmar.com` |
| Privacy email | Done: `privacy.mina-system@kingnarmar.com` |
| Account deletion email | Done: `deletion.mina-system@kingnarmar.com` |
| Privacy Policy URL | Done: `https://kingnarmar.com/mina-system/privacy-policy` |
| Account Deletion URL | Done: `https://kingnarmar.com/mina-system/account-deletion` |

### Android release technical foundation

| Item | Current status |
| --- | --- |
| Release signing configuration | Done |
| Local keystore and `key.properties` flow | Done locally and protected from Git |
| Signed release APK previously built/tested | Done before demo completion |
| Signed release AAB previously built | Done before demo completion |
| Previous APK permission review | Done before demo completion |

Important:

```text
Because Issue #46 added a major public demo flow after the previous release build, a new post-demo AAB must be built before any Play Console testing upload.
```

### Local Demo Workspace

Issue #46 is completed and closed.

The following demo items are already complete and should not be listed again as pending:

- Welcome Screen.
- Explore Demo without login.
- `AppMode.live` and `AppMode.demo` foundation.
- Demo AppShell.
- Demo current context.
- Local demo storage.
- Seed demo data.
- Demo Dashboard.
- Demo Workers.
- Demo Tools.
- Demo Transactions.
- Demo Reports.
- Demo Team.
- Demo Settings.
- Reset Demo Data.
- Local transaction proof images.
- Local approval documents.
- Local signed PDFs.
- Signed Reports local history.
- DEMO watermark.
- Demo limits:
  - Workers: 10.
  - Tools: 20.
  - Transactions: 50.
  - Pending Team Invitations: 3.
- `dart format lib` passed.
- `flutter analyze` passed.

## Remaining Work For Issue #12

### 1. Post-demo AAB build

A new AAB should be built after Issue #46.

Recommended local build command:

```bash
flutter clean
flutter pub get
flutter analyze
flutter build appbundle --release --build-name=1.0.0 --build-number=2
```

Expected output:

```text
build/app/outputs/bundle/release/app-release.aab
```

Decision note:

- Current `pubspec.yaml` version is `1.0.0+1`.
- Because the previous release build existed before the Local Demo Workspace, the next Google Play testing build should use build number `2` unless Play Console has never received build number `1` and the developer intentionally decides to keep it.
- Safer release path: use `1.0.0+2` for the first post-demo Play Console testing upload.

### 2. Post-demo permission review

After building the new post-demo release artifact, re-run Android permissions review.

Recommended check:

```bash
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk
```

If only an AAB is produced, generate/review an APK from the same release configuration before documenting final permissions.

Expected known permissions from the previous review:

```text
android.permission.INTERNET
android.permission.ACCESS_NETWORK_STATE
com.minasystem.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
```

Do not finalize Data Safety answers until this post-demo permissions review is repeated.

### 3. Store screenshots after demo

Screenshots should be captured from demo mode only, using fake data.

Recommended first Google Play phone screenshot set:

1. Welcome Screen showing Explore Demo / Sign In / Request Company Access.
2. Demo Dashboard with realistic summary cards.
3. Demo Workers list/details.
4. Demo Tools list/details.
5. Demo Transaction flow with local proof image.
6. Demo lost/damaged approval or transaction detail screen.
7. Demo report preview with DEMO watermark.
8. Demo signed report history / saved signed PDF confirmation.

Rules:

- Use demo data only.
- Do not show real company, worker, HR code, customer, email, phone, signature, or document data.
- Do not show production Supabase records.
- Avoid empty screens.
- Avoid misleading claims such as free, best, top, official, guaranteed, or similar promotional wording.

### 4. Store assets review

Known current asset:

```text
docs/release/store_assets/android/play_store_icon_512.png
```

Still to verify before Play Console listing:

- Confirm Play Store icon upload preview.
- Confirm whether feature graphic exists.
- If missing, prepare feature graphic:

```text
1024 x 500 PNG or JPEG
```

Optional but useful:

- Prepare alt text / internal descriptions for each screenshot.
- Prepare desktop/website screenshots separately later; do not mix them into Android Play Store phone screenshots unless needed for marketing outside Google Play.

### 5. Store listing text finalization

Existing release metadata already includes draft short and full descriptions.

Remaining action:

- Review and freeze short description.
- Review and freeze full description.
- Make sure both descriptions reflect the current demo-enabled public release state.
- Do not use direct external purchase wording.
- Use safe B2B wording such as:

```text
Request company access
Request onboarding
Contact support
```

### 6. Data Safety final pass

The Data Safety inventory exists, but final answers are still pending final build/review.

Remaining action:

- Re-check permissions after the post-demo build.
- Confirm no Ads, AdMob, Analytics, Crashlytics, location, contacts, SMS, microphone, or camera permission was added.
- Confirm whether image picking uses Android Photo Picker / file picker without broad storage permission.
- Confirm Supabase, email provider, and storage processing are reflected accurately.
- Confirm account deletion and privacy URLs are accessible.
- Finalize retention wording before production submission.

### 7. Demo/review access decision

Recommended reviewer path after Issue #46:

```text
Primary review path: Explore Demo without login.
Live review account: optional and deferred until production Supabase readiness is confirmed.
```

Reason:

- Demo mode allows reviewers to explore the app safely without credentials.
- Demo mode avoids shared demo data corruption.
- Demo mode avoids uncontrolled Supabase writes.
- Demo mode avoids mixing real and sample data.

If Play Console later requires credentials for live login testing, create a separate review account only after production Supabase readiness is confirmed.

### 8. Play Console submission path

Current blocked state:

```text
Production submit is blocked because developer account address approval is still pending.
```

Safe next route after account approval:

1. Finish Play Console account/address verification.
2. Create or complete app setup in Play Console.
3. Fill Store Listing using prepared metadata/assets.
4. Upload post-demo AAB to Internal Testing or Closed Testing depending on available account options.
5. Complete App Content sections:
   - Privacy Policy.
   - Data Safety.
   - App access.
   - Ads declaration.
   - Content rating.
   - Target audience.
   - News apps / Government / Financial declarations if shown by Play Console.
6. Run testing.
7. If required for the account, run closed testing with the required tester count and duration before applying for Production access.
8. Apply for Production access only after the testing requirement is satisfied and feedback is documented.

## Current Blockers

| Blocker | Type | Status |
| --- | --- | --- |
| Google Play developer account address approval | External / Play Console | Pending |
| New post-demo AAB | Local release build | Pending |
| Post-demo permission review | Technical release verification | Pending |
| Final phone screenshots | Store listing asset | Pending |
| Feature graphic confirmation | Store listing asset | Pending |
| Final Data Safety answers | Play Console compliance | Pending final build/review |
| Exact retention wording | Legal/policy | Pending |
| Production Supabase readiness | Backend release readiness | Pending |
| Production storage bucket policies | Backend release readiness | Pending |

## Current Decision

Issue #12 should continue in a pre-submission readiness mode until the Google Play developer account is fully approved.

No Production submission should be attempted at this stage.

The next practical work should be:

```text
Step 12.8B — Prepare post-demo AAB build commands and screenshot capture checklist
```

This keeps the project moving without depending on Play Console approval and without repeating completed demo work.
