param(
    [string]$GameRoot = "D:\SteamLibrary\steamapps\common\Victoria 3\game",
    [string]$ModRoot = (Join-Path $PSScriptRoot "..\mod\ming_in_africa")
)

$ErrorActionPreference = "Stop"

function Get-BalancedBlockEnd {
    param(
        [string]$Text,
        [int]$OpenBraceIndex
    )

    $depth = 0
    for ($i = $OpenBraceIndex; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($ch -eq "{") { $depth++ }
        elseif ($ch -eq "}") {
            $depth--
            if ($depth -eq 0) { return $i }
        }
    }

    throw "Unbalanced block starting at index $OpenBraceIndex"
}

function Get-AfricaStates {
    param([string]$GameRoot)

    $stateRegionFiles = @(
        "map_data\state_regions\03_north_africa.txt",
        "map_data\state_regions\04_subsaharan_africa.txt"
    )

    $states = foreach ($file in $stateRegionFiles) {
        $path = Join-Path $GameRoot $file
        $text = Get-Content -LiteralPath $path -Raw
        [regex]::Matches($text, "(?m)^STATE_[A-Z0-9_]+(?=\s*=\s*\{)") | ForEach-Object { $_.Value }
    }

    $states = $states | Select-Object -Unique
    return [System.Collections.Generic.HashSet[string]]::new([string[]]$states)
}

function Convert-StateHistory {
    param(
        [string]$GameRoot,
        [string]$ModRoot,
        [System.Collections.Generic.HashSet[string]]$AfricaStates
    )

    $sourcePath = Join-Path $GameRoot "common\history\states\00_states.txt"
    $targetPath = Join-Path $ModRoot "common\history\states\00_states.txt"
    $text = Get-Content -LiteralPath $sourcePath -Raw

    $pattern = [regex]"s:(STATE_[A-Z0-9_]+)\s*=\s*\{"
    $matches = $pattern.Matches($text)
    $out = New-Object System.Text.StringBuilder
    $cursor = 0

    foreach ($match in $matches) {
        $state = $match.Groups[1].Value
        $open = $text.IndexOf("{", $match.Index)
        $end = Get-BalancedBlockEnd -Text $text -OpenBraceIndex $open
        $blockEndExclusive = $end + 1

        [void]$out.Append($text.Substring($cursor, $match.Index - $cursor))

        if ($AfricaStates.Contains($state)) {
            $block = $text.Substring($match.Index, $blockEndExclusive - $match.Index)
            $provinceMatches = [regex]::Matches($block, "owned_provinces\s*=\s*\{([^}]*)\}", "Singleline")
            $provinceSet = [System.Collections.Generic.List[string]]::new()
            $seen = [System.Collections.Generic.HashSet[string]]::new()

            foreach ($pm in $provinceMatches) {
                $tokens = [regex]::Matches($pm.Groups[1].Value, "x[0-9A-Fa-f]+") | ForEach-Object { $_.Value }
                foreach ($token in $tokens) {
                    if ($seen.Add($token)) { $provinceSet.Add($token) }
                }
            }

            if ($provinceSet.Count -eq 0) {
                throw "No owned provinces found for $state"
            }

            $extraLines = [System.Collections.Generic.List[string]]::new()
            foreach ($line in ($block -split "`r?`n")) {
                if ($line -match "^\s*add_homeland\s*=") {
                    $extraLines.Add($line.Trim())
                }
            }

            [void]$out.Append("s:$state = {`r`n")
            [void]$out.Append("`tcreate_state = {`r`n")
            [void]$out.Append("`t`tcountry = c:MGN`r`n")
            [void]$out.Append("`t`towned_provinces = { $($provinceSet -join ' ') }`r`n")
            [void]$out.Append("`t}`r`n")
            if ($extraLines.Count -gt 0) {
                [void]$out.Append("`r`n")
                foreach ($line in $extraLines) {
                    [void]$out.Append("`t$line`r`n")
                }
            }
            [void]$out.Append("}")
        }
        else {
            [void]$out.Append($text.Substring($match.Index, $blockEndExclusive - $match.Index))
        }

        $cursor = $blockEndExclusive
    }

    [void]$out.Append($text.Substring($cursor))

    # Egypt is an African starting country but owns several Levantine states in 1836.
    # Transfer those non-African remnants back to the Ottomans so EGY does not survive.
    $result = $out.ToString()
    $result = [regex]::Replace($result, "country\s*=\s*c:EGY", "country = c:TUR")
    Set-Content -LiteralPath $targetPath -Value $result -Encoding UTF8
}

