param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = "Stop"
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
& (Join-Path $PSScriptRoot "validate_release.ps1") -RepositoryRoot $RepositoryRoot

$metadata = Get-Content -LiteralPath (Join-Path $RepositoryRoot "mod\ming_in_africa\.metadata\metadata.json") -Raw | ConvertFrom-Json
$releaseRoot = Join-Path $RepositoryRoot "release"
$stagingRoot = Join-Path $releaseRoot "staging"
$archivePath = Join-Path $releaseRoot "ming_in_africa-v$($metadata.version).zip"

if (Test-Path -LiteralPath $stagingRoot) {
    Remove-Item -LiteralPath $stagingRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $stagingRoot | Out-Null

$stagedMod = Join-Path $stagingRoot "ming_in_africa"
Copy-Item -LiteralPath (Join-Path $RepositoryRoot "mod\ming_in_africa") -Destination $stagedMod -Recurse
Copy-Item -LiteralPath (Join-Path $RepositoryRoot "mod\ming_in_africa.mod") -Destination $stagingRoot

foreach ($developmentFile in @("AGENTS.md", "README.md")) {
    $path = Join-Path $stagedMod $developmentFile
    if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
}

if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}
Compress-Archive -Path (Join-Path $stagingRoot "*") -DestinationPath $archivePath -CompressionLevel Optimal
Remove-Item -LiteralPath $stagingRoot -Recurse -Force

Write-Host "Created release archive: $archivePath"
