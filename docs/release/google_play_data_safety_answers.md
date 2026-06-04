# Google Play Data Safety Answers

Issue: #12 — Prepare Google Play release checklist  
Step: 12.5 — Data Safety Answers  
Status: Draft Play Console answers  
Last updated: 2026-06-04

## Purpose

This document converts the Mina System data inventory into practical draft answers for the Google Play Console Data Safety form.

It should be reviewed before submission. The final Play Console answers must match the real production build, backend configuration, permissions, and third-party SDK behavior.

## Current release assumptions

These answers apply to the current Android release preparation build.

| Area | Current answer |
| --- | --- |
| Ads | No ads in current scope. |
| AdMob / ad SDK | Not included. |
| Analytics SDK | Not included. |
| Crashlytics / crash reporting SDK | Not included. |
| Backend | Supabase. |
| Email provider | Brevo or configured SMTP provider may be used for auth/support email delivery. |
| Privacy Policy URL | `https://kingnarmar.github.io/mina_system/privacy-policy/` |
| Account deletion URL | `https://kingnarmar.github.io/mina_system/account-deletion/` |
| Contact email | `adlymina99@gmail.com` |

## Security practices section

### Is all user data collected by your app encrypted in transit?

Recommended answer:

```text
Yes
```

Reason:

The app is intended to connect to Supabase and release redirect URLs over HTTPS.

### Do you provide a way for users to request that their data is deleted?

Recommended answer:

```text
Yes
```

Use this public URL:

```text
https://kingnarmar.github.io/mina_system/account-deletion/
```

Notes:

- Personal user account deletion may delete or anonymize active account profile data.
- Historical company business records may retain limited identifying snapshots where required for company accountability, security, audit, contractual, or legal purposes.
- Company workspace deletion is handled separately and requires authorized company owner verification.

### Has your app been independently validated against a global security standard?

Recommended answer for now:

```text
No
```

Reason:

No independent MASA or equivalent security review has been completed yet.

## Data collection overview

### Does your app collect or share any required user data types?

Recommended answer:

```text
Yes
```

Reason:

Mina System collects and stores account, company, worker, inventory, transaction, signature, file/document, report, and audit/security data as part of its core business functionality.

### Is user data sold?

Recommended answer:

```text
No
```

Reason:

Mina System does not sell user data.

### Is data shared with third parties?

Recommended practical answer:

```text
No, not as third-party sharing for sale or independent third-party use.
```

Important note:

Supabase and Brevo/configured SMTP are service providers that process data to provide app functionality. In Google Play's Data Safety framing, service provider processing may not need to be declared as third-party sharing if the provider processes data on the developer's behalf and under the developer's instructions. This must be verified before final submission.

## Data type answers

### 1. Personal info — Name

| Question | Draft answer |
| --- | --- |
| Collected? | Yes |
| Shared? | No, except service provider processing if applicable |
| Required or optional? | Required for account/profile and business audit workflows |
| Purpose | App functionality, account management, fraud prevention/security/compliance |
| Processed ephemerally? | No |

Notes:

- User names may be used for active profiles and role/accountability workflows.
- Historical records may retain a limited name snapshot at the time of an action.

### 2. Personal info — Email address

| Question | Draft answer |
| --- | --- |
| Collected? | Yes |
| Shared? | No, except service provider processing if applicable |
| Required or optional? | Required for authentication and support/account recovery |
| Purpose | App functionality, account management, developer communications, fraud prevention/security/compliance |
| Processed ephemerally? | No |

Notes:

- Email is used for login, account recovery, email confirmation, support, and deletion requests.

### 3. Personal info — User IDs

| Question | Draft answer |
| --- | --- |
| Collected? | Yes |
| Shared? | No, except service provider processing if applicable |
| Required or optional? | Required |
| Purpose | App functionality, account management, fraud prevention/security/compliance |
| Processed ephemerally? | No |

Notes:

- Supabase user IDs and internal references may be used for access control, audit trail, and company membership.

### 4. Photos and videos — Photos

| Question | Draft answer |
| --- | --- |
| Collected? | Yes, if the user uploads images or captures transaction proof images |
| Shared? | No, except service provider processing if applicable |
| Required or optional? | Optional or workflow-required depending on company process |
| Purpose | App functionality, fraud prevention/security/compliance |
| Processed ephemerally? | No |

Notes:

- This may include company logos and transaction proof images.
- No camera permission was found in the final APK permissions output at the time of review, but image upload/capture workflows should be rechecked before final submission.

