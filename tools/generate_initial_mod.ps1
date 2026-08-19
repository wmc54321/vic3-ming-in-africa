param(
    [string]$GameRoot,
    [string]$ModRoot = (Join-Path $PSScriptRoot "..\mod\ming_in_africa")
)

$ErrorActionPreference = "Stop"

function Get-LocalEnvValue {
    param(
        [string]$Name,
        [string]$EnvPath = (Join-Path $PSScriptRoot "..\.env.local")
    )

    if (-not (Test-Path -LiteralPath $EnvPath)) { return $null }

    foreach ($line in Get-Content -LiteralPath $EnvPath) {
        $trimmed = $line.Trim()
        if ($trimmed -eq "" -or $trimmed.StartsWith("#")) { continue }
        if ($trimmed -match "^\s*$([regex]::Escape($Name))\s*=\s*(.+?)\s*$") {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }

    return $null
}

if (-not $GameRoot) {
    $GameRoot = Get-LocalEnvValue -Name "VICTORIA3_GAME_ROOT"
}

if (-not $GameRoot) {
    throw "Game root not set. Pass -GameRoot or create .env.local with VICTORIA3_GAME_ROOT=<Victoria 3 game directory>."
}

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

function Get-StatesFromRegionFiles {
    param(
        [string]$GameRoot,
        [string[]]$Files
    )

    $states = foreach ($file in $Files) {
        $path = Join-Path $GameRoot "map_data\state_regions\$file"
        $text = Get-Content -LiteralPath $path -Raw
        [regex]::Matches($text, "(?m)^STATE_[A-Z0-9_]+(?=\s*=\s*\{)") | ForEach-Object { $_.Value }
    }

    $states = $states | Select-Object -Unique
    return [System.Collections.Generic.HashSet[string]]::new([string[]]$states)
}

function Get-NamedBlock {
    param(
        [string]$Text,
        [string]$Name
    )

    $match = [regex]::Match($Text, "(?m)^$([regex]::Escape($Name))\s*=\s*\{")
    if (-not $match.Success) { throw "Could not find block $Name" }
    $open = $Text.IndexOf("{", $match.Index)
    $end = Get-BalancedBlockEnd -Text $Text -OpenBraceIndex $open
    return $Text.Substring($match.Index, $end - $match.Index + 1)
}

function Get-StateBlockRange {
    param(
        [string]$Text,
        [string]$State
    )

    $match = [regex]::Match($Text, "(?m)^[\t ]*s:$([regex]::Escape($State))\s*=\s*\{")
    if (-not $match.Success) { throw "Could not find state history block $State" }
    $open = $Text.IndexOf("{", $match.Index)
    $end = Get-BalancedBlockEnd -Text $Text -OpenBraceIndex $open
    return [pscustomobject]@{
        Index = $match.Index
        Length = $end - $match.Index + 1
        Text = $Text.Substring($match.Index, $end - $match.Index + 1)
    }
}

function Merge-StateCreateScopes {
    param(
        [string]$Text,
        [string]$State,
        [string]$Country
    )

    $stateRange = Get-StateBlockRange -Text $Text -State $State
    $block = $stateRange.Text
    $scopes = [System.Collections.Generic.List[object]]::new()
    foreach ($match in [regex]::Matches($block, "(?m)^[\t ]*create_state\s*=\s*\{")) {
        $open = $block.IndexOf("{", $match.Index)
        $end = Get-BalancedBlockEnd -Text $block -OpenBraceIndex $open
        $scopeText = $block.Substring($match.Index, $end - $match.Index + 1)
        if ($scopeText -match "country\s*=\s*c:$([regex]::Escape($Country))\b") {
            $scopes.Add([pscustomobject]@{ Index = $match.Index; End = $end; Text = $scopeText })
        }
    }

    if ($scopes.Count -ne 2) {
        throw "Expected two $Country create_state scopes in $State after ownership transfer; found $($scopes.Count)."
    }

    $provinces = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($scope in $scopes) {
        $provinceMatch = [regex]::Match($scope.Text, "owned_provinces\s*=\s*\{([^}]*)\}", "Singleline")
        if (-not $provinceMatch.Success) { throw "Missing owned_provinces in a $Country scope for $State" }
        foreach ($province in [regex]::Matches($provinceMatch.Groups[1].Value, "x[0-9A-Fa-f]+")) {
            if ($seen.Add($province.Value)) { $provinces.Add($province.Value) }
        }
    }

    $mergedScope = [regex]::Replace(
        $scopes[0].Text,
        "owned_provinces\s*=\s*\{[^}]*\}",
        "owned_provinces = { $($provinces -join ' ') }",
        1
    )
    $out = [System.Text.StringBuilder]::new()
    $cursor = 0
    for ($i = 0; $i -lt $scopes.Count; $i++) {
        $scope = $scopes[$i]
        [void]$out.Append($block.Substring($cursor, $scope.Index - $cursor))
        if ($i -eq 0) { [void]$out.Append($mergedScope) }
        $cursor = $scope.End + 1
    }
    [void]$out.Append($block.Substring($cursor))

    return $Text.Remove($stateRange.Index, $stateRange.Length).Insert($stateRange.Index, $out.ToString())
}

function Merge-RegionStateScopes {
    param(
        [string]$Text,
        [string]$State,
        [string]$Country
    )

    $stateRange = Get-StateBlockRange -Text $Text -State $State
    $block = $stateRange.Text
    $scopes = [System.Collections.Generic.List[object]]::new()
    foreach ($match in [regex]::Matches($block, "(?m)^(?<indent>[\t ]*)region_state:$([regex]::Escape($Country))\s*=\s*\{")) {
        $open = $block.IndexOf("{", $match.Index)
        $end = Get-BalancedBlockEnd -Text $block -OpenBraceIndex $open
        $scopes.Add([pscustomobject]@{
            Index = $match.Index
            Open = $open
            End = $end
            Indent = $match.Groups["indent"].Value
            Text = $block.Substring($match.Index, $end - $match.Index + 1)
        })
    }

    if ($scopes.Count -ne 2) {
        throw "Expected two region_state:$Country scopes in $State after ownership transfer; found $($scopes.Count)."
    }

    $mergedScope = $scopes[0].Text.Substring(0, $scopes[0].Open - $scopes[0].Index + 1)
    foreach ($scope in $scopes) {
        $body = $block.Substring($scope.Open + 1, $scope.End - $scope.Open - 1)
        if (-not [string]::IsNullOrWhiteSpace($body)) { $mergedScope += $body.TrimEnd() }
    }
    $mergedScope += "`r`n$($scopes[0].Indent)}"

    $out = [System.Text.StringBuilder]::new()
    $cursor = 0
    for ($i = 0; $i -lt $scopes.Count; $i++) {
        $scope = $scopes[$i]
        [void]$out.Append($block.Substring($cursor, $scope.Index - $cursor))
        if ($i -eq 0) { [void]$out.Append($mergedScope) }
        $cursor = $scope.End + 1
    }
    [void]$out.Append($block.Substring($cursor))

    return $Text.Remove($stateRange.Index, $stateRange.Length).Insert($stateRange.Index, $out.ToString())
}

function Get-CompanyRegionStates {
    param(
        [string]$GameRoot,
        [string]$ModRoot,
        [string]$TriggerName
    )

    $triggerPath = Join-Path $ModRoot "common\scripted_triggers\00_mgn_scripted_triggers.txt"
    $triggerText = Get-Content -LiteralPath $triggerPath -Raw
    $triggerBlock = Get-NamedBlock -Text $triggerText -Name $TriggerName
    $states = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($match in [regex]::Matches($triggerBlock, "state_region\s*=\s*s:(STATE_[A-Z0-9_]+)")) {
        [void]$states.Add($match.Groups[1].Value)
    }

    foreach ($geoMatch in [regex]::Matches($triggerBlock, "is_in_geographic_region\s*=\s*(geographic_region_[a-z0-9_]+)")) {
        $geoName = $geoMatch.Groups[1].Value
        $geoBlock = $null
        foreach ($file in Get-ChildItem -LiteralPath (Join-Path $GameRoot "common\geographic_regions") -Filter "*.txt") {
            $text = Get-Content -LiteralPath $file.FullName -Raw
            if ([regex]::IsMatch($text, "(?m)^$([regex]::Escape($geoName))\s*=\s*\{")) {
                $geoBlock = Get-NamedBlock -Text $text -Name $geoName
                break
            }
        }
        if (-not $geoBlock) { throw "Could not resolve geographic region $geoName" }

        foreach ($strategicMatch in [regex]::Matches($geoBlock, "sr:(region_[a-z0-9_]+)")) {
            $strategicName = $strategicMatch.Groups[1].Value
            $strategicBlock = $null
            foreach ($file in Get-ChildItem -LiteralPath (Join-Path $GameRoot "common\strategic_regions") -Filter "*.txt") {
                $text = Get-Content -LiteralPath $file.FullName -Raw
                if ([regex]::IsMatch($text, "(?m)^$([regex]::Escape($strategicName))\s*=\s*\{")) {
                    $strategicBlock = Get-NamedBlock -Text $text -Name $strategicName
                    break
                }
            }
            if (-not $strategicBlock) { throw "Could not resolve strategic region $strategicName" }
            foreach ($stateMatch in [regex]::Matches($strategicBlock, "\bSTATE_[A-Z0-9_]+\b")) {
                [void]$states.Add($stateMatch.Value)
            }
        }
    }

    foreach ($excludedMatch in [regex]::Matches($triggerBlock, "NOT\s*=\s*\{\s*state_region\s*=\s*s:(STATE_[A-Z0-9_]+)\s*\}")) {
        [void]$states.Remove($excludedMatch.Groups[1].Value)
    }

    return $states
}

function Convert-StateHistory {
    param(
        [string]$GameRoot,
        [string]$ModRoot,
        [System.Collections.Generic.HashSet[string]]$AfricaStates,
        [System.Collections.Generic.HashSet[string]]$AfricanHanHomelands,
        [System.Collections.Generic.HashSet[string]]$WesternHanHomelands,
        [System.Collections.Generic.HashSet[string]]$QingTibetStates,
        [hashtable]$CompanyCultureHomelands
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

        $block = $text.Substring($match.Index, $blockEndExclusive - $match.Index)
        if ($AfricaStates.Contains($state)) {
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
            if ($AfricanHanHomelands.Contains($state)) {
                $extraLines.Add("add_homeland = cu:african_han")
            }
            if ($WesternHanHomelands.Contains($state)) {
                $extraLines.Add("add_homeland = cu:western_han")
            }
            foreach ($culture in $CompanyCultureHomelands.Keys) {
                if ($CompanyCultureHomelands[$culture].Contains($state)) {
                    $extraLines.Add("add_homeland = cu:$culture")
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
            if ($QingTibetStates.Contains($state)) {
                $block = [regex]::Replace(
                    $block,
                    "country\s*=\s*c:TIB",
                    "country = c:CHI`r`n`t`t`tstate_type = unincorporated"
                )
            }

            $newHomelands = [System.Collections.Generic.List[string]]::new()
            if ($WesternHanHomelands.Contains($state)) {
                $newHomelands.Add("western_han")
            }
            foreach ($culture in $CompanyCultureHomelands.Keys) {
                if ($CompanyCultureHomelands[$culture].Contains($state)) {
                    $newHomelands.Add($culture)
                }
            }
            if ($newHomelands.Count -gt 0) {
                $closingBrace = $block.LastIndexOf("}")
                $insertAt = $block.LastIndexOf("`n", $closingBrace) + 1
                $insertText = ($newHomelands | ForEach-Object { "`tadd_homeland = cu:$_`r`n" }) -join ""
                $block = $block.Insert($insertAt, $insertText)
            }
            [void]$out.Append($block)
        }

        $cursor = $blockEndExclusive
    }

    [void]$out.Append($text.Substring($cursor))

    # Egypt is an African starting country but owns several Levantine states in 1836.
    # Transfer those non-African remnants back to the Ottomans so EGY does not survive.
    $result = $out.ToString()
    $result = [regex]::Replace($result, "country\s*=\s*c:EGY", "country = c:TUR")
    # Vanilla Adana starts split between Egypt and the Ottomans. Once both halves belong
    # to TUR they must be one state; duplicate same-owner scopes create an empty fragment.
    $result = Merge-StateCreateScopes -Text $result -State "STATE_ADANA" -Country "TUR"
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
        [string[]]$Files,
        [System.Collections.Generic.HashSet[string]]$GovernmentAdministrationStates,
        [string]$LocalChineseCulture
    )

    $targetDir = Join-Path $ModRoot "common\history\pops"
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    foreach ($file in $Files) {
        $sourcePath = Join-Path $GameRoot "common\history\pops\$file"
        $targetPath = Join-Path $ModRoot "common\history\pops\$file"
        $text = Get-Content -LiteralPath $sourcePath -Raw
        $text = [regex]::Replace($text, "region_state:[A-Z0-9_]+", "region_state:MGN")
        $text = Add-MgnStartingPops `
            -Text $text `
            -GovernmentAdministrationStates $GovernmentAdministrationStates `
            -LocalChineseCulture $LocalChineseCulture
        Set-Content -LiteralPath $targetPath -Value $text -Encoding UTF8
    }
}

function Get-StatesWithGovernmentAdministration {
    param(
        [string]$GameRoot,
        [string[]]$Files
    )

    $states = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($file in $Files) {
        $path = Join-Path $GameRoot "common\history\buildings\$file"
        $text = Get-Content -LiteralPath $path -Raw
        foreach ($match in [regex]::Matches($text, "(?m)^\s*s:(STATE_[A-Z0-9_]+)\s*=\s*\{")) {
            $open = $text.IndexOf("{", $match.Index)
            $end = Get-BalancedBlockEnd -Text $text -OpenBraceIndex $open
            $block = $text.Substring($match.Index, $end - $match.Index + 1)
            if ($block -match 'building\s*=\s*"building_government_administration"') {
                [void]$states.Add($match.Groups[1].Value)
            }
        }
    }

    return $states
}

function Add-MgnStartingPops {
    param(
        [string]$Text,
        [System.Collections.Generic.HashSet[string]]$GovernmentAdministrationStates,
        [string]$LocalChineseCulture
    )

    $matches = [regex]::Matches($Text, "(?m)^\s*s:(STATE_[A-Z0-9_]+)\s*=\s*\{")
    for ($i = $matches.Count - 1; $i -ge 0; $i--) {
        $match = $matches[$i]
        $state = $match.Groups[1].Value
        $open = $Text.IndexOf("{", $match.Index)
        $end = Get-BalancedBlockEnd -Text $Text -OpenBraceIndex $open

        if ($state -eq "STATE_LOWER_EGYPT") {
            $popDefinitions = @(
                @{ Culture = "han"; PopType = "bureaucrats"; Size = 1000 },
                @{ Culture = "western_han"; PopType = "bureaucrats"; Size = 3000 },
                @{ Culture = "african_han"; PopType = "bureaucrats"; Size = 1000 }
            )
        }
        else {
            $popType = if ($GovernmentAdministrationStates.Contains($state)) { "bureaucrats" } else { "clergymen" }
            $popDefinitions = @(
                @{ Culture = "han"; PopType = $popType; Size = 100 },
                @{ Culture = $LocalChineseCulture; PopType = $popType; Size = 500 }
            )
        }

        $insert = "`t`tregion_state:MGN = {`r`n"
        foreach ($pop in $popDefinitions) {
            $insert += "`t`t`tcreate_pop = {`r`n"
            $insert += "`t`t`t`tculture = $($pop.Culture)`r`n"
            $insert += "`t`t`t`tpop_type = $($pop.PopType)`r`n"
            $insert += "`t`t`t`tsize = $($pop.Size)`r`n"
            $insert += "`t`t`t}`r`n"
        }
        $insert += "`t`t}`r`n"
        $lineStart = $Text.LastIndexOf("`n", $end) + 1
        $Text = $Text.Insert($lineStart, $insert)
    }

    return $Text
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
    $text = Merge-RegionStateScopes -Text $text -State "STATE_ADANA" -Country "TUR"
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
    $text = Merge-RegionStateScopes -Text $text -State "STATE_ADANA" -Country "TUR"
    Set-Content -LiteralPath $targetPath -Value $text -Encoding UTF8
}

function Convert-EgyptSouthEuropeHistory {
    param(
        [string]$GameRoot,
        [string]$ModRoot
    )

    foreach ($category in @("buildings", "pops")) {
        $sourcePath = Join-Path $GameRoot "common\history\$category\01_south_europe.txt"
        $targetDir = Join-Path $ModRoot "common\history\$category"
        $targetPath = Join-Path $targetDir "01_south_europe.txt"
        $sourceText = Get-Content -LiteralPath $sourcePath -Raw
        $creteRange = Get-StateBlockRange -Text $sourceText -State "STATE_CRETE"
        $creteBlock = $creteRange.Text
        $creteBlock = [regex]::Replace($creteBlock, "region_state:EGY", "region_state:TUR")
        if ($category -eq "buildings") {
            $creteBlock = [regex]::Replace($creteBlock, 'country\s*=\s*"c:EGY"', 'country="c:TUR"')
            $creteBlock = [regex]::Replace($creteBlock, 'country\s*=\s*c:EGY', 'country = c:TUR')
        }

        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        $text = $sourceText.Remove($creteRange.Index, $creteRange.Length).Insert($creteRange.Index, $creteBlock)
        Set-Content -LiteralPath $targetPath -Value $text -Encoding utf8BOM
    }
}

function Convert-QingTibetCentralAsiaHistory {
    param(
        [string]$GameRoot,
        [string]$ModRoot
    )

    foreach ($category in @("buildings", "pops")) {
        $sourcePath = Join-Path $GameRoot "common\history\$category\09_central_asia.txt"
        $targetPath = Join-Path $ModRoot "common\history\$category\09_central_asia.txt"
        $text = Get-Content -LiteralPath $sourcePath -Raw
        $text = [regex]::Replace($text, "region_state:TIB", "region_state:CHI")
        if ($category -eq "buildings") {
            $text = [regex]::Replace($text, 'country\s*=\s*"c:TIB"', 'country="c:CHI"')
            $text = [regex]::Replace($text, 'country\s*=\s*c:TIB', 'country = c:CHI')
        }
        Set-Content -LiteralPath $targetPath -Value $text -Encoding UTF8
    }
}

$northAfricaStates = Get-StatesFromRegionFiles -GameRoot $GameRoot -Files @("03_north_africa.txt")
$subSaharanAfricaStates = Get-StatesFromRegionFiles -GameRoot $GameRoot -Files @("04_subsaharan_africa.txt")
$middleEastStates = Get-StatesFromRegionFiles -GameRoot $GameRoot -Files @("08_middle_east.txt")
$northAfricaAdministrationStates = Get-StatesWithGovernmentAdministration -GameRoot $GameRoot -Files @("03_north_africa.txt")
$subSaharanAdministrationStates = Get-StatesWithGovernmentAdministration -GameRoot $GameRoot -Files @("04_subsaharan_africa.txt")
$africaStates = [System.Collections.Generic.HashSet[string]]::new()
foreach ($state in $northAfricaStates) { [void]$africaStates.Add($state) }
foreach ($state in $subSaharanAfricaStates) { [void]$africaStates.Add($state) }
$westernHanHomelands = [System.Collections.Generic.HashSet[string]]::new()
foreach ($state in $northAfricaStates) { [void]$westernHanHomelands.Add($state) }
foreach ($state in $middleEastStates) { [void]$westernHanHomelands.Add($state) }
$qingTibetStates = [System.Collections.Generic.HashSet[string]]::new([string[]]@(
    "STATE_LHASA",
    "STATE_NGARI",
    "STATE_EASTERN_HIMALAYAS"
))
$companyCultureHomelands = @{
    haedong_han = Get-CompanyRegionStates -GameRoot $GameRoot -ModRoot $ModRoot -TriggerName "mgn_state_is_korean_company_region"
    nanyang_han = Get-CompanyRegionStates -GameRoot $GameRoot -ModRoot $ModRoot -TriggerName "mgn_state_is_lanfang_company_region"
    shuofang_han = Get-CompanyRegionStates -GameRoot $GameRoot -ModRoot $ModRoot -TriggerName "mgn_state_is_siberian_company_region"
    tianshan_han = Get-CompanyRegionStates -GameRoot $GameRoot -ModRoot $ModRoot -TriggerName "mgn_state_is_central_asian_company_region"
    fusang_han = Get-CompanyRegionStates -GameRoot $GameRoot -ModRoot $ModRoot -TriggerName "mgn_state_is_japanese_company_region"
    jiaonan_han = Get-CompanyRegionStates -GameRoot $GameRoot -ModRoot $ModRoot -TriggerName "mgn_state_is_southeast_asian_company_region"
}
Convert-StateHistory -GameRoot $GameRoot -ModRoot $ModRoot -AfricaStates $africaStates -AfricanHanHomelands $subSaharanAfricaStates -WesternHanHomelands $westernHanHomelands -QingTibetStates $qingTibetStates -CompanyCultureHomelands $companyCultureHomelands
Convert-BuildingHistory -GameRoot $GameRoot -ModRoot $ModRoot -Files @(
    "03_north_africa.txt",
    "04_subsaharan_africa.txt"
)
Convert-PopHistory -GameRoot $GameRoot -ModRoot $ModRoot -Files @(
    "03_north_africa.txt"
) -GovernmentAdministrationStates $northAfricaAdministrationStates -LocalChineseCulture "western_han"
Convert-PopHistory -GameRoot $GameRoot -ModRoot $ModRoot -Files @(
    "04_subsaharan_africa.txt"
) -GovernmentAdministrationStates $subSaharanAdministrationStates -LocalChineseCulture "african_han"
Convert-EgyptMiddleEastBuildings -GameRoot $GameRoot -ModRoot $ModRoot
Convert-EgyptMiddleEastPops -GameRoot $GameRoot -ModRoot $ModRoot
Convert-EgyptSouthEuropeHistory -GameRoot $GameRoot -ModRoot $ModRoot
Convert-QingTibetCentralAsiaHistory -GameRoot $GameRoot -ModRoot $ModRoot

Write-Host "Generated Africa state history for $($africaStates.Count) states."
Write-Host "Added African Han homelands to $($subSaharanAfricaStates.Count) Sub-Saharan states."
Write-Host "Added Western Han homelands to $($westernHanHomelands.Count) North African and Middle Eastern states."
foreach ($culture in $companyCultureHomelands.Keys | Sort-Object) {
    Write-Host "Added $culture homelands to $($companyCultureHomelands[$culture].Count) states from its company-region trigger."
}
Write-Host "Generated African building history files."
Write-Host "Generated African pop history files."
Write-Host "Added Han and local Chinese bureaucrats to $($northAfricaAdministrationStates.Count + $subSaharanAdministrationStates.Count) African states with government administrations; other African states received clergy."
Write-Host "Generated Middle East building history with Egyptian ownership reassigned to TUR."
Write-Host "Generated Middle East pop history with Egyptian ownership reassigned to TUR."
Write-Host "Generated same-name South European building and pop history overrides with Crete reassigned to TUR."
Write-Host "Generated Central Asian state, building, and pop history with Tibet directly owned by Qing as unincorporated territory."
