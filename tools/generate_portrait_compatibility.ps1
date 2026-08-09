[CmdletBinding()]
param(
    [string]$GameRoot,
    [switch]$Check
)

$ErrorActionPreference = "Stop"
$RepositoryRoot = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($GameRoot)) {
    $environmentPath = Join-Path $RepositoryRoot ".env.local"
    if (Test-Path -LiteralPath $environmentPath -PathType Leaf) {
        $gameRootLine = Get-Content -LiteralPath $environmentPath |
            Where-Object { $_ -match '^VICTORIA3_GAME_ROOT=' } |
            Select-Object -First 1
        if ($gameRootLine) {
            $GameRoot = $gameRootLine -replace '^VICTORIA3_GAME_ROOT=', ''
        }
    }
}

if ([string]::IsNullOrWhiteSpace($GameRoot)) {
    throw "GameRoot is required. Pass -GameRoot or set VICTORIA3_GAME_ROOT in .env.local."
}

$SourceRoot = Join-Path $GameRoot "gfx\portraits\portrait_modifiers"
$OutputRoot = Join-Path $RepositoryRoot "mod\ming_in_africa\gfx\portraits\portrait_modifiers"

$ClothesBlock = @'
    # Ming and post-Manchu Qing royal clothing. These routes use base-game genes
    # and apply to current and future rulers and heirs without editing templates.
    mgn_ming_monarch_clothes = {
        dna_modifiers = {
            accessory = {
                mode = add
                gene = outfits
                template = chinese_imperial_outfits
                range = { 0.5 1 }
            }
        }
        weight = {
            base = 0
            modifier = {
                add = 90000
                scope:character ?= {
                    OR = {
                        is_ruler_of_own_country = yes
                        is_heir_of_own_country = yes
                    }
                    exists = owner
                    owner = {
                        c:MGN ?= this
                        OR = {
                            has_law = law_type:law_monarchy
                            has_law = law_type:law_social_monarchy
                        }
                    }
                }
            }
        }
    }

    mgn_qing_han_monarch_clothes = {
        dna_modifiers = {
            accessory = {
                mode = add
                gene = outfits
                template = chinese_imperial_outfits
                range = { 0.5 1 }
            }
        }
        weight = {
            base = 0
            modifier = {
                add = 90000
                scope:character ?= {
                    OR = {
                        is_ruler_of_own_country = yes
                        is_heir_of_own_country = yes
                    }
                    exists = owner
                    owner = {
                        c:CHI ?= this
                        NOT = { country_has_primary_culture = cu:manchu }
                        OR = {
                            has_law = law_type:law_monarchy
                            has_law = law_type:law_social_monarchy
                        }
                    }
                }
            }
        }
    }
'@

$HeadgearBlock = @'
    # Ming and post-Manchu Qing royal headgear. The lower half of the base-game
    # common Chinese template is the round-cap route used by the reference mod.
    mgn_ming_monarch_headgear = {
        dna_modifiers = {
            accessory = {
                mode = add
                gene = headgear
                template = chinese_common_headgear
                range = { 0 0.5 }
            }
        }
        weight = {
            base = 0
            modifier = {
                add = 90000
                scope:character ?= {
                    OR = {
                        is_ruler_of_own_country = yes
                        is_heir_of_own_country = yes
                    }
                    exists = owner
                    owner = {
                        c:MGN ?= this
                        OR = {
                            has_law = law_type:law_monarchy
                            has_law = law_type:law_social_monarchy
                        }
                    }
                }
            }
        }
    }

    mgn_qing_han_monarch_headgear = {
        dna_modifiers = {
            accessory = {
                mode = add
                gene = headgear
                template = chinese_common_headgear
                range = { 0 0.5 }
            }
        }
        weight = {
            base = 0
            modifier = {
                add = 90000
                scope:character ?= {
                    OR = {
                        is_ruler_of_own_country = yes
                        is_heir_of_own_country = yes
                    }
                    exists = owner
                    owner = {
                        c:CHI ?= this
                        NOT = { country_has_primary_culture = cu:manchu }
                        OR = {
                            has_law = law_type:law_monarchy
                            has_law = law_type:law_social_monarchy
                        }
                    }
                }
            }
        }
    }
'@

function Get-NormalizedText {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing portrait modifier source: $Path"
    }

    return [IO.File]::ReadAllText($Path).Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd()
}

function Get-GeneratedPortraitFile {
    param(
        [string]$SourcePath,
        [string]$RootKey,
        [string]$Injection
    )

    $source = Get-NormalizedText $SourcePath
    if (-not $source.StartsWith("$RootKey = {")) {
        throw "Unexpected portrait modifier root in $SourcePath"
    }

    $closingIndex = $source.LastIndexOf('}')
    if ($closingIndex -lt 0 -or $source.Substring($closingIndex).Trim() -ne '}') {
        throw "Could not locate final root brace in $SourcePath"
    }

    $body = $source.Substring(0, $closingIndex).TrimEnd()
    $sourceName = [IO.Path]::GetFileName($SourcePath)
    return "# Generated from the current Victoria 3 $sourceName by tools/generate_portrait_compatibility.ps1.`n# Full virtual-path override; do not edit by hand.`n" + $body + "`n`n" + $Injection.TrimEnd() + "`n}`n"
}

$targets = @(
    [ordered]@{ Name = "01_clothes.txt"; Root = "clothes"; Block = $ClothesBlock },
    [ordered]@{ Name = "01_headgear.txt"; Root = "headgear"; Block = $HeadgearBlock }
)

foreach ($target in $targets) {
    $sourcePath = Join-Path $SourceRoot $target.Name
    $outputPath = Join-Path $OutputRoot $target.Name
    $expected = Get-GeneratedPortraitFile -SourcePath $sourcePath -RootKey $target.Root -Injection $target.Block

    if ($Check) {
        if (-not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
            throw "Generated portrait modifier is missing: $($target.Name)"
        }

        $actual = [IO.File]::ReadAllText($outputPath).Replace("`r`n", "`n").Replace("`r", "`n")
        if ($actual -cne $expected) {
            throw "Generated portrait modifier is stale: $($target.Name)"
        }
        continue
    }

    if (-not (Test-Path -LiteralPath $OutputRoot)) {
        New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    }
    [IO.File]::WriteAllText($outputPath, $expected, [Text.UTF8Encoding]::new($false))
}

if ($Check) {
    Write-Host "Portrait compatibility overrides are current."
}
else {
    Write-Host "Generated portrait overrides for Great Ming and post-Manchu Qing rulers and heirs."
}
