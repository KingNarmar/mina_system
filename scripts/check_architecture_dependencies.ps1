[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$violations = New-Object System.Collections.Generic.List[string]

$domainFiles = Get-ChildItem -Path (Join-Path $repoRoot 'lib') -Recurse -Filter '*.dart' -File |
  Where-Object { $_.FullName -match '[\\/]domain[\\/]' }

$domainForbidden = @(
  'package:flutter/',
  'package:flutter_bloc/',
  'package:supabase',
  'package:shared_preferences/',
  'package:file_picker/',
  'package:image_picker/'
)

foreach ($file in $domainFiles) {
  $lines = Get-Content -LiteralPath $file.FullName
  for ($index = 0; $index -lt $lines.Count; $index++) {
    foreach ($token in $domainForbidden) {
      if ($lines[$index] -like "*$token*") {
        $relative = [IO.Path]::GetRelativePath($repoRoot, $file.FullName)
        $violations.Add("${relative}:$($index + 1) imports forbidden dependency '$token'")
      }
    }
  }
}

$presentationFiles = Get-ChildItem -Path (Join-Path $repoRoot 'lib') -Recurse -Filter '*.dart' -File |
  Where-Object { $_.FullName -match '[\\/]presentation[\\/]' }

foreach ($file in $presentationFiles) {
  $lines = Get-Content -LiteralPath $file.FullName
  for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match '^\s*import\s+[''"]package:supabase') {
      $relative = [IO.Path]::GetRelativePath($repoRoot, $file.FullName)
      $violations.Add("${relative}:$($index + 1) imports Supabase directly from presentation")
    }
  }
}

if ($violations.Count -gt 0) {
  throw "Architecture dependency violations detected:`n$($violations -join "`n")"
}

Write-Host 'Architecture dependency checks passed.'
