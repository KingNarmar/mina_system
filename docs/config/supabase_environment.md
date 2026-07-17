# Supabase Environment Configuration

Mina System must not hardcode Supabase project values inside Dart source files.

The app reads Supabase configuration at build/run time using Dart compilation
environment declarations.

## Required variables

| Variable                          | Required              | Description                                                                                     |
| --------------------------------- | --------------------- | ----------------------------------------------------------------------------------------------- |
| `APP_ENV`                         | No                    | App environment name. Defaults to `development`. Supported values: `development`, `production`. |
| `SUPABASE_URL`                    | Yes                   | Supabase project URL. Must be a valid HTTPS URL.                                                |
| `SUPABASE_PUBLISHABLE_KEY`        | Preferred             | Supabase client-side publishable/anon key.                                                      |
| `SUPABASE_ANON_KEY`               | Fallback              | Supported for the current `supabase_flutter` version used by the project.                       |
| `PASSWORD_RESET_REDIRECT_URL`     | Required in production | HTTPS destination used by the password-reset flow.                                             |
| `EMAIL_CONFIRMATION_REDIRECT_URL` | Required in production | HTTPS destination used by the email-confirmation flow.                                         |

Use either `SUPABASE_PUBLISHABLE_KEY` or `SUPABASE_ANON_KEY`.

Do not commit real Supabase keys to the repository.

## Development run example

Windows CMD:

```bash
flutter run ^
  --dart-define=APP_ENV=development ^
  --dart-define=SUPABASE_URL=YOUR_DEV_SUPABASE_URL ^
  --dart-define=SUPABASE_ANON_KEY=YOUR_DEV_SUPABASE_ANON_KEY
```

PowerShell:

```powershell
flutter run `
  --dart-define=APP_ENV=development `
  --dart-define=SUPABASE_URL=YOUR_DEV_SUPABASE_URL `
  --dart-define=SUPABASE_ANON_KEY=YOUR_DEV_SUPABASE_ANON_KEY
```

## Device Preview run example

Windows CMD:

```bash
flutter run -t lib/main_device_preview.dart ^
  --dart-define=APP_ENV=development ^
  --dart-define=SUPABASE_URL=YOUR_DEV_SUPABASE_URL ^
  --dart-define=SUPABASE_ANON_KEY=YOUR_DEV_SUPABASE_ANON_KEY
```

PowerShell:

```powershell
flutter run -t lib/main_device_preview.dart `
  --dart-define=APP_ENV=development `
  --dart-define=SUPABASE_URL=YOUR_DEV_SUPABASE_URL `
  --dart-define=SUPABASE_ANON_KEY=YOUR_DEV_SUPABASE_ANON_KEY
```

## Production Google Play AAB build example

Windows CMD:

```bash
flutter build appbundle --release ^
  --dart-define=APP_ENV=production ^
  --dart-define=SUPABASE_URL=YOUR_PRODUCTION_SUPABASE_URL ^
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PRODUCTION_PUBLISHABLE_KEY ^
  --dart-define=PASSWORD_RESET_REDIRECT_URL=YOUR_PASSWORD_RESET_URL ^
  --dart-define=EMAIL_CONFIRMATION_REDIRECT_URL=YOUR_EMAIL_CONFIRMATION_URL
```

PowerShell:

```powershell
flutter build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=SUPABASE_URL=YOUR_PRODUCTION_SUPABASE_URL `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PRODUCTION_PUBLISHABLE_KEY `
  --dart-define=PASSWORD_RESET_REDIRECT_URL=YOUR_PASSWORD_RESET_URL `
  --dart-define=EMAIL_CONFIRMATION_REDIRECT_URL=YOUR_EMAIL_CONFIRMATION_URL
