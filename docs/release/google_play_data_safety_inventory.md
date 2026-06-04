# Google Play Data Safety Inventory

Issue: #12 — Prepare Google Play release checklist
Step: 12.3 — Legal and store data review
Status: Draft review inventory
Last updated: 2026-06-04

## Purpose

This document records the current Mina System data inventory for Google Play release preparation.

It is intended to support:

- Google Play Data Safety answers.
- Privacy Policy preparation.
- Account deletion policy preparation.
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

Current Android package:

```text
com.minasystem.app
```

Current version:

```text
1.0.0+1
```

## Current Backend and Storage Context

The app uses Supabase for backend services.

Expected Supabase components include:

- Authentication.
- Database tables.
- Row Level Security policies.
- Storage buckets.
- Auth email confirmation and password reset redirect flows.

Expected storage buckets:

| Bucket                           | Purpose                                |
| -------------------------------- | -------------------------------------- |
| `company-assets`                 | Company logo uploads.                  |
| `transaction-proofs`             | Transaction proof image uploads.       |
| `transaction-approval-documents` | Transaction approval document uploads. |

## Final APK Permissions Review

Final APK permissions reviewed using:

```text
aapt dump permissions
```

Current output:

```text
android.permission.INTERNET
android.permission.ACCESS_NETWORK_STATE
com.minasystem.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
```

No camera, microphone, location, contacts, SMS, call log, or storage permissions were found in the final APK permissions output.

Notes:

- `android.permission.INTERNET` is required for Supabase/backend connectivity.
- `android.permission.ACCESS_NETWORK_STATE` is used to check network connectivity.
- `com.minasystem.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` is an app-scoped generated/internal permission and is not a sensitive Android runtime permission.

## Data Inventory Summary

| Data Area                  | Data Types                                                                     | Source                                     | Purpose                                                    | Required?                               | Stored Where                                                                     | Shared?                                                            | Deletion Handling                                                                               |
| -------------------------- | ------------------------------------------------------------------------------ | ------------------------------------------ | ---------------------------------------------------------- | --------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| User account               | Email address, user ID, login/session identifiers                              | User registration/login                    | Authentication and account access                          | Required                                | Supabase Auth / database                                                         | Not sold. Processed by Supabase as backend provider.               | Delete or disable account and associated user profile data based on account deletion policy.    |
| User profile               | Full name, email, role, company membership                                     | User/admin input and system records        | Identify users and assign access roles                     | Required for business use               | Supabase database                                                                | Not sold. Processed by Supabase as backend provider.               | Delete or anonymize depending on company/legal retention needs.                                 |
| Company profile            | Company name, logo, settings, report configuration                             | Company owner/admin input                  | Company setup, branding, reports, and system configuration | Required for company workspace          | Supabase database and `company-assets` bucket                                    | Not sold. Processed by Supabase as backend provider.               | Delete company data when company account is deleted, subject to retention requirements.         |
| Departments and job titles | Department names, job title names                                              | Company admin input                        | Organize workers and reporting                             | Optional but expected                   | Supabase database                                                                | Not sold.                                                          | Delete with company data or when admin deletes lookup records.                                  |
| Worker records             | Worker name, HR code, worker code, department, job title, status               | Company user/admin input                   | Manage worker custody and accountability                   | Required for custody workflow           | Supabase database                                                                | Not sold.                                                          | Delete or anonymize based on company retention policy.                                          |
| Tool records               | Tool name, code, category, unit, status                                        | Company user/admin input                   | Manage tools and inventory custody                         | Required for custody workflow           | Supabase database                                                                | Not sold.                                                          | Delete when no longer needed, subject to transaction history restrictions.                      |
| Transactions               | Issue/return/lost/damaged records, quantities, dates, worker/tool links, notes | Company user/admin input                   | Track custody movement and accountability                  | Required for core workflow              | Supabase database                                                                | Not sold.                                                          | Retain for audit/accountability unless company deletion policy requires deletion/anonymization. |
| Signatures                 | Worker or authorized person signature images/data                              | User input during custody/report workflows | Evidence of acknowledgment and accountability              | Required for signed report workflows    | Supabase database/storage or generated report output depending on implementation | Not sold.                                                          | Delete with related transaction/report data unless retention is required.                       |
| Images/photos              | Transaction proof images, approval document images/files                       | User upload                                | Evidence and transaction support                           | Optional/required depending on workflow | Supabase storage buckets                                                         | Not sold.                                                          | Delete with related transaction/company data unless retention is required.                      |
| PDF reports                | Generated custody/report documents                                             | System generated from company data         | Reporting, accountability, and audit trail                 | Optional/required by workflow           | Local device and/or Supabase storage depending on implementation                 | Not sold. May be shared by company users outside the app manually. | Delete according to company/report retention policy.                                            |
| Audit logs                 | User actions, lifecycle events, timestamps, company/user references            | System generated                           | Security, accountability, and troubleshooting              | Required for audit trail                | Supabase database                                                                | Not sold.                                                          | Retain for security/audit purposes for a defined period, then delete or anonymize.              |
| Auth recovery data         | Password reset and email confirmation tokens/links                             | Supabase Auth                              | Account recovery and email verification                    | Required for auth flow                  | Supabase Auth / email provider flow                                              | Processed by Supabase and email provider                           | Expire automatically; account-related data handled under account deletion policy.               |
| Device/network status      | Network connectivity status                                                    | Device/app runtime                         | Show connection status and handle offline/network errors   | Optional operational data               | App runtime; not intentionally stored as personal data                           | Not sold.                                                          | Not applicable unless logged later.                                                             |

