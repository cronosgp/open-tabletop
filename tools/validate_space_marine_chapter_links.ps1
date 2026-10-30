param(
    [string]$SnapshotPath = ".tools\wahapedia-e11-live-refresh-20261029T072022Z-final-integration",
    [string]$GodotPath = ".tools\godot\Godot_v4.7.2-stable_win64_console.exe",
    [string]$RuntimeIdentityPath = ".tools\space-marine-runtime-identities-current.json",
    [string]$RuntimeLinksPath = "scripts\edition_11\marine_leader_links.gd",
    [string]$SupportLinksPath = "scripts\edition_11\support_attachments.gd"
)

$ErrorActionPreference = "Stop"
$bookNames = [ordered]@{
    "000000139" = "Space Marines"
    "000000036" = "Space Wolves"
    "000000023" = "Dark Angels"
    "000000162" = "Black Templars"
    "000000021" = "Blood Angels"
    "000000035" = "Deathwatch"
}
$expectedBookCounts = @{
    "000000139" = 85
    "000000036" = 21
    "000000023" = 16
    "000000162" = 15
    "000000021" = 14
    "000000035" = 10
}

$manifestPath = Join-Path $SnapshotPath "manifest.json"
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Snapshot manifest is missing: $manifestPath" }
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ([string]$manifest.edition -ne "11e") { throw "Expected a Wahapedia 11e source snapshot." }
$csvDirectory = $SnapshotPath
$filesToVerify = @()
if ([string]$manifest.mode -eq "live_download") {
    if ($manifest.provider -ne "wahapedia" -or $manifest.live_timestamp_bracket_checked -ne $true) { throw "Live export provenance is incomplete." }
    if ([string]$manifest.source_policy -notmatch "^wahapedia-e11-definitive-") { throw "Snapshot does not cite the selected Wahapedia e11 source policy." }
    $csvDirectory = Join-Path $SnapshotPath "raw"
    foreach ($entry in $manifest.files.PSObject.Properties) {
        $filesToVerify += [pscustomobject]@{ filename = "$($entry.Name).csv"; sha256 = [string]$entry.Value.sha256 }
    }
} else {
    foreach ($entry in $manifest.files) {
        $filesToVerify += [pscustomobject]@{ filename = [string]$entry.filename; sha256 = [string]$entry.sha256 }
    }
}
if ($filesToVerify.Count -lt 3) { throw "Snapshot manifest does not record the expected relational files." }
foreach ($file in $filesToVerify) {
    $path = Join-Path $csvDirectory $file.filename
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Snapshot file is missing: $($file.filename)" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($file.sha256) -or $actual -ne $file.sha256.ToLowerInvariant()) { throw "SHA-256 mismatch for $($file.filename)." }
}

$godotFullPath = (Resolve-Path -LiteralPath $GodotPath).Path
$runtimeIdentityFullPath = [System.IO.Path]::GetFullPath($RuntimeIdentityPath)
& $godotFullPath --headless --path (Get-Location).Path --script tools/export_space_marine_runtime_identities.gd -- --output $runtimeIdentityFullPath
if ($LASTEXITCODE -ne 0) { throw "Godot could not export runtime identity metadata (exit $LASTEXITCODE)." }
$runtimeIdentityAudit = Get-Content -LiteralPath $runtimeIdentityFullPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (@($runtimeIdentityAudit.missing_source_ids).Count -ne 0) { throw "Some runtime Marine profiles lack source IDs." }

$sources = Import-Csv -LiteralPath (Join-Path $csvDirectory "Source.csv") -Delimiter '|' -Encoding UTF8
$sourceById = @{}
foreach ($source in $sources) { $sourceById[[string]$source.id] = $source }
foreach ($bookId in $bookNames.Keys) {
    if (-not $sourceById.ContainsKey($bookId)) { throw "Source book $bookId is absent from the export." }
    if ([string]$sourceById[$bookId].name -ne [string]$bookNames[$bookId] -or [string]$sourceById[$bookId].edition -ne "11") {
        throw "Source book identity or edition does not match the expected current scope: $bookId."
    }
}

