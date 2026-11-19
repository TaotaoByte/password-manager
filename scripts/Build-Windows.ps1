[CmdletBinding()]
param([string]$MsysRoot)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $MsysRoot) { $MsysRoot = Join-Path $projectRoot '.tools/msys64' }
$bash = Join-Path $MsysRoot 'usr/bin/bash.exe'
if (-not (Test-Path -LiteralPath $bash)) { throw 'MSYS2 not found. See docs/BUILD.md.' }
$env:MSYSTEM = 'UCRT64'
$env:CHERE_INVOKING = '1'
$stage = Join-Path $projectRoot 'build/windows-package'
$env:LOCALVAULT_PACKAGE_DIR = $stage
Push-Location $projectRoot
try {
    & $bash -lc './scripts/build-windows.sh'
    if ($LASTEXITCODE -ne 0) { throw 'Windows build or required tests failed.' }
    $zip = Join-Path $projectRoot 'dist/LocalVault-Windows-x64.zip'
    if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip)
    & (Join-Path $PSScriptRoot 'Deploy-Windows.ps1') -StagePath $stage
} finally { Pop-Location }
