[CmdletBinding()]
param([string]$JavaHome = $env:JAVA_HOME, [string]$AndroidSdk = $env:ANDROID_HOME)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$fixture = Join-Path $projectRoot 'tests/android-fixture'
$out = Join-Path $projectRoot 'build/android-fixture'
$tools = Join-Path $AndroidSdk 'build-tools/35.0.0'
$androidJar = Join-Path $AndroidSdk 'platforms/android-36/android.jar'
New-Item -ItemType Directory -Force "$out/classes", "$out/dex" | Out-Null
$sources = Get-ChildItem $fixture -Filter '*.java' | ForEach-Object FullName
& "$JavaHome/bin/javac.exe" -encoding UTF-8 -source 8 -target 8 -bootclasspath $androidJar -d "$out/classes" @sources
if ($LASTEXITCODE -ne 0) { throw 'Fixture compilation failed' }
& "$tools/aapt2.exe" link -I $androidJar --manifest "$fixture/AndroidManifest.xml" -o "$out/fixture-unsigned.apk"
if ($LASTEXITCODE -ne 0) { throw 'Fixture resource linking failed' }
$env:JAVA_HOME = $JavaHome
$classes = Get-ChildItem "$out/classes" -Recurse -Filter '*.class' | ForEach-Object FullName
& "$tools/d8.bat" --lib $androidJar --output "$out/dex" @classes
if ($LASTEXITCODE -ne 0) { throw 'Fixture DEX generation failed' }
$archive = [System.IO.Compression.ZipFile]::Open("$out/fixture-unsigned.apk", [System.IO.Compression.ZipArchiveMode]::Update)
try {
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, "$out/dex/classes.dex", 'classes.dex') | Out-Null
    $testVault = Join-Path $projectRoot 'build/test-vault/LocalVault-test.kdbx'
    if (Test-Path $testVault) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $testVault, 'assets/test.kdbx') | Out-Null
    }
}
finally { $archive.Dispose() }
& "$tools/zipalign.exe" -f 4 "$out/fixture-unsigned.apk" "$out/fixture-aligned.apk"
if ($LASTEXITCODE -ne 0) { throw 'Fixture alignment failed' }
$testKey = Join-Path $env:USERPROFILE '.android/debug.keystore'
& "$tools/apksigner.bat" sign --ks $testKey --ks-pass pass:android --key-pass pass:android --out "$out/LocalVault-TestForm.apk" "$out/fixture-aligned.apk"
if ($LASTEXITCODE -ne 0) { throw 'Fixture test signing failed' }
Write-Output "$out/LocalVault-TestForm.apk"