### 5. Files and docs — Files and docs

| Question | Draft answer |
| --- | --- |
| Collected? | Yes, if users upload or generate documents/reports |
| Shared? | No, except service provider processing if applicable |
| Required or optional? | Optional or workflow-required depending on company process |
| Purpose | App functionality, fraud prevention/security/compliance |
| Processed ephemerally? | No |

Notes:

- This may include approval documents and generated PDF reports.
- Company users may manually export/share reports outside the app according to their own workflow.

### 6. App activity — App interactions / Other actions

| Question | Draft answer |
| --- | --- |
| Collected? | Yes |
| Shared? | No, except service provider processing if applicable |
| Required or optional? | Required for audit/accountability workflows |
| Purpose | App functionality, fraud prevention/security/compliance |
| Processed ephemerally? | No |

Notes:

- This includes transaction actions, lifecycle events, audit logs, and accountability records.
- This is not analytics advertising data in the current build.

### 7. Other user-generated content

| Question | Draft answer |
| --- | --- |
| Collected? | Yes |
| Shared? | No, except service provider processing if applicable |
| Required or optional? | Required/optional depending on workflow |
| Purpose | App functionality, fraud prevention/security/compliance |
| Processed ephemerally? | No |

Notes:

- This may include notes, transaction comments, company settings, report template content, and operational records entered by users.

### 8. Device or other IDs

| Question | Draft answer |
| --- | --- |
| Collected? | Needs final verification |
| Shared? | Needs final verification |
| Required or optional? | Needs final verification |
| Purpose | App functionality, fraud prevention/security/compliance if collected |
| Processed ephemerally? | Needs final verification |

Current recommendation:

```text
Do not declare Advertising ID because ads are not included in the current build and no AD_ID permission was found in the reviewed APK.
```

However, Supabase/session identifiers and app/account identifiers may still fall under User IDs rather than Device IDs. Recheck the final AAB and SDK behavior before submission.

## Data types currently expected as not collected

Based on the current scope and permissions review, these should be answered as not collected unless implementation changes before submission:

| Google Play category | Draft answer |
| --- | --- |
| Location | Not collected |
| Contacts | Not collected |
| SMS or MMS | Not collected |
| Emails message content | Not collected |
| Audio files | Not collected |
| Calendar | Not collected |
| Health and fitness | Not collected |
| Financial info | Not collected in current app scope |
| Web browsing history | Not collected |
| Crash logs | Not collected by SDK in current scope |
| Diagnostics | Not collected by SDK in current scope |
| Advertising ID | Not collected in current scope |

## Final APK permissions reference

The reviewed release APK permissions were:

```text
android.permission.INTERNET
android.permission.ACCESS_NETWORK_STATE
com.minasystem.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
```

No camera, microphone, location, contacts, SMS, call log, storage, or advertising ID permissions were found in the reviewed APK output.

## Required Play Console URLs

### Privacy Policy URL

```text
https://kingnarmar.github.io/mina_system/privacy-policy/
```

### Account deletion URL

```text
https://kingnarmar.github.io/mina_system/account-deletion/
```

## Store listing notes

Screenshots and store listing media must use demo data only.

Do not show:

- Real company names.
- Real worker names.
- Real HR codes.
- Real signatures.
- Real documents.
- Real customer, supplier, or project data.
- Real email addresses or phone numbers.

## Open checks before final submission

| Check | Status |
| --- | --- |
| Rebuild final AAB after all release checklist changes | Pending |
| Re-run APK/AAB permission review | Pending |
| Confirm no Ads SDK was added | Pending final build check |
| Confirm no Analytics/Crashlytics SDK was added | Pending final build check |
| Confirm final Privacy Policy URL opens publicly | Done for current URL |
| Confirm final account deletion URL opens publicly | Done for current URL |
| Add or confirm in-app account deletion entry point | Pending |
| Prepare demo/review account for Google Play review | Pending |
| Prepare final screenshots using demo data | Pending |
| Final Play Console Data Safety submission | Pending |

## Recommended Play Console answer summary

```text
Collects user data: Yes
Shares user data: No, except service provider processing if applicable
Data is encrypted in transit: Yes
Users can request data deletion: Yes
Ads: No
Analytics: No
Crash reporting: No
Privacy Policy URL: https://kingnarmar.github.io/mina_system/privacy-policy/
Account deletion URL: https://kingnarmar.github.io/mina_system/account-deletion/
```
