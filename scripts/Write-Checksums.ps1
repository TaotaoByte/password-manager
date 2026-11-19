$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $projectRoot 'dist'
$files = @('LocalVault-Windows-x64.zip','android/LocalVault-Android-test.apk','KeePassXC-Browser-1.10.4.1-Chromium.zip')
$lines = foreach ($relative in $files) {
    $digest = Get-FileHash -LiteralPath (Join-Path $dist $relative) -Algorithm SHA256
    '{0}  {1}' -f $digest.Hash.ToLowerInvariant(), $relative
}
[System.IO.File]::WriteAllLines((Join-Path $dist 'SHA256SUMS.txt'), $lines, [System.Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/VALIDATION.md') -Destination (Join-Path $dist '验收记录.md') -Force
