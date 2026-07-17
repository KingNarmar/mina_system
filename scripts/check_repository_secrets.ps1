[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Push-Location $repoRoot
try {
  $trackedFiles = @(git ls-files)
  if ($LASTEXITCODE -ne 0) {
    throw 'git ls-files failed.'
  }

  $forbiddenNames = @(
    '(?i)(^|/)\.env($|\.)',
    '(?i)(^|/)key\.properties$',
    '(?i)\.(pfx|p12|jks|keystore|pem|key)$'
  )

  $badFiles = foreach ($file in $trackedFiles) {
    foreach ($pattern in $forbiddenNames) {
      if ($file -match $pattern) {
        $file
        break
      }
    }
  }

  if ($badFiles) {
    throw "Tracked secret-bearing file types detected:`n$($badFiles -join "`n")"
  }

  $privateKeyPattern = '-----BEGIN ' + '(RSA |EC |OPENSSH )?' + 'PRIVATE KEY-----'
  $contentPatterns = @(
    '(?i)service[_ -]?role\s*[:=]\s*["''][A-Za-z0-9._-]{24,}',
    '(?i)(password|token|secret|private[_ -]?key)\s*[:=]\s*["''][^"'']{16,}["'']',
    $privateKeyPattern
  )

  $violations = New-Object System.Collections.Generic.List[string]
  foreach ($file in $trackedFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
    $extension = [IO.Path]::GetExtension($file).ToLowerInvariant()
    if ($extension -in @('.png', '.jpg', '.jpeg', '.webp', '.ico', '.pdf', '.zip', '.exe', '.dll')) { continue }

    $content = Get-Content -LiteralPath $file -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { continue }
    foreach ($pattern in $contentPatterns) {
      if ($content -match $pattern) {
        $violations.Add("$file matched $pattern")
      }
    }
  }

  if ($violations.Count -gt 0) {
    throw "Possible committed secrets detected:`n$($violations -join "`n")"
  }

  Write-Host 'Repository secrets scan passed.'
} finally {
  Pop-Location
}
