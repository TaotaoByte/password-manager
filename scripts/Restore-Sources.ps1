[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$lock = Get-Content (Join-Path $projectRoot 'upstream.lock.json') -Raw | ConvertFrom-Json
foreach ($project in $lock.projects) {
    $target = Join-Path $projectRoot ('upstream/' + $project.name)
    if (-not (Test-Path $target)) {
        & git clone --depth 1 --branch $project.tag $project.url $target
        if ($LASTEXITCODE -ne 0) { throw "Clone failed: $($project.name)" }
    }
    $head = & git -C $target rev-parse HEAD
    if ($LASTEXITCODE -ne 0 -or $head -ne $project.commit) { throw "Source revision mismatch: $($project.name)" }
    $patch = Join-Path $projectRoot ('patches/' + $project.name + '.patch')
    if (Test-Path $patch) {
        & git -C $target apply --reverse --check $patch 2>$null
        if ($LASTEXITCODE -eq 0) { continue }
        & git -C $target apply --check $patch
        if ($LASTEXITCODE -ne 0) { throw "Existing edits differ from the patch: $($project.name). No changes made." }
        & git -C $target apply $patch
        if ($LASTEXITCODE -ne 0) { throw "Patch failed: $($project.name)" }
    }
}
