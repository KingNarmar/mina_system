[CmdletBinding()]
param(
  [string]$SupabaseUrl = $env:SUPABASE_URL,
  [string]$SupabasePublishableKey = $env:SUPABASE_PUBLISHABLE_KEY,
  [string]$PasswordResetRedirectUrl = $env:PASSWORD_RESET_REDIRECT_URL,
  [string]$EmailConfirmationRedirectUrl = $env:EMAIL_CONFIRMATION_REDIRECT_URL,
  [string]$AppPublisher = 'King Narmar',
  [string]$OutputDirectory = '',
  [switch]$SkipValidation,
  [switch]$SkipInstaller,
  [switch]$SkipSigning
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $IsWindows) {
  throw 'Windows release packaging must run on Windows.'
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
  $OutputDirectory = Join-Path $repoRoot 'dist\windows'
}
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)

function Invoke-Checked {
  param(
    [Parameter(Mandatory = $true)][string]$Command,
    [Parameter(Mandatory = $true)][string[]]$Arguments
  )

  Write-Host "> $Command $($Arguments -join ' ')"
  & $Command @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code ${LASTEXITCODE}: $Command"
  }
}

function Assert-HttpsUrl {
  param([string]$Name, [string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) {
    throw "$Name is required."
  }
  $uri = $null
  if (-not [Uri]::TryCreate($Value, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
    throw "$Name must be a valid HTTPS URL."
  }
}

function Resolve-InnoCompiler {
  if ($env:ISCC_PATH) {
    if (-not (Test-Path -LiteralPath $env:ISCC_PATH -PathType Leaf)) {
      throw 'ISCC_PATH does not point to ISCC.exe.'
    }
    return (Resolve-Path -LiteralPath $env:ISCC_PATH).Path
  }

  $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
  if ($command) { return $command.Source }

  $candidates = @(
    (Join-Path $env:ProgramFiles 'Inno Setup 7\ISCC.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 7\ISCC.exe'),
    (Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe')
  )
  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
  }

  throw 'ISCC.exe was not found. Install Inno Setup 6/7 or set ISCC_PATH.'
}

function Get-AppVersion {
  $pubspec = Get-Content -LiteralPath (Join-Path $repoRoot 'pubspec.yaml') -Raw
  $match = [regex]::Match($pubspec, '(?m)^version:\s*(?<name>\d+\.\d+\.\d+)\+(?<build>\d+)\s*$')
  if (-not $match.Success) {
    throw 'Could not read semantic version and build number from pubspec.yaml.'
  }
  return [pscustomobject]@{
    Name = $match.Groups['name'].Value
    Build = [int]$match.Groups['build'].Value
    Quad = "$($match.Groups['name'].Value).$($match.Groups['build'].Value)"
  }
}

Assert-HttpsUrl 'SUPABASE_URL' $SupabaseUrl
Assert-HttpsUrl 'PASSWORD_RESET_REDIRECT_URL' $PasswordResetRedirectUrl
Assert-HttpsUrl 'EMAIL_CONFIRMATION_REDIRECT_URL' $EmailConfirmationRedirectUrl
if ([string]::IsNullOrWhiteSpace($SupabasePublishableKey)) {
  throw 'SUPABASE_PUBLISHABLE_KEY is required.'
}

$version = Get-AppVersion
$flutter = (Get-Command flutter -ErrorAction Stop).Source

Push-Location $repoRoot
try {
  if (-not $SkipValidation) {
    Invoke-Checked $flutter @('pub', 'get')
    Invoke-Checked 'dart' @('format', '--output=none', '--set-exit-if-changed', 'lib', 'test')
    Invoke-Checked $flutter @('analyze')
    Invoke-Checked $flutter @('test')
    $architectureArguments = @('-NoProfile', '-File', (Join-Path $PSScriptRoot 'check_architecture_dependencies.ps1'))
    & git rev-parse --verify origin/main *> $null
    if ($LASTEXITCODE -eq 0) {
      $architectureArguments += @('-BaseRef', 'origin/main')
    }
    Invoke-Checked 'pwsh' $architectureArguments
    Invoke-Checked 'pwsh' @('-NoProfile', '-File', (Join-Path $PSScriptRoot 'check_repository_secrets.ps1'))
  }

  $buildArguments = @(
    'build', 'windows', '--release',
    '--dart-define=APP_ENV=production',
    "--dart-define=SUPABASE_URL=$SupabaseUrl",
    "--dart-define=SUPABASE_PUBLISHABLE_KEY=$SupabasePublishableKey",
    "--dart-define=PASSWORD_RESET_REDIRECT_URL=$PasswordResetRedirectUrl",
    "--dart-define=EMAIL_CONFIRMATION_REDIRECT_URL=$EmailConfirmationRedirectUrl"
  )
  Invoke-Checked $flutter $buildArguments

  $releaseExe = Get-ChildItem -LiteralPath (Join-Path $repoRoot 'build\windows') -Recurse -Filter 'mina_system.exe' -File |
    Where-Object { $_.FullName -match '[\\/]Release[\\/]mina_system\.exe$' } |
    Select-Object -First 1
  if (-not $releaseExe) {
    throw 'Windows release executable was not found after flutter build windows.'
  }

  $bundleDirectory = $releaseExe.Directory.FullName
  $requiredBundleEntries = @(
    (Join-Path $bundleDirectory 'mina_system.exe'),
    (Join-Path $bundleDirectory 'flutter_windows.dll'),
    (Join-Path $bundleDirectory 'data\flutter_assets')
  )
  foreach ($entry in $requiredBundleEntries) {
    if (-not (Test-Path -LiteralPath $entry)) {
      throw "Required Windows bundle entry is missing: $entry"
    }
  }

  if (Test-Path -LiteralPath $OutputDirectory) {
    Remove-Item -LiteralPath $OutputDirectory -Recurse -Force
  }
  New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null

  $stagingDirectory = Join-Path $OutputDirectory 'portable-staging'
  New-Item -ItemType Directory -Path $stagingDirectory -Force | Out-Null
  Copy-Item -Path (Join-Path $bundleDirectory '*') -Destination $stagingDirectory -Recurse -Force

  $readme = @"
M.I.N.A System for Windows
Version: $($version.Name) (build $($version.Build))

Requirements:
- 64-bit Windows 10 or Windows 11.
- Internet connection for Live Mode.
- A company account/access approval for Live Mode.

Portable package:
1. Extract the full ZIP to a local folder.
2. Keep all files and the data folder together.
3. Run mina_system.exe.

The ZIP is installer-free, but application data still uses the normal Windows user profile directories. Do not run the EXE directly from inside the ZIP archive.

If Windows reports a missing Microsoft Visual C++ runtime DLL, install the current Microsoft Visual C++ 2015-2022 Redistributable (x64) from Microsoft and retry.

Legal:
Privacy Policy: https://kingnarmar.com/mina-system/privacy-policy
Account Deletion: https://kingnarmar.com/mina-system/account-deletion
"@
  [IO.File]::WriteAllText((Join-Path $stagingDirectory 'README-Windows.txt'), $readme, [Text.UTF8Encoding]::new($false))

  $signScript = Join-Path $PSScriptRoot 'sign_windows_file.ps1'
  if (-not $SkipSigning) {
    $peFiles = Get-ChildItem -LiteralPath $stagingDirectory -Recurse -File |
      Where-Object { $_.Extension -in @('.exe', '.dll') }
    foreach ($file in $peFiles) {
      Invoke-Checked 'pwsh' @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $signScript, $file.FullName)
    }
  }

  $portableZip = Join-Path $OutputDirectory 'MINA-System-Windows-x64-Portable.zip'
  Compress-Archive -Path (Join-Path $stagingDirectory '*') -DestinationPath $portableZip -CompressionLevel Optimal -Force

  if (-not $SkipInstaller) {
    $iscc = Resolve-InnoCompiler
    $issFile = Join-Path $repoRoot 'installer\mina_system.iss'
    $isccArguments = @(
      "/DMyAppVersion=$($version.Name)",
      "/DMyAppVersionQuad=$($version.Quad)",
      "/DMyAppPublisher=$AppPublisher",
      "/DBuildOutputDir=$stagingDirectory",
      "/DOutputDir=$OutputDirectory"
    )

    if (-not $SkipSigning) {
      $powerShellPath = (Get-Command powershell.exe -ErrorAction Stop).Source
      $signCommand = "$powerShellPath -NoProfile -ExecutionPolicy Bypass -File `$q$signScript`$q `$f"
      $isccArguments += '/DEnableSigning=1'
      $isccArguments += "/Smina_sign=$signCommand"
    }

    $isccArguments += $issFile
    Invoke-Checked $iscc $isccArguments

    $installer = Join-Path $OutputDirectory 'MINA-System-Windows-x64-Setup.exe'
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
      throw 'Inno Setup completed but the expected installer was not found.'
    }
  }

  Remove-Item -LiteralPath $stagingDirectory -Recurse -Force
  Invoke-Checked 'pwsh' @('-NoProfile', '-File', (Join-Path $PSScriptRoot 'create_release_checksums.ps1'), '-ArtifactsDirectory', $OutputDirectory)

  Write-Host ''
  Write-Host 'Windows release artifacts:'
  Get-ChildItem -LiteralPath $OutputDirectory -File | Sort-Object Name | ForEach-Object {
    Write-Host "- $($_.FullName)"
  }
} finally {
  Pop-Location
}
