# Google Play Data Safety Inventory

Issue: #12 — Prepare Google Play release checklist  
Step: 12.7B — Domain legal links and release contact sync  
Status: Draft review inventory, updated after King Narmar legal pages and in-app Account/Profile Panel  
Last updated: 2026-06-06

## Purpose

This document records the current Mina System data inventory for Google Play release preparation.

It is intended to support:

- Google Play Data Safety answers.
- Privacy Policy preparation and review.
- Account deletion policy preparation and review.
- Store review readiness.
- Internal technical review before production release.

This document is not a final legal privacy policy. It is a technical and product inventory that must be reviewed before public store submission.

## Current App Context

Mina System is a materials inventory and custody management system for companies, warehouses, workshops, maintenance teams, and industrial operations.

The app supports:

- User authentication.
- Company account setup.
- Company membership and role-based access.
- Workers management.
- Tools and inventory-related records.
- Custody transactions.
- Signatures.
- Images and supporting documents.
- PDF reports.
- Company-level settings and templates.
- Account/Profile Panel with legal links and account actions.

Current Android package:

```text
com.minasystem.app
```

Current version:

```text
1.0.0+1
```

## Current Backend, Website, and Contact Context

The app uses Supabase for backend services.

Expected Supabase components include:

- Authentication.
- Database tables.
- Row Level Security policies.
- Storage buckets.
- Auth email confirmation and password reset redirect flows.

Expected storage buckets:

| Bucket | Purpose |
| --- | --- |
| `company-assets` | Company logo uploads. |
| `transaction-proofs` | Transaction proof image uploads. |
| `transaction-approval-documents` | Transaction approval document uploads. |

Current public legal URLs:

| Page | URL | Status |
| --- | --- | --- |
| Privacy Policy | `https://kingnarmar.com/mina-system/privacy-policy` | Public domain URL prepared |
| Account Deletion | `https://kingnarmar.com/mina-system/account-deletion` | Public domain URL prepared |

Current app-specific emails:

| Purpose | Email | Status |
| --- | --- | --- |
| Product support | `support.mina-system@kingnarmar.com` | Final app-specific release contact |
| Privacy requests | `privacy.mina-system@kingnarmar.com` | Final app-specific release contact |
| Account deletion requests | `deletion.mina-system@kingnarmar.com` | Final app-specific release contact |

## Final APK Permissions Review

Final APK permissions reviewed using:

```text
aapt dump permissions
```

Current output from the reviewed release APK:

```text
android.permission.INTERNET
android.permission.ACCESS_NETWORK_STATE
com.minasystem.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
```

No camera, microphone, location, contacts, SMS, call log, or storage permissions were found in the reviewed APK permissions output.

Notes:

- `android.permission.INTERNET` is required for Supabase/backend connectivity.
- `android.permission.ACCESS_NETWORK_STATE` is used to check network connectivity.
- `com.minasystem.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` is an app-scoped generated/internal permission and is not a sensitive Android runtime permission.
- Permissions must be rechecked after the final signed AAB is rebuilt.

## Data Inventory Summary

| Data Area | Data Types | Source | Purpose | Required? | Stored Where | Shared? | Deletion Handling |
| --- | --- | --- | --- | --- | --- | --- | --- |
| User account | Email address, user ID, login/session identifiers | User registration/login | Authentication and account access | Required | Supabase Auth / database | Not sold. Processed by Supabase as backend provider. | Delete or disable account and associated user profile data based on account deletion policy. |
| User profile | Full name, email, role, company membership | User/admin input and system records | Identify users and assign access roles | Required for business use | Supabase database | Not sold. Processed by Supabase as backend provider. | Delete or anonymize depending on company/legal retention needs. |
| Company profile | Company name, logo, settings, report configuration | Company owner/admin input | Company setup, branding, reports, and system configuration | Required for company workspace | Supabase database and `company-assets` bucket | Not sold. Processed by Supabase as backend provider. | Delete company data when company workspace is deleted, subject to retention requirements. |
| Departments and job titles | Department names, job title names | Company admin input | Organize workers and reporting | Optional but expected | Supabase database | Not sold. | Delete with company data or when admin deletes lookup records. |
| Worker records | Worker name, HR code, worker code, department, job title, status | Company user/admin input | Manage worker custody and accountability | Required for custody workflow | Supabase database | Not sold. | Delete or anonymize based on company retention policy. |
| Tool records | Tool name, code, category, unit, status | Company user/admin input | Manage tools and inventory custody | Required for custody workflow | Supabase database | Not sold. | Delete when no longer needed, subject to transaction history restrictions. |
| Transactions | Issue/return/lost/damaged records, quantities, dates, worker/tool links, notes | Company user/admin input | Track custody movement and accountability | Required for core workflow | Supabase database | Not sold. | Retain for audit/accountability unless company deletion policy requires deletion/anonymization. |
| Signatures | Worker or authorized person signature images/data | User input during custody/report workflows | Evidence of acknowledgment and accountability | Required for signed report workflows | Supabase database/storage or generated report output depending on implementation | Not sold. | Delete with related transaction/report data unless retention is required. |
| Images/photos | Transaction proof images, approval document images/files | User upload | Evidence and transaction support | Optional/required depending on workflow | Supabase storage buckets | Not sold. | Delete with related transaction/company data unless retention is required. |
| PDF reports | Generated custody/report documents | System generated from company data | Reporting, accountability, and audit trail | Optional/required by workflow | Local device and/or Supabase storage depending on implementation | Not sold. May be shared by company users outside the app manually. | Delete according to company/report retention policy. |
| Audit logs | User actions, lifecycle events, timestamps, company/user references | System generated | Security, accountability, and troubleshooting | Required for audit trail | Supabase database | Not sold. | Retain for security/audit purposes for a defined period, then delete or anonymize. |
| Auth recovery data | Password reset and email confirmation tokens/links | Supabase Auth | Account recovery and email verification | Required for auth flow | Supabase Auth / email provider flow | Processed by Supabase and email provider | Expire automatically; account-related data handled under account deletion policy. |
| Device/network status | Network connectivity status | Device/app runtime | Show connection status and handle offline/network errors | Optional operational data | App runtime; not intentionally stored as personal data | Not sold. | Not applicable unless logged later. |

