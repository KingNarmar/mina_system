[CmdletBinding()]
param(
  [string]$BaseRef = 'origin/main'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot
try {
  git rev-parse --verify $BaseRef *> $null
  if ($LASTEXITCODE -ne 0) {
    throw "Base ref '$BaseRef' is unavailable. Fetch the target branch before running the secret scan."
  }

  $changedFiles = @(git diff --name-only --diff-filter=ACMR "$BaseRef...HEAD")
  if ($LASTEXITCODE -ne 0) {
    throw "Could not determine changed files against '$BaseRef'."
  }

  if ($changedFiles.Count -eq 0) {
    Write-Host "No changed files to scan against $BaseRef."
    return
  }

  $forbiddenNames = @(
    '(?i)(^|/)\.env($|\.)',
    '(?i)(^|/)key\.properties$',
    '(?i)\.(pfx|p12|jks|keystore|pem|key)$'
  )

  $badFiles = foreach ($file in $changedFiles) {
    foreach ($pattern in $forbiddenNames) {
      if ($file -match $pattern) {
        $file
        break
      }
    }
  }

  if ($badFiles) {
    throw "Secret-bearing file types were added or modified:`n$($badFiles -join "`n")"
  }

  $privateKeyPattern = '-----BEGIN ' + '(RSA |EC |OPENSSH )?' + 'PRIVATE KEY-----'
  $contentPatterns = @(
    '(?i)\bghp_[A-Za-z0-9]{30,}\b',
    '(?i)\bgithub_pat_[A-Za-z0-9_]{40,}\b',
    '(?i)\b(sk_live_|sk_test_)[A-Za-z0-9]{20,}\b',
    '(?i)\bsb_secret_[A-Za-z0-9_-]{20,}\b',
    '(?i)\beyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\b',
    $privateKeyPattern
  )

  $binaryExtensions = @('.png', '.jpg', '.jpeg', '.webp', '.ico', '.pdf', '.zip', '.exe', '.dll')
  $violations = New-Object System.Collections.Generic.List[string]

  foreach ($file in $changedFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
    $extension = [IO.Path]::GetExtension($file).ToLowerInvariant()
    if ($extension -in $binaryExtensions) { continue }

    $lines = Get-Content -LiteralPath $file -ErrorAction SilentlyContinue
    if ($null -eq $lines) { continue }

    for ($index = 0; $index -lt $lines.Count; $index++) {
      foreach ($pattern in $contentPatterns) {
        if ($lines[$index] -match $pattern) {
          $violations.Add("${file}:$($index + 1) matched a secret token pattern")
        }
      }
    }
  }

  if ($violations.Count -gt 0) {
    throw "Possible committed secrets detected in changed files:`n$($violations -join "`n")"
  }

  Write-Host "Repository secret delta scan passed against $BaseRef."
} finally {
  Pop-Location
}
