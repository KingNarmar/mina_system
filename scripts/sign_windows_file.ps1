[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$FilePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedFile = (Resolve-Path -LiteralPath $FilePath).Path

function Resolve-SignTool {
  if ($env:SIGNTOOL_PATH) {
    if (-not (Test-Path -LiteralPath $env:SIGNTOOL_PATH -PathType Leaf)) {
      throw "SIGNTOOL_PATH does not point to a file."
    }
    return (Resolve-Path -LiteralPath $env:SIGNTOOL_PATH).Path
  }

  $command = Get-Command signtool.exe -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $kitsRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
  if (Test-Path -LiteralPath $kitsRoot) {
    $candidate = Get-ChildItem -LiteralPath $kitsRoot -Directory |
      Sort-Object Name -Descending |
      ForEach-Object { Join-Path $_.FullName 'x64\signtool.exe' } |
      Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
      Select-Object -First 1
    if ($candidate) {
      return $candidate
    }
  }

  throw 'signtool.exe was not found. Install the Windows SDK or set SIGNTOOL_PATH.'
}

$timestampUrl = $env:WINDOWS_SIGN_TIMESTAMP_URL
if ([string]::IsNullOrWhiteSpace($timestampUrl)) {
  throw 'WINDOWS_SIGN_TIMESTAMP_URL is required and must point to an RFC3161 timestamp service.'
}

$signtool = Resolve-SignTool
$arguments = @('sign', '/fd', 'SHA256', '/tr', $timestampUrl, '/td', 'SHA256', '/v')

if (-not [string]::IsNullOrWhiteSpace($env:WINDOWS_SIGN_PFX_PATH)) {
  $pfxPath = (Resolve-Path -LiteralPath $env:WINDOWS_SIGN_PFX_PATH).Path
  $arguments += @('/f', $pfxPath)
  if (-not [string]::IsNullOrWhiteSpace($env:WINDOWS_SIGN_PFX_PASSWORD)) {
    $arguments += @('/p', $env:WINDOWS_SIGN_PFX_PASSWORD)
  }
} elseif (-not [string]::IsNullOrWhiteSpace($env:WINDOWS_SIGN_CERT_SHA1)) {
  $thumbprint = ($env:WINDOWS_SIGN_CERT_SHA1 -replace '\s', '')
  $arguments += @('/sha1', $thumbprint)
  if ($env:WINDOWS_SIGN_CERT_STORE -and $env:WINDOWS_SIGN_CERT_STORE -ne 'My') {
    $arguments += @('/s', $env:WINDOWS_SIGN_CERT_STORE)
  }
  if ($env:WINDOWS_SIGN_CERT_STORE_SCOPE -eq 'machine') {
    $arguments += '/sm'
  }
} else {
  throw 'Set WINDOWS_SIGN_PFX_PATH or WINDOWS_SIGN_CERT_SHA1 before enabling signing.'
}

$arguments += $resolvedFile
Write-Host "Authenticode signing: $resolvedFile"
& $signtool @arguments
if ($LASTEXITCODE -ne 0) {
  throw "signtool sign failed for '$resolvedFile' with exit code $LASTEXITCODE."
}

& $signtool verify /pa /v $resolvedFile
if ($LASTEXITCODE -ne 0) {
  throw "signtool verify failed for '$resolvedFile' with exit code $LASTEXITCODE."
}
