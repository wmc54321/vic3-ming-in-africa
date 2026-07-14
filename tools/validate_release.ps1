param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = "Stop"
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$ModRoot = Join-Path $RepositoryRoot "mod\ming_in_africa"
$errors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError([string]$Message) {
    $script:errors.Add($Message)
}

$legacyDescriptor = Get-Content -LiteralPath (Join-Path $ModRoot "descriptor.mod") -Raw
$launcherDescriptor = Get-Content -LiteralPath (Join-Path $RepositoryRoot "mod\ming_in_africa.mod") -Raw
$metadataPath = Join-Path $ModRoot ".metadata\metadata.json"
$metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json

$legacyVersion = [regex]::Match($legacyDescriptor, '(?m)^version="([^"]+)"').Groups[1].Value
$launcherVersion = [regex]::Match($launcherDescriptor, '(?m)^version="([^"]+)"').Groups[1].Value
$versions = @(@($legacyVersion, $launcherVersion, [string]$metadata.version) | Select-Object -Unique)
if ($versions.Count -ne 1 -or [string]::IsNullOrWhiteSpace($versions[0])) {
    Add-ValidationError "Version mismatch across descriptor.mod, ming_in_africa.mod, and metadata.json."
}

$legacyGameVersion = [regex]::Match($legacyDescriptor, '(?m)^supported_version="([^"]+)"').Groups[1].Value
$launcherGameVersion = [regex]::Match($launcherDescriptor, '(?m)^supported_version="([^"]+)"').Groups[1].Value
$gameVersions = @(@($legacyGameVersion, $launcherGameVersion, [string]$metadata.supported_game_version) | Select-Object -Unique)
if ($gameVersions.Count -ne 1 -or [string]::IsNullOrWhiteSpace($gameVersions[0])) {
    Add-ValidationError "Supported game version mismatch across launcher metadata."
}

foreach ($required in @("LICENSE", "NOTICE.md", "README.md", "CHANGELOG.md", "mod\ming_in_africa\thumbnail.png", "mod\ming_in_africa\.metadata\thumbnail.png")) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot $required))) {
        Add-ValidationError "Missing required release file: $required"
    }
}

$thumbnail = Join-Path $ModRoot "thumbnail.png"
$metadataThumbnail = Join-Path $ModRoot ".metadata\thumbnail.png"
if ((Test-Path $thumbnail) -and (Test-Path $metadataThumbnail)) {
    if ((Get-FileHash -LiteralPath $thumbnail).Hash -ne (Get-FileHash -LiteralPath $metadataThumbnail).Hash) {
        Add-ValidationError "Launcher thumbnails do not match."
    }
}

foreach ($localization in Get-ChildItem -LiteralPath (Join-Path $ModRoot "localization") -Recurse -Filter "*.yml") {
    $bytes = [IO.File]::ReadAllBytes($localization.FullName)
    if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
        Add-ValidationError "Localization must use UTF-8 BOM: $($localization.FullName)"
    }
    $keys = Get-Content -LiteralPath $localization.FullName | ForEach-Object {
        if ($_ -match '^\s+([^#\s][^:]*):') { $Matches[1] }
    }
    foreach ($duplicate in $keys | Group-Object | Where-Object Count -gt 1) {
        Add-ValidationError "Duplicate localization key '$($duplicate.Name)' in $($localization.FullName)"
    }
}

foreach ($scriptFile in Get-ChildItem -LiteralPath $ModRoot -Recurse -File | Where-Object Extension -in @(".txt", ".mod")) {
    $content = Get-Content -LiteralPath $scriptFile.FullName -Raw
    $openBraces = ([regex]::Matches($content, '\{')).Count
    $closeBraces = ([regex]::Matches($content, '\}')).Count
    if ($openBraces -ne $closeBraces) {
        Add-ValidationError "Unbalanced braces in $($scriptFile.FullName): $openBraces opening, $closeBraces closing."
    }
}

foreach ($versionedDocument in @("README.md", "CHANGELOG.md", "docs\workshop-description.md")) {
    $content = Get-Content -LiteralPath (Join-Path $RepositoryRoot $versionedDocument) -Raw
    if ($content -notmatch [regex]::Escape([string]$metadata.version)) {
        Add-ValidationError "Current mod version is missing from $versionedDocument"
    }
}

$textExtensions = @(".md", ".txt", ".mod", ".json", ".ps1", ".yml", ".example")
foreach ($file in Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File | Where-Object {
    $textExtensions -contains $_.Extension -and $_.FullName -notmatch '[\\/]\.git[\\/]'
}) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    if ($content -match '(?i)C:\\Users\\|steamapps\\common') {
        Add-ValidationError "Machine-specific path found in $($file.FullName)"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Release validation failed with $($errors.Count) error(s)."
}

Write-Host "Release validation passed. Mod version: $($versions[0]); game version: $($gameVersions[0])."
