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

## Step 12.8B — Build And Screenshot Checklist

Recommended next local testing artifact:

```text
1.0.0+2
```

Recommended AAB command:

```bash
flutter clean
flutter pub get
flutter analyze
flutter build appbundle --release --build-name=1.0.0 --build-number=2
```

Expected Flutter AAB path:

```text
build/app/outputs/bundle/release/app.aab
```

Recommended screenshots:

1. Welcome Screen.
2. Demo Dashboard.
3. Demo Workers.
4. Demo Tools.
5. Demo Transactions.
6. Demo Transaction Details / Proof Image.
7. Demo Report Preview with DEMO watermark.
8. Demo Signed Reports / Saved PDF.

Screenshots must use demo data only and must not show real company, worker, customer, document, signature, email, or phone data.

Next step:

```text
Step 12.8C — Run and record the local post-demo release build and permission review once the development machine is ready.
```