## Google Play Data Safety Draft Classification

This section is a draft classification for Play Console review. It must be verified before submission.

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

The app connects to Supabase through HTTPS URLs and production environment validation requires HTTPS URLs for configured backend and redirect URLs.

### Users Can Request Data Deletion

Expected answer:

```text
Pending implementation / policy confirmation.
```

Required before public release:

- Add or document an in-app account deletion request path.
- Add a public external account deletion request page or form.
- Define what data is deleted immediately.
- Define what data may be retained for legitimate business, security, audit, or legal reasons.
- Reflect the same information in the Privacy Policy.

## Draft Data Safety Categories

| Google Play Category | Mina System Data                                                        | Current Draft Answer                |
| -------------------- | ----------------------------------------------------------------------- | ----------------------------------- |
| Personal info        | Name, email address, user/account identity                              | Collected                           |
| App activity         | User actions, audit logs, transaction activities                        | Collected                           |
| Photos and videos    | Transaction proof images, company logo if image-based                   | Collected if user uploads           |
| Files and docs       | Approval documents, generated PDFs if stored/uploaded                   | Collected if user uploads or stores |
| Device or other IDs  | Supabase/user/session identifiers; no advertising ID intentionally used | Needs verification                  |
| Location             | Not collected                                                           |                                     |
| Contacts             | Not collected                                                           |                                     |
| Messages             | Not collected                                                           |                                     |
| Audio                | Not collected                                                           |                                     |
| Calendar             | Not collected                                                           |                                     |
| Health and fitness   | Not collected                                                           |                                     |
| Financial info       | Not collected by the app in current scope                               |                                     |
| Web browsing         | Not collected                                                           |                                     |

## Purpose Mapping

| Data Type                     | Purpose                                                              |
| ----------------------------- | -------------------------------------------------------------------- |
| Account/profile data          | Account creation, login, access control, support, security.          |
| Company data                  | Company workspace setup, branding, reports, and configuration.       |
| Worker data                   | Custody tracking, accountability, reporting, and company operations. |
| Tool data                     | Inventory and tool custody management.                               |
| Transaction data              | Issue/return/lost/damaged tracking and audit trail.                  |
| Signatures                    | Evidence of acknowledgment and responsibility.                       |
| Images/documents              | Proof of issue/return/approval and operational support.              |
| Audit logs                    | Security, troubleshooting, accountability, and abuse prevention.     |
| Email reset/confirmation data | Account recovery and email verification.                             |