## Google Play Data Safety Draft Classification

This section is a draft classification for Play Console review. It must be verified before final submission.

### Data Collected

Expected answer:

```text
Yes, the app collects user data.
```

Reason:

The app stores user accounts, company data, worker records, transactions, signatures, images/documents, and reports.

### Data Shared

Expected answer:

```text
No user data is sold.
```

Backend/service provider processing:

- Supabase is used as backend/auth/database/storage provider.
- Brevo or configured SMTP/email provider may be used for authentication emails.
- Data may be processed by these providers only to deliver app functionality.

This should be described in the Privacy Policy as service provider processing, not sale of data.

### Data Encrypted in Transit

Expected answer:

```text
Yes.
```

Reason:

The app connects to Supabase and public legal pages through HTTPS URLs.

### Users Can Request Data Deletion

Expected answer:

```text
Yes.
```

Current implementation status:

- In-app path prepared through the Account/Profile Panel: `Account > Request Account Deletion`.
- Public account deletion URL prepared: `https://kingnarmar.com/mina-system/account-deletion`.
- Public Privacy Policy URL prepared: `https://kingnarmar.com/mina-system/privacy-policy`.
- App-specific account deletion email prepared: `deletion.mina-system@kingnarmar.com`.

Deletion policy direction:

- Verified personal user account deletion may delete or anonymize active account profile data.
- Historical company business records may retain limited identifying snapshots where required for company accountability, security, audit, contractual, or legal purposes.
- Company workspace deletion is separate and requires authorized company owner verification.

## Draft Data Safety Categories

| Google Play Category | Mina System Data | Current Draft Answer |
| --- | --- | --- |
| Personal info | Name, email address, user/account identity | Collected |
| App activity | User actions, audit logs, transaction activities | Collected |
| Photos and videos | Transaction proof images, company logo if image-based | Collected if user uploads |
| Files and docs | Approval documents, generated PDFs if stored/uploaded | Collected if user uploads or stores |
| Device or other IDs | Supabase/user/session identifiers; no advertising ID intentionally used | Needs final verification |
| Location | Not collected | |
| Contacts | Not collected | |
| Messages | Not collected | |
| Audio | Not collected | |
| Calendar | Not collected | |
| Health and fitness | Not collected | |
| Financial info | Not collected by the app in current scope | |
| Web browsing | Not collected | |

## Purpose Mapping

| Data Type | Purpose |
| --- | --- |
| Account/profile data | Account creation, login, access control, support, security. |
| Company data | Company workspace setup, branding, reports, and configuration. |
| Worker data | Custody tracking, accountability, reporting, and company operations. |
| Tool data | Inventory and tool custody management. |
| Transaction data | Issue/return/lost/damaged tracking and audit trail. |
| Signatures | Evidence of acknowledgment and responsibility. |
| Images/documents | Proof of issue/return/approval and operational support. |
| Audit logs | Security, troubleshooting, accountability, and abuse prevention. |
| Email reset/confirmation data | Account recovery and email verification. |

## Retention and Deletion Draft

Current draft policy direction:

