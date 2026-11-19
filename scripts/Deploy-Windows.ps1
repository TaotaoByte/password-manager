[CmdletBinding()]
param([string]$StagePath)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $StagePath) { $StagePath = Join-Path $projectRoot 'build/windows-package' }
$source = [System.IO.Path]::GetFullPath($StagePath)
$destination = Join-Path $projectRoot 'dist/windows'
if (-not (Test-Path -LiteralPath (Join-Path $source 'KeePassXC.exe'))) { throw 'Prepared Windows package is missing.' }
$exe = Join-Path $destination 'KeePassXC.exe'
$running = Get-Process KeePassXC -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe }
if ($running) { throw '新版已准备好。请正常退出密码管理器后再运行 scripts/Deploy-Windows.ps1；不会强制关闭当前会话。' }
$backup = Join-Path $projectRoot ('.tools/rollback/windows-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force $backup,$destination | Out-Null
foreach ($name in @('KeePassXC.exe','keepassxc-cli.exe','keepassxc-proxy.exe')) {
    $old = Join-Path $destination $name
    if (Test-Path -LiteralPath $old) { Copy-Item -LiteralPath $old -Destination $backup }
}
foreach ($item in Get-ChildItem -LiteralPath $source -Force) {
    if ($item.Name -eq 'config' -and (Test-Path -LiteralPath (Join-Path $destination 'config'))) { continue }
    Copy-Item -LiteralPath $item.FullName -Destination $destination -Recurse -Force
}
Write-Output 'Windows 程序已更新；原有 config 与个人密码库文件保留。'
