[CmdletBinding()]
param(
  [string]$ArtifactsDirectory = (Join-Path $PSScriptRoot '..\dist\windows'),
  [string]$OutputFile = 'SHA256SUMS.txt'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$directory = (Resolve-Path -LiteralPath $ArtifactsDirectory).Path
$outputPath = Join-Path $directory $OutputFile
$releaseFiles = Get-ChildItem -LiteralPath $directory -File |
  Where-Object { $_.Name -ne $OutputFile -and $_.Name -match '^MINA-System-Windows-x64-.+\.(exe|zip)$' } |
  Sort-Object Name

if (-not $releaseFiles) {
  throw "No Windows release assets were found in '$directory'."
}

$lines = foreach ($file in $releaseFiles) {
  $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
  "$hash  $($file.Name)"
}

[System.IO.File]::WriteAllLines($outputPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote SHA-256 checksums to $outputPath"
Get-Content -LiteralPath $outputPath