```

The generated bundle is expected at `build/app/outputs/bundle/release/app-release.aab`.

## Safety notes

- Keep development and production Supabase projects separate.
- Never use the development Supabase project for production builds.
- Never commit real `.env` files.
- Keep only placeholder examples in documentation.
- Rotate keys if any real key is accidentally committed.
- Confirm database migrations before switching production builds to the production Supabase project.
- Confirm required storage buckets before switching production builds to the production Supabase project.

## Required Supabase storage buckets

The current app expects these storage buckets to exist:

| Bucket                           | Purpose                                |
| -------------------------------- | -------------------------------------- |
| `company-assets`                 | Company logo uploads.                  |
| `transaction-proofs`             | Transaction proof image uploads.       |
| `transaction-approval-documents` | Transaction approval document uploads. |

## Production Supabase project requirements

Before building Mina System with `APP_ENV=production`, create and verify a separate production Supabase project.

The production project must not share development data, test companies, test users, test transactions, or temporary storage files.

Required production setup:

- Create a dedicated Supabase production project.
- Confirm the production project URL.
- Confirm the production client-side anon or publishable key.
- Keep the production service role key private and never use it inside the Flutter app.
- Apply all required database schema migrations.
- Apply all required RLS policies.
- Apply all required storage bucket policies.
- Create all required storage buckets.
- Confirm authentication settings.
- Confirm email templates and redirect URLs if email confirmation or password reset flows are enabled.
- Confirm realtime settings for tables that need live synchronization.
- Test the app with production configuration before any public release.

## Database migration checklist

Before using the production project, confirm that the production database includes all tables, functions, constraints, triggers, indexes, and RLS policies required by the app.

Minimum checklist:

- `profiles` table is created and configured.
- `companies` table is created and configured.
- `company_members` table is created and configured.
- `company_report_settings` table is created and configured.
- `company_document_templates` table is created and configured.
- Workers-related tables are created and configured.
- Tools-related tables are created and configured.
- Transactions-related tables are created and configured.
- Audit logs tables are created and configured.
- Required RPC functions are created.
- Required triggers are created.
- Required indexes are created.
- RLS is enabled on all protected tables.
- RLS policies preserve company isolation.
- Test users cannot access another company's data.

## Storage setup checklist

Create these buckets in the production Supabase project before testing production builds:

| Bucket                           | Access model                 | Notes                               |
| -------------------------------- | ---------------------------- | ----------------------------------- |
| `company-assets`                 | Private or policy-controlled | Used for company logo uploads.      |
| `transaction-proofs`             | Private or policy-controlled | Used for transaction proof images.  |
| `transaction-approval-documents` | Private or policy-controlled | Used for approval document uploads. |

Storage checklist:

- Buckets exist in the production project.
- Upload policies are configured.
- Read policies are configured.
- Delete policies are configured where needed.
- Users can only access files belonging to their company.
- File paths remain scoped by `companyId`.
- Signed URL behavior is tested for private files.
- Orphan file cleanup strategy is confirmed.

## Auth setup checklist

Before release, confirm the production Supabase Auth settings.

Minimum checklist:

- Email login is enabled if required.
- Email confirmation setting matches the intended user flow.
- Password reset redirect URLs are configured if password reset is used.
- Site URL is configured correctly.
- Additional redirect URLs are configured for supported platforms.
- Test users are separated from development users.
- Production test accounts are created only for controlled testing.

## Realtime setup checklist

If realtime synchronization is required in production, confirm the production Supabase project has realtime enabled for the required tables.

Minimum checklist:

- Realtime is enabled for the `transactions` table if transaction sync is required.
- Realtime behavior is tested between two active devices.
- Company isolation remains enforced through RLS and query filtering.
- The app remains stable if realtime is temporarily unavailable.

## Pre-release safety checklist

Run this checklist before generating any release build:

- Confirm `APP_ENV=production` is passed.
- Confirm `SUPABASE_URL` points to the production Supabase project.
- Confirm `SUPABASE_ANON_KEY` or `SUPABASE_PUBLISHABLE_KEY` belongs to the production project.
- Confirm `PASSWORD_RESET_REDIRECT_URL` is a valid production HTTPS URL.
- Confirm `EMAIL_CONFIRMATION_REDIRECT_URL` is a valid production HTTPS URL.
- Confirm no real keys are committed in Dart files.
- Confirm no real keys are committed in Markdown files.
- Confirm no real `.env` files are committed.
- Confirm `.gitignore` includes `.env` and `.env.*`.
- Run `dart format lib`.
- Run `flutter analyze`.
- Run the app with development config and confirm it still works.
- Run the app with production config and confirm login, company selection, dashboard loading, storage uploads, and reports work.
- Confirm production database has no unwanted test data before release.

## Key rotation note

If any real Supabase key is accidentally committed, remove it from the code and rotate the key from Supabase before continuing.

Do not rely only on deleting the key from the latest commit, because Git history may still expose it.