$datasheets = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets.csv") -Delimiter '|' -Encoding UTF8
$sourceById = @{}
foreach ($sheet in $datasheets) {
    if ($sourceById.ContainsKey([string]$sheet.id)) { throw "Duplicate source datasheet ID: $($sheet.id)" }
    $sourceById[[string]$sheet.id] = $sheet
}
$candidateById = @{}
foreach ($sheet in $datasheets) {
    $bookId = [string]$sheet.source_id
    if ($bookNames.Contains($bookId)) { $candidateById[[string]$sheet.id] = $sheet }
}
foreach ($bookId in $bookNames.Keys) {
    $count = @($candidateById.Values | Where-Object { [string]$_.source_id -eq $bookId }).Count
    if ($count -ne [int]$expectedBookCounts[$bookId]) { throw "Book $($bookNames[$bookId]) has $count source sheets; expected $($expectedBookCounts[$bookId]). Review the source scope." }
}
if ($candidateById.Count -ne 161) { throw "The current standard Marine inventory has $($candidateById.Count) sheets, not the expected 161." }

$identityById = @{}
$identityBySlug = @{}
foreach ($profile in $runtimeIdentityAudit.profiles) {
    $sourceId = [string]$profile.source_datasheet_id
    $identity = [string]$profile.identity
    if (-not $candidateById.ContainsKey($sourceId)) { throw "Runtime profile source ID is outside the six standard books: $sourceId / $identity" }
    if ($identityById.ContainsKey($sourceId) -or $identityBySlug.ContainsKey($identity)) { throw "Runtime source map contains a duplicate ID or identity: $sourceId / $identity" }
    $sheet = $candidateById[$sourceId]
    if ([string]$profile.source_book_id -ne [string]$sheet.source_id) { throw "Runtime book identity differs from the export for $identity." }
    $sourceName = ([string]$sheet.name).Replace([char]0x2019, [char]0x27).Replace([char]0x2018, [char]0x27).Trim()
    $runtimeName = ([string]$profile.source_name).Replace([char]0x2019, [char]0x27).Replace([char]0x2018, [char]0x27).Trim()
    if ($sourceName -ine $runtimeName) { throw "Runtime profile name differs from the source for $sourceId ($identity): $runtimeName / $sourceName" }
    $identityById[$sourceId] = $identity
    $identityBySlug[$identity] = $sourceId
}
$missingRuntime = @($candidateById.Keys | Where-Object { -not $identityById.ContainsKey($_) })
if ($runtimeIdentityAudit.profile_count -ne $candidateById.Count -or $identityById.Count -ne $candidateById.Count -or $missingRuntime.Count -ne 0) {
    throw "Expected a runtime profile for every one of the $($candidateById.Count) current standard Marine sheets; found $($identityById.Count) mappings and $($missingRuntime.Count) missing source identities."
}

$sourceEdges = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$leaderRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_leader.csv") -Delimiter '|' -Encoding UTF8
foreach ($row in $leaderRows) {
    $leaderId = [string]$row.leader_id
    $targetId = [string]$row.attached_id
    if ($identityById.ContainsKey($leaderId) -and $identityById.ContainsKey($targetId)) {
        [void]$sourceEdges.Add("$($identityById[$leaderId])|$($identityById[$targetId])")
    }
}

function Read-TargetMap([string]$Path, [string]$StartPattern, [string]$EndPattern, [string]$Label) {
    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $block = [regex]::Match($text, "(?s)$StartPattern(?<body>.*?)$EndPattern")
    if (-not $block.Success) { throw "Could not read $Label from $Path." }
    $result = @{}
    foreach ($entry in [regex]::Matches($block.Groups["body"].Value, '"(?<identity>[a-z0-9-]+)"\s*:\s*\[(?<targets>[^\]]*)\]\s*,?')) {
        $identity = $entry.Groups["identity"].Value
        if ($result.ContainsKey($identity)) { throw "Duplicate $Label identity: $identity" }
        $result[$identity] = @([regex]::Matches($entry.Groups["targets"].Value, '"(?<target>[a-z0-9-]+)"') | ForEach-Object { $_.Groups["target"].Value })
    }
    if ($result.Count -eq 0) { throw "No entries were parsed from $Label." }
    return $result
}