## Retention and Deletion Draft

Current draft policy direction:

- User account data should be deleted when a verified account deletion request is approved.
- Company data should be deleted when the company workspace is deleted, subject to retention requirements.
- Transaction and audit records may need retention for accountability, legal, contractual, fraud prevention, or security reasons.
- If retention is required, the Privacy Policy must clearly explain what is retained, why it is retained, and for how long.
- Uploaded images/documents should be deleted with their related transaction/company records unless retention is required.
- Generated reports should be deleted if stored by the system, but reports exported/downloaded outside the app may remain outside Mina System control.

Pending decision:

```text
Define exact retention period before production release.
```

Suggested default for review:

```text
Operational records may be retained while the company account remains active. After account or company deletion request, data will be deleted or anonymized within a defined period unless retention is required for security, legal, contractual, or audit purposes.
```

## Account Deletion Requirements

Before Google Play production release, Mina System must provide:

### In-app deletion request path

Suggested implementation:

```text
Settings > Account > Request account deletion
```

or:

```text
Settings > Support > Request account deletion
```

### External deletion request URL

Suggested temporary option:

```text
A public GitHub Pages page or website page explaining how users request account deletion.
```

Required content on the external page:

- App name: Mina System.
- Developer/contact name.
- Support email.
- What users must provide to verify the request.
- What data will be deleted.
- What data may be retained and why.
- Expected processing timeframe.

Pending:

```text
Create public account deletion request page before Play Console submission.
```

## Privacy Policy Requirements

Before Google Play release, prepare a public Privacy Policy URL.

The Privacy Policy must include:

- App name: Mina System.
- Developer or company information.
- Privacy contact email.
- Types of data collected.
- Why the data is collected.
- Whether data is shared with service providers.
- Statement that data is not sold.
- Security practices.
- Data retention and deletion policy.
- Account deletion request process.
- Children/family statement if applicable.
- Effective date.
- Update policy.

Pending:

```text
Prepare public Privacy Policy URL before Google Play submission.
```

Suggested hosting options:

| Option                | Notes                                                                              |
| --------------------- | ---------------------------------------------------------------------------------- |
| GitHub Pages          | Fastest temporary option. Suitable for early release/testing if stable and public. |
| minasystem.app domain | Best long-term professional option. Requires domain and hosting decision.          |
| Business website      | Best if Mina System will be sold as a commercial product.                          |

## Support Contact

Current temporary support email:

```text
megamarkter@gmail.com
```

Pending decision:

```text
Use temporary Gmail for first internal/closed testing release, or replace with final business/domain email before production.
```

Recommended final support email:

```text
support@minasystem.app
```

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

| Item                                      | Status       |
| ----------------------------------------- | ------------ |
| Final support email                       | Pending      |
| Privacy Policy URL                        | Pending      |
| Account deletion external URL             | Pending      |
| In-app account deletion request flow      | Pending      |
| Exact data retention period               | Pending      |
| Final Data Safety answers                 | Pending      |
| Production Supabase project readiness     | Pending      |
| Production storage bucket policies        | Pending      |
| Demo/review account                       | Pending      |
| Final screenshots with demo data          | Pending      |
| Final Google Play store short description | Draft exists |
| Final Google Play store full description  | Draft exists |

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

### Not yet ready for public Google Play production release

Reasons:

- No final public Privacy Policy URL yet.
- No public account deletion request URL yet.
- In-app account deletion request flow needs confirmation or implementation.
- Data Safety answers are not finalized.
- Demo/review account is not confirmed.
- Final screenshots are not prepared.
- Production Supabase readiness still needs final verification.

## Recommended Next Steps

1. Review this data inventory.
2. Confirm whether Privacy Policy should be hosted on GitHub Pages or a final domain.
3. Confirm account deletion process.
4. Draft Privacy Policy.
5. Draft account deletion page.
6. Prepare Google Play Data Safety answers.
7. Prepare Google Play store screenshots using demo data.
8. Prepare Play Console internal/closed testing submission steps.
