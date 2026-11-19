[CmdletBinding()]
param([string]$JavaHome = $env:JAVA_HOME, [string]$AndroidSdk = $env:ANDROID_HOME,
      [switch]$Release)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $JavaHome -or -not (Test-Path (Join-Path $JavaHome 'bin/java.exe'))) { throw 'Set -JavaHome to JDK 17 or 21.' }
if (-not $AndroidSdk -or -not (Test-Path $AndroidSdk)) { throw 'Set -AndroidSdk to an Android SDK with platform 36 and build-tools 35.0.0.' }
$env:JAVA_HOME = $JavaHome
$env:ANDROID_HOME = $AndroidSdk
$env:GRADLE_USER_HOME = Join-Path $projectRoot '.tools/gradle'
$source = Join-Path $projectRoot 'upstream/keepassdx'
$extraArgs = @()
$localInit = Join-Path $projectRoot '.tools/offline-tests.init.gradle'
if (Test-Path $localInit) { $extraArgs = @('--init-script', $localInit) }
$gradle = Join-Path $projectRoot '.tools/gradle-8.14.2/bin/gradle.bat'
if (-not (Test-Path $gradle)) { $gradle = Join-Path $source 'gradlew.bat' }
Push-Location $source
try {
    & $gradle ':app:testLibreDebugUnitTest' ':app:lintLibreDebug' ':app:assembleLibreDebug' --console=plain --no-daemon --no-configuration-cache --max-workers=4 '-Pkotlin.compiler.execution.strategy=in-process' @extraArgs
    if ($LASTEXITCODE -ne 0) { throw 'Android build or required checks failed.' }
    $apk = Join-Path $source 'app/build/outputs/apk/libre/debug/app-libre-debug.apk'
    & python (Join-Path $PSScriptRoot 'check-android-native.py') $apk
    if ($LASTEXITCODE -ne 0) { throw 'Android 16 KB ELF alignment check failed.' }
    $zipalign = Join-Path $AndroidSdk 'build-tools/35.0.0/zipalign.exe'
    & $zipalign -c -P 16 4 $apk
    if ($LASTEXITCODE -ne 0) { throw 'APK ZIP alignment check failed.' }
    $target = Join-Path $projectRoot 'dist/android'
    New-Item -ItemType Directory -Force $target | Out-Null
    Copy-Item -LiteralPath 'app/build/outputs/apk/libre/debug/app-libre-debug.apk' -Destination (Join-Path $target 'LocalVault-Android-test.apk')
    Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/ANDROID-SETUP.zh-CN.md') -Destination $target
    Copy-Item -LiteralPath 'LICENSE' -Destination (Join-Path $target 'KeePassDX-LICENSE.txt')
    if ($Release) {
        # Use an external private signing key; never commit or distribute it with source.
        foreach ($name in @('LOCALVAULT_KEYSTORE','LOCALVAULT_KEY_ALIAS','LOCALVAULT_STORE_PASSWORD','LOCALVAULT_KEY_PASSWORD')) {
            if (-not [Environment]::GetEnvironmentVariable($name)) { throw "Missing release signing environment variable: $name" }
        }
        & $gradle ':app:assembleLibreRelease' --console=plain --no-daemon --no-configuration-cache
        if ($LASTEXITCODE -ne 0) { throw 'Release build failed.' }
        Copy-Item -LiteralPath 'app/build/outputs/apk/libre/release/app-libre-release.apk' -Destination (Join-Path $target 'LocalVault-Android.apk')
    }
} finally { Pop-Location }