$commonMap = Read-TargetMap $RuntimeLinksPath 'const TARGETS := \{' '## Chapter-book targets' "common Leader map"
$chapterMap = Read-TargetMap $RuntimeLinksPath 'const CHAPTER_TARGETS := \{' '\r?\n\}\r?\n\s*\r?\nstatic func targets' "Chapter Leader map"
$runtimeEdges = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($map in @($commonMap, $chapterMap)) {
    foreach ($leader in $map.Keys) {
        foreach ($target in $map[$leader]) { [void]$runtimeEdges.Add("$leader|$target") }
    }
}
$missingEdges = @($sourceEdges | Where-Object { -not $runtimeEdges.Contains($_) } | Sort-Object)
$extraEdges = @($runtimeEdges | Where-Object { -not $sourceEdges.Contains($_) } | Sort-Object)
if ($runtimeEdges.Count -ne $sourceEdges.Count -or $missingEdges.Count -gt 0 -or $extraEdges.Count -gt 0) {
    throw "Leader link mismatch: source $($sourceEdges.Count), runtime $($runtimeEdges.Count), missing [$($missingEdges -join ', ')], extra [$($extraEdges -join ', ')]."
}

$sourceSupport = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($sourceId in $candidateById.Keys) {
    if ([string]$candidateById[$sourceId].is_support -ieq "true") { [void]$sourceSupport.Add($identityById[$sourceId]) }
}
$bodyguards = Read-TargetMap $SupportLinksPath 'const BODYGUARDS := \{' 'const CONDITIONAL_BODYGUARDS' "Support bodyguard map"
$conditional = Read-TargetMap $SupportLinksPath 'const CONDITIONAL_BODYGUARDS := \{' '\r?\n\r?\nstatic func' "conditional Support map"
$runtimeSupport = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($identity in $bodyguards.Keys) { [void]$runtimeSupport.Add($identity) }
$missingSupport = @($sourceSupport | Where-Object { -not $runtimeSupport.Contains($_) } | Sort-Object)
$extraSupport = @($runtimeSupport | Where-Object { -not $sourceSupport.Contains($_) } | Sort-Object)
if ($sourceSupport.Count -ne 14 -or $runtimeSupport.Count -ne $sourceSupport.Count -or $missingSupport.Count -gt 0 -or $extraSupport.Count -gt 0) {
    throw "Support identity mismatch: source $($sourceSupport.Count), runtime $($runtimeSupport.Count), missing [$($missingSupport -join ', ')], extra [$($extraSupport -join ', ')]."
}
foreach ($map in @($bodyguards, $conditional)) {
    foreach ($leader in $map.Keys) {
        $expectedTargets = @($sourceEdges | Where-Object { $_.StartsWith("$leader|", [System.StringComparison]::Ordinal) } | ForEach-Object { $_.Substring($leader.Length + 1) } | Sort-Object)
        $actualTargets = @($map[$leader] | Sort-Object)
        if (($expectedTargets -join "|") -ne ($actualTargets -join "|")) { throw "Support targets differ from the source relation map for $leader." }
    }
}

$snapshotId = [System.IO.Path]::GetFileName((Resolve-Path -LiteralPath $SnapshotPath).Path)
Write-Output "Wahapedia e11 Space Marine attachments: $($sourceEdges.Count) source relations exact across $($identityById.Count)/$($candidateById.Count) runtime/source identities."
Write-Output "Support: $($sourceSupport.Count)/14 static Support identities exact; conditional Support: $(@($conditional.Keys).Count) profile(s). Snapshot $snapshotId passed $($filesToVerify.Count)/$($filesToVerify.Count) manifest SHA-256 checks."
