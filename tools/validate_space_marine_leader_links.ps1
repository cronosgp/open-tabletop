$ErrorActionPreference = "Stop"

$snapshotPath = ".tools\wahapedia-e11"
$identityAuditPath = "docs\space-marines-source-identity-map.json"
$runtimeLinksPath = "scripts\edition_11\marine_leader_links.gd"
$supportLinksPath = "scripts\edition_11\support_attachments.gd"
$bookId = "000000139"
$factionId = "SM"

$audit = Get-Content -Encoding UTF8 $identityAuditPath -Raw | ConvertFrom-Json
if ($audit.source -ne "Wahapedia" -or $audit.edition -ne "11th" -or $audit.source_book_id -ne $bookId -or $audit.faction_id -ne $factionId) {
    throw "The identity audit does not match the selected Wahapedia e11 common-book scope."
}

$manifestPath = Join-Path $snapshotPath "snapshot-manifest.json"
$leaderPath = Join-Path $snapshotPath "Datasheets_leader.csv"
if (-not (Test-Path $manifestPath) -or -not (Test-Path $leaderPath)) {
    throw "The pinned Wahapedia snapshot or its manifest is missing."
}
$manifest = Get-Content -Encoding UTF8 $manifestPath -Raw | ConvertFrom-Json
$manifestLeader = $manifest.files | Where-Object { $_.name -eq "Datasheets_leader.csv" }
if (-not $manifestLeader) {
    throw "The snapshot manifest does not record Datasheets_leader.csv."
}
$leaderHash = (Get-FileHash $leaderPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($leaderHash -ne $manifestLeader.sha256) {
    throw "Datasheets_leader.csv does not match the pinned snapshot hash."
}
$updateMarkers = @(
    (Import-Csv -Delimiter "|" (Join-Path $snapshotPath "Last_update_before.csv")).last_update.Trim(),
    (Import-Csv -Delimiter "|" (Join-Path $snapshotPath "Last_update_after.csv")).last_update.Trim(),
    (Import-Csv -Delimiter "|" (Join-Path $snapshotPath "Last_update.csv")).last_update.Trim()
)
$manifestMarker = $manifest.last_update_marker.Trim().TrimEnd("|")
if (@($updateMarkers | Select-Object -Unique).Count -ne 1 -or $updateMarkers[0] -ne $manifestMarker -or $manifestMarker -ne $audit.source_export_updated_at) {
    throw "The export update markers do not match the pinned identity audit."
}

$identityById = @{}
foreach ($mapping in $audit.identity_mappings) {
    $identityById[[string]$mapping.source_datasheet_id] = [string]$mapping.identity
}
$expected = @{}
$sourceLeaderRows = @(Import-Csv -Delimiter "|" $leaderPath | Where-Object {
    $identityById.ContainsKey([string]$_.leader_id)
})
$inScopeRows = @($sourceLeaderRows | Where-Object {
    $identityById.ContainsKey([string]$_.attached_id)
})
foreach ($row in $inScopeRows) {
    $leader = $identityById[[string]$row.leader_id]
    $target = $identityById[[string]$row.attached_id]
    if (-not $expected.ContainsKey($leader)) {
        $expected[$leader] = @()
    }
    $expected[$leader] = @($expected[$leader]) + $target
}
if ($inScopeRows.Count -ne 153 -or $expected.Count -ne 37) {
    throw "The pinned source now has $($inScopeRows.Count) in-scope relations across $($expected.Count) datasheets; review the scope before accepting it."
}

function Read-TargetMap([string]$Path, [string]$StartPattern, [string]$EndPattern, [string]$Label) {
    $text = Get-Content -Encoding UTF8 $Path -Raw
    $block = [regex]::Match($text, "(?s)$StartPattern(?<body>.*?)$EndPattern")
    if (-not $block.Success) {
        throw "Could not read $Label from $Path."
    }
    $result = @{}
    foreach ($entry in [regex]::Matches($block.Groups["body"].Value, '(?m)^\s*"(?<identity>[a-z0-9-]+)"\s*:\s*\[(?<targets>[^\]]*)\]\s*,?\s*$')) {
        $targets = @([regex]::Matches($entry.Groups["targets"].Value, '"(?<target>[a-z0-9-]+)"') | ForEach-Object { $_.Groups["target"].Value })
        $result[$entry.Groups["identity"].Value] = $targets
    }
    if ($result.Count -eq 0) {
        throw "No entries were parsed from $Label."
    }
    return $result
}

function Assert-MapsEqual([hashtable]$ExpectedMap, [hashtable]$ActualMap, [string]$Label) {
    $missing = @($ExpectedMap.Keys | Where-Object { -not $ActualMap.ContainsKey($_) })
    $extra = @($ActualMap.Keys | Where-Object { -not $ExpectedMap.ContainsKey($_) })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "$Label identity mismatch; missing: $($missing -join ', '); extra: $($extra -join ', ')."
    }
    foreach ($identity in $ExpectedMap.Keys) {
        $expectedTargets = @($ExpectedMap[$identity] | Sort-Object)
        $actualTargets = @($ActualMap[$identity] | Sort-Object)
        if (($expectedTargets -join "|") -ne ($actualTargets -join "|")) {
            throw "$Label targets differ for $identity; expected [$($expectedTargets -join ', ')], got [$($actualTargets -join ', ')]."
        }
    }
}

$runtime = Read-TargetMap $runtimeLinksPath 'const TARGETS := \{' '\r?\n\}' "runtime Leader/Support targets"
Assert-MapsEqual $expected $runtime "Runtime relationship map"

$supports = Read-TargetMap $supportLinksPath 'const BODYGUARDS := \{' '\}\r?\nconst CONDITIONAL_BODYGUARDS' "Support bodyguards"
foreach ($identity in $supports.Keys) {
    if (-not $expected.ContainsKey($identity)) {
        throw "Support map identity $identity has no in-scope source relationships."
    }
    $expectedSupportTargets = @($expected[$identity] | Sort-Object)
    $actualSupportTargets = @($supports[$identity] | Sort-Object)
    if (($expectedSupportTargets -join "|") -ne ($actualSupportTargets -join "|")) {
        throw "Support targets differ from the source for $identity."
    }
}
$conditional = Read-TargetMap $supportLinksPath 'const CONDITIONAL_BODYGUARDS := \{' '\}' "conditional Support targets"
foreach ($identity in $conditional.Keys) {
    if (-not $expected.ContainsKey($identity)) {
        throw "Conditional Support identity $identity has no in-scope source relationships."
    }
    $expectedConditionalTargets = @($expected[$identity] | Sort-Object)
    $actualConditionalTargets = @($conditional[$identity] | Sort-Object)
    if (($expectedConditionalTargets -join "|") -ne ($actualConditionalTargets -join "|")) {
        throw "Conditional Support targets differ from the source for $identity."
    }
}

$externalCount = $sourceLeaderRows.Count - $inScopeRows.Count
Write-Output "Wahapedia e11 Leader/Support links: $($inScopeRows.Count)/153 exact across $($expected.Count) datasheets; $externalCount out-of-scope targets excluded."