- User account data should be deleted or anonymized when a verified account deletion request is approved.
- Company data should be deleted or anonymized when an authorized company workspace deletion request is approved, subject to retention requirements.
- Transaction and audit records may need retention for accountability, legal, contractual, fraud prevention, or security reasons.
- If retention is required, the Privacy Policy must clearly explain what is retained and why it is retained.
- Uploaded images/documents should be deleted with their related transaction/company records unless retention is required.
- Generated reports should be deleted if stored by the system, but reports exported/downloaded outside the app may remain outside Mina System control.

Open decision before final production release:

```text
Define exact retention period or confirm retention remains policy-based per company/legal/audit requirements before production submission.
```

Suggested default for review:

```text
Operational records may be retained while the company account remains active. After an account or company deletion request, data will be deleted or anonymized within a defined period unless retention is required for security, legal, contractual, or audit purposes.
```

## Account Deletion Requirements

### In-app deletion request path

Current implementation:

```text
Account Panel > Request Account Deletion
```

Status:

```text
Implemented and linked from the in-app Account/Profile Panel.
```

### External deletion request URL

Current public URL:

```text
https://kingnarmar.com/mina-system/account-deletion
```

Status:

```text
Prepared on the King Narmar domain.
```

Required content on the external page:

- App name: Mina System.
- Developer/contact name.
- Support/privacy/deletion emails.
- What users must provide to verify the request.
- What data will be deleted or anonymized.
- What data may be retained and why.
- Company workspace deletion distinction.

## Privacy Policy Requirements

Current public URL:

```text
https://kingnarmar.com/mina-system/privacy-policy
```

Status:

```text
Prepared on the King Narmar domain.
```

The Privacy Policy includes:

- App name: Mina System.
- Developer/company brand: King Narmar Software Solutions.
- Privacy contact email.
- Support contact email.
- Types of data collected.
- Why the data is collected.
- Service provider processing.
- Statement that data is not sold.
- Security practices.
- Data retention and deletion policy.
- Account deletion request process.
- Children/family statement.
- Effective date/update policy.

## Support Contact

Current final app-specific support email:

```text
support.mina-system@kingnarmar.com
```

Additional app-specific legal contacts:

```text
privacy.mina-system@kingnarmar.com
deletion.mina-system@kingnarmar.com
```

These replace the previous temporary Gmail contacts for Google Play release documentation.

## Store Listing Data Impact Notes

The store listing must avoid showing real company or worker data.

Screenshots should use demo data only:

- Demo company.
- Demo users.
- Demo workers.
- Demo tools.
- Demo transactions.
- Demo signatures.
- Demo reports.

No real customer, company, employee, phone, email, HR code, signature, or document should appear in screenshots.

## Open Decisions Before Google Play Submission

| Item | Status |
| --- | --- |
| Final support email | Done: `support.mina-system@kingnarmar.com` |
| Privacy Policy URL | Done: `https://kingnarmar.com/mina-system/privacy-policy` |
| Account deletion external URL | Done: `https://kingnarmar.com/mina-system/account-deletion` |
| In-app account deletion request flow | Done: Account/Profile Panel action |
| Exact data retention period | Pending |
| Final Data Safety answers | Pending final build/review |
| Production Supabase project readiness | Pending |
| Production storage bucket policies | Pending |
| Demo/review account | Pending |
| Final screenshots with demo data | Pending |
| Final Google Play store short description | Draft exists |
| Final Google Play store full description | Draft exists |

## Current Release Readiness Assessment

### Completed

- Android app identity confirmed.
- Android launcher icons prepared.
- Release signing configured.
- Signed release APK built and tested.
- Signed release AAB built.
- APK permissions reviewed.
- Supabase environment flow uses `--dart-define`.
- Git signing secrets protection added.
- Public Privacy Policy URL prepared on King Narmar domain.
- Public account deletion URL prepared on King Narmar domain.
- In-app account deletion entry point implemented in the Account/Profile Panel.
- App-specific Mina System support/privacy/deletion emails selected for release documentation.

### Not yet ready for public Google Play production release

Reasons:

- Final Data Safety answers still need final build verification.
- Demo/review account is not confirmed.
- Final screenshots are not prepared.
- Production Supabase readiness still needs final verification.
- Production storage bucket policies still need final verification.
- Exact retention period or retention wording must be finalized before production submission.

## Recommended Next Steps

1. Rebuild final signed AAB after all release checklist changes.
2. Re-run APK/AAB permission review.
3. Confirm no Ads, Analytics, Crashlytics, or AdMob SDKs were added.
4. Prepare demo/review account for Google Play.
5. Prepare final screenshots using demo data.
6. Finalize Data Safety answers in Play Console.
7. Prepare Play Console internal/closed testing submission steps.
