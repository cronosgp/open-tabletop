param(
    [string]$SnapshotPath = ".tools\wahapedia\11e\space-marines\20261021T130623Z",
    [string]$IdentityAuditPath = "docs\space-marines-source-identity-map.json",
    [string]$RuntimeLinksPath = "scripts\edition_11\marine_leader_links.gd"
)

$ErrorActionPreference = "Stop"
$bookId = "000000139"
$factionId = "SM"

$audit = Get-Content -Encoding UTF8 $IdentityAuditPath -Raw | ConvertFrom-Json
if ($audit.source -ne "Wahapedia" -or $audit.edition -ne "11th" -or $audit.source_book_id -ne $bookId -or $audit.faction_id -ne $factionId) {
    throw "The identity audit does not match the selected Wahapedia e11 common-book scope."
}

$manifestPath = Join-Path $SnapshotPath "manifest.json"
if (-not (Test-Path $manifestPath)) { $manifestPath = Join-Path $SnapshotPath "snapshot-manifest.json" }
$datasheetsPath = Join-Path $SnapshotPath "Datasheets.csv"
$leaderPath = Join-Path $SnapshotPath "Datasheets_leader.csv"
if (-not (Test-Path $manifestPath) -or -not (Test-Path $datasheetsPath) -or -not (Test-Path $leaderPath)) {
    throw "The selected Wahapedia snapshot, datasheets table or manifest is missing."
}
$manifest = Get-Content -Encoding UTF8 $manifestPath -Raw | ConvertFrom-Json
$manifestFiles = @($manifest.files)
if ($manifestFiles.Count -eq 0) {
    throw "The snapshot manifest does not record its source files."
}
foreach ($file in $manifestFiles) {
    $fileName = [string]$file.filename
    if ([string]::IsNullOrWhiteSpace($fileName)) { $fileName = [string]$file.name }
    $expectedHash = [string]$file.sha256
    if ([string]::IsNullOrWhiteSpace($fileName) -or [string]::IsNullOrWhiteSpace($expectedHash)) {
        throw "The snapshot manifest contains a file without a name or SHA-256."
    }
    $filePath = Join-Path $SnapshotPath $fileName
    if (-not (Test-Path $filePath)) { throw "Snapshot file is missing: $fileName" }
    $actualHash = (Get-FileHash $filePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne $expectedHash.ToLowerInvariant()) { throw "Snapshot file hash mismatch: $fileName" }
}
$manifestDateMatch = [regex]::Match([string]$manifest.source_export_updated_at, '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')
$manifestMarker = if ($manifestDateMatch.Success) { $manifestDateMatch.Value } else { [string]$manifest.last_update_marker.Trim().TrimEnd("|") }
$updateMarkers = @()
foreach ($markerName in @("Last_update_before.csv", "Last_update_after.csv", "Last_update.csv")) {
    $markerPath = Join-Path $SnapshotPath $markerName
    if (Test-Path $markerPath) {
        $markerRows = @(Import-Csv -Delimiter "|" $markerPath)
        foreach ($row in $markerRows) {
            if (-not [string]::IsNullOrWhiteSpace([string]$row.last_update)) { $updateMarkers += [string]$row.last_update.Trim() }
        }
    }
}
if ($updateMarkers.Count -eq 0 -or @($updateMarkers | Select-Object -Unique).Count -ne 1 -or $updateMarkers[0] -ne $manifestMarker) {
    throw "The export update marker does not match the selected snapshot manifest."
}
$snapshotDate = [datetime]::ParseExact($manifestMarker, "yyyy-MM-dd HH:mm:ss", [Globalization.CultureInfo]::InvariantCulture)
$identityDateText = ([string]$audit.source_export_updated_at).Substring(0, 19)
$identityDate = [datetime]::ParseExact($identityDateText, "yyyy-MM-dd HH:mm:ss", [Globalization.CultureInfo]::InvariantCulture)
if ($identityDate -gt $snapshotDate) {
    throw "The identity map is newer than the selected datasheet snapshot."
}

$sourceDatasheets = Import-Csv -Delimiter "|" $datasheetsPath
$sourceById = @{}
foreach ($row in $sourceDatasheets) {
    if ($sourceById.ContainsKey([string]$row.id)) { throw "Duplicate datasheet ID in the selected export: $($row.id)" }
    $sourceById[[string]$row.id] = $row
}
$identityById = @{}
foreach ($mapping in $audit.identity_mappings) {
    $sourceId = [string]$mapping.source_datasheet_id
    $identity = [string]$mapping.identity
    if ([string]::IsNullOrWhiteSpace($sourceId) -or [string]::IsNullOrWhiteSpace($identity) -or $identityById.ContainsKey($sourceId) -or ($identityById.Values -contains $identity)) {
        throw "The identity map contains an empty or duplicate source ID/runtime identity."
    }
    if (-not $sourceById.ContainsKey($sourceId)) { throw "Identity-map datasheet ID is absent from the selected export: $sourceId" }
    $sourceRow = $sourceById[$sourceId]
    $sourceName = ([string]$sourceRow.name).Replace("’", "'").Replace("‘", "'").Trim()
    $mappedName = ([string]$mapping.source_name).Replace("’", "'").Replace("‘", "'").Trim()
    if ([string]$sourceRow.source_id -ne $bookId -or [string]$sourceRow.faction_id -ne $factionId -or $sourceName -ine $mappedName) {
        throw "Identity-map source facts differ from the selected export for $sourceId."
    }
    $identityById[$sourceId] = $identity
}
if ($identityById.Count -ne 85 -or $identityById.Count -ne [int]$audit.source_subject_count) {
    throw "The identity map covers $($identityById.Count) records, not the expected common-book set."
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

$runtime = Read-TargetMap $RuntimeLinksPath 'const TARGETS := \{' '\r?\n\}' "runtime Leader targets"
Assert-MapsEqual $expected $runtime "Runtime relationship map"

$externalCount = $sourceLeaderRows.Count - $inScopeRows.Count
Write-Output "Wahapedia e11 common-book Leader links: $($inScopeRows.Count)/153 exact across $($expected.Count) datasheets; $externalCount out-of-scope targets excluded."
Write-Output "Snapshot $($manifest.snapshot_id): $($manifestFiles.Count)/$($manifestFiles.Count) manifest hashes passed; $($identityById.Count) common-book identities matched source ID, name, faction and book. Identity map: $($audit.source_export_updated_at); current export: $manifestMarker."
Write-Output "Cross-book BODYGUARD/Support attachment mappings are not certified by this common-book Leader audit."
