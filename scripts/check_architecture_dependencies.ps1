[CmdletBinding()]
param(
  [string]$BaseRef = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$violations = New-Object System.Collections.Generic.List[string]

Push-Location $repoRoot
try {
  if ([string]::IsNullOrWhiteSpace($BaseRef)) {
    $candidatePaths = @(git ls-files -- 'lib/**/*.dart')
    if ($LASTEXITCODE -ne 0) {
      throw 'git ls-files failed while preparing the architecture check.'
    }
  } else {
    & git rev-parse --verify $BaseRef *> $null
    if ($LASTEXITCODE -ne 0) {
      throw "Architecture-check base ref was not found: $BaseRef"
    }

    $candidatePaths = @(git diff --name-only --diff-filter=ACMR "$BaseRef...HEAD" -- 'lib/**/*.dart')
    if ($LASTEXITCODE -ne 0) {
      throw "git diff failed while comparing architecture changes with $BaseRef."
    }
    Write-Host "Architecture delta check against $BaseRef."
  }

  $candidatePaths = @($candidatePaths | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_ -PathType Leaf)
  })

  $domainForbidden = @(
    'package:flutter/',
    'package:flutter_bloc/',
    'package:supabase',
    'package:shared_preferences/',
    'package:file_picker/',
    'package:image_picker/'
  )

  foreach ($relative in $candidatePaths) {
    $normalized = $relative -replace '\\', '/'
    $lines = @(Get-Content -LiteralPath $relative)

    if ($normalized -match '(^|/)domain/') {
      for ($index = 0; $index -lt $lines.Count; $index++) {
        foreach ($token in $domainForbidden) {
          if ($lines[$index] -like "*$token*") {
            $violations.Add("${normalized}:$($index + 1) imports forbidden dependency '$token'")
          }
        }
      }
    }

    if ($normalized -match '(^|/)presentation/') {
      for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match '^\s*import\s+[''"]package:supabase') {
          $violations.Add("${normalized}:$($index + 1) imports Supabase directly from presentation")
        }
      }
    }
  }

  if ($violations.Count -gt 0) {
    throw "Architecture dependency violations detected:`n$($violations -join "`n")"
  }

  Write-Host "Architecture dependency checks passed for $($candidatePaths.Count) Dart file(s)."
} finally {
  Pop-Location
}