function Convert-BuildingHistory {
    param(
        [string]$GameRoot,
        [string]$ModRoot,
        [string[]]$Files
    )

    foreach ($file in $Files) {
        $sourcePath = Join-Path $GameRoot "common\history\buildings\$file"
        $targetPath = Join-Path $ModRoot "common\history\buildings\$file"
        $text = Get-Content -LiteralPath $sourcePath -Raw
        $text = [regex]::Replace($text, "region_state:[A-Z0-9_]+", "region_state:MGN")
        $text = [regex]::Replace($text, 'country\s*=\s*"c:[A-Z0-9_]+"', 'country="c:MGN"')
        $text = [regex]::Replace($text, 'country\s*=\s*c:[A-Z0-9_]+', 'country = c:MGN')
        Set-Content -LiteralPath $targetPath -Value $text -Encoding UTF8
    }
}

function Convert-PopHistory {
    param(
        [string]$GameRoot,
        [string]$ModRoot,
        [string[]]$Files
    )

    $targetDir = Join-Path $ModRoot "common\history\pops"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    foreach ($file in $Files) {
        $sourcePath = Join-Path $GameRoot "common\history\pops\$file"
        $targetPath = Join-Path $ModRoot "common\history\pops\$file"
        $text = Get-Content -LiteralPath $sourcePath -Raw
        $text = [regex]::Replace($text, "region_state:[A-Z0-9_]+", "region_state:MGN")
        Set-Content -LiteralPath $targetPath -Value $text -Encoding UTF8
    }
}

function Convert-EgyptMiddleEastBuildings {
    param(
        [string]$GameRoot,
        [string]$ModRoot
    )

    $sourcePath = Join-Path $GameRoot "common\history\buildings\08_middle_east.txt"
    $targetPath = Join-Path $ModRoot "common\history\buildings\08_middle_east.txt"
    $text = Get-Content -LiteralPath $sourcePath -Raw
    $text = [regex]::Replace($text, "region_state:EGY", "region_state:TUR")
    $text = [regex]::Replace($text, 'country\s*=\s*"c:EGY"', 'country="c:TUR"')
    Set-Content -LiteralPath $targetPath -Value $text -Encoding UTF8
}

function Convert-EgyptMiddleEastPops {
    param(
        [string]$GameRoot,
        [string]$ModRoot
    )

    $targetDir = Join-Path $ModRoot "common\history\pops"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    $sourcePath = Join-Path $GameRoot "common\history\pops\08_middle_east.txt"
    $targetPath = Join-Path $ModRoot "common\history\pops\08_middle_east.txt"
    $text = Get-Content -LiteralPath $sourcePath -Raw
    $text = [regex]::Replace($text, "region_state:EGY", "region_state:TUR")
    Set-Content -LiteralPath $targetPath -Value $text -Encoding UTF8
}

$africaStates = Get-AfricaStates -GameRoot $GameRoot
Convert-StateHistory -GameRoot $GameRoot -ModRoot $ModRoot -AfricaStates $africaStates
Convert-BuildingHistory -GameRoot $GameRoot -ModRoot $ModRoot -Files @(
    "03_north_africa.txt",
    "04_subsaharan_africa.txt"
)
Convert-PopHistory -GameRoot $GameRoot -ModRoot $ModRoot -Files @(
    "03_north_africa.txt",
    "04_subsaharan_africa.txt"
)
Convert-EgyptMiddleEastBuildings -GameRoot $GameRoot -ModRoot $ModRoot
Convert-EgyptMiddleEastPops -GameRoot $GameRoot -ModRoot $ModRoot

Write-Host "Generated Africa state history for $($africaStates.Count) states."
Write-Host "Generated African building history files."
Write-Host "Generated African pop history files."
Write-Host "Generated Middle East building history with Egyptian ownership reassigned to TUR."
Write-Host "Generated Middle East pop history with Egyptian ownership reassigned to TUR."
