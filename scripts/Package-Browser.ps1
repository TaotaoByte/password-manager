$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $projectRoot 'upstream/keepassxc-browser'
$target = Join-Path $projectRoot 'dist/browser'
if (-not (Test-Path (Join-Path $source 'LICENSE'))) { throw 'Browser sources are missing. Run Restore-Sources.ps1 first.' }
New-Item -ItemType Directory -Force $target | Out-Null
Copy-Item -Path (Join-Path $source 'keepassxc-browser/*') -Destination $target -Recurse -Force
Copy-Item -LiteralPath (Join-Path $source 'dist/manifest_chromium.json') -Destination (Join-Path $target 'manifest.json') -Force
Copy-Item -LiteralPath (Join-Path $source 'LICENSE') -Destination (Join-Path $target 'LICENSE') -Force
$manifest = Get-Content (Join-Path $target 'manifest.json') -Raw | ConvertFrom-Json
if ($manifest.version -ne '1.10.4.1') { throw 'Unexpected browser extension version.' }
Compress-Archive -Path (Join-Path $target '*') -DestinationPath (Join-Path $projectRoot 'dist/KeePassXC-Browser-1.10.4.1-Chromium.zip') -Force
