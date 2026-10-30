param(
    [string]$SnapshotPath = ".tools/wahapedia/11e/space-marines/20261021T130623Z",
    [string]$ProfilePath = "scripts/edition_11/current_reference_marine_profiles.gd",
    [string]$CatalogPath = "scripts/edition_11/army_capabilities.gd",
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

function Format-SourceText([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return "—" }
    $text = [System.Net.WebUtility]::HtmlDecode(($Value -replace '<[^>]+>', ''))
    $text = ($text -replace '\s+', ' ').Trim()
    return $text -replace '\|', '\|'
}

$chapterBooks = [ordered]@{
    "000000162" = "Black Templars"
    "000000021" = "Blood Angels"
    "000000023" = "Dark Angels"
    "000000035" = "Deathwatch"
    "000000036" = "Space Wolves"
}

$manifestPath = Join-Path $SnapshotPath "manifest.json"
$manifestText = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8
$manifest = $manifestText | ConvertFrom-Json
if ($manifest.edition -ne "11e") { throw "Expected a verified 11e snapshot." }
$snapshotFiles = [System.Collections.Generic.List[object]]::new()
$csvDirectory = $SnapshotPath
if ($manifest.provider -eq "wahapedia" -and $manifest.mode -eq "live_download") {
    if ($manifest.live_timestamp_bracket_checked -ne $true -or [string]::IsNullOrWhiteSpace([string]$manifest.last_update_after.retrieved_at)) {
        throw "Live export manifest is missing its checked Last_update timestamp bracket."
    }
    if ($manifest.source_policy -notmatch "^wahapedia-e11-definitive-") { throw "Live export manifest does not identify the current Wahapedia 11e source policy." }
    $csvDirectory = Join-Path $SnapshotPath "raw"
    if (-not (Test-Path -LiteralPath $csvDirectory -PathType Container)) { throw "Live export raw directory is missing." }
    foreach ($entry in $manifest.files.PSObject.Properties) {
        $snapshotFiles.Add([pscustomobject]@{ filename = "$($entry.Name).csv"; sha256 = [string]$entry.Value.sha256 })
    }
    $snapshotId = [System.IO.Path]::GetFileName($SnapshotPath) -replace '^wahapedia-e11-live-refresh-', ''
    $retrievedUtc = [string]$manifest.last_update_after.retrieved_at
    $validationErrorCount = @($manifest.validation_errors).Count
    $structureNote = if ($manifest.structurally_valid -eq $true) { "The parent export passed structural validation." } else { "The parent export records $validationErrorCount structural validation findings; this gap report does not certify individual sheets, which require clean subject-scoped slices." }
} else {
    if ($manifest.dataset_scope -notmatch "Complete relational 40k export") { throw "Snapshot manifest does not identify a complete relational export." }
    foreach ($file in $manifest.files) {
        $snapshotFiles.Add([pscustomobject]@{ filename = [string]$file.filename; sha256 = [string]$file.sha256 })
    }
    $snapshotId = [string]$manifest.snapshot_id
    $retrievedUtc = [string]$manifest.retrieved_at_utc
    $validationErrorCount = 0
    $structureNote = "The snapshot is recorded as a complete relational export."
}
$requiredTables = @("Factions", "Source", "Datasheets", "Datasheets_abilities", "Datasheets_keywords", "Datasheets_models", "Datasheets_options", "Datasheets_wargear", "Datasheets_unit_composition", "Datasheets_models_cost", "Datasheets_leader", "Abilities")
$verifiedTableNames = @($snapshotFiles | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.filename) })
foreach ($requiredTable in $requiredTables) {
    if ($requiredTable -notin $verifiedTableNames) { throw "Snapshot manifest is missing required relational table $requiredTable.csv." }
}
foreach ($file in $snapshotFiles) {
    $path = Join-Path $csvDirectory $file.filename
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Snapshot file is missing: $($file.filename)" }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($file.sha256) -or $actual -ne $file.sha256.ToLowerInvariant()) { throw "SHA-256 mismatch for $($file.filename)." }
}

$sources = Import-Csv -LiteralPath (Join-Path $csvDirectory "Source.csv") -Delimiter '|' -Encoding UTF8
$sourceById = @{}
foreach ($source in $sources) { $sourceById[[string]$source.id] = $source }
foreach ($bookId in $chapterBooks.Keys) {
    if (-not $sourceById.ContainsKey($bookId)) { throw "Chapter book $bookId is not in Source.csv." }
    if ([string]$sourceById[$bookId].edition -ne "11") { throw "Chapter book $bookId is not marked 11th edition." }
    if ([string]$sourceById[$bookId].name -ne [string]$chapterBooks[$bookId]) { throw "Chapter book $bookId does not match the expected source identity." }
}

$datasheets = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets.csv") -Delimiter '|' -Encoding UTF8
$chapterRows = @($datasheets | Where-Object { $chapterBooks.Contains([string]$_.source_id) })
$modelRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_models.csv") -Delimiter '|' -Encoding UTF8
$costRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_models_cost.csv") -Delimiter '|' -Encoding UTF8
$compositionRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_unit_composition.csv") -Delimiter '|' -Encoding UTF8
$weaponRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_wargear.csv") -Delimiter '|' -Encoding UTF8
$abilityRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_abilities.csv") -Delimiter '|' -Encoding UTF8
$keywordRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_keywords.csv") -Delimiter '|' -Encoding UTF8
$optionRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_options.csv") -Delimiter '|' -Encoding UTF8
$attachmentRows = Import-Csv -LiteralPath (Join-Path $csvDirectory "Datasheets_leader.csv") -Delimiter '|' -Encoding UTF8
$abilityDefinitions = Import-Csv -LiteralPath (Join-Path $csvDirectory "Abilities.csv") -Delimiter '|' -Encoding UTF8
$abilityNameById = @{}
foreach ($ability in $abilityDefinitions) { $abilityNameById[[string]$ability.id] = [string]$ability.name }
$sourceNameById = @{}
foreach ($sheet in $datasheets) { $sourceNameById[[string]$sheet.id] = [string]$sheet.name }
$profilesBySource = @{}
$profileText = Get-Content -LiteralPath $ProfilePath -Raw -Encoding UTF8
$profilePattern = '(?ms)^\t"(?<identity>[a-z0-9-]+)": \{\r?\n(?<body>.*?)(?=^\t"[a-z0-9-]+": \{|\r?\n\})'
foreach ($match in [regex]::Matches($profileText, $profilePattern)) {
    $body = $match.Groups['body'].Value
    $book = [regex]::Match($body, '"source_book_id":\s*"(\d+)"')
    $sheet = [regex]::Match($body, '"source_datasheet_id":\s*"(\d+)"')
    if (-not $book.Success -or -not $sheet.Success) { continue }
    $key = "$($book.Groups[1].Value)/$($sheet.Groups[1].Value)"
    if ($profilesBySource.ContainsKey($key)) { throw "Duplicate runtime profile source identity: $key" }
    $name = [regex]::Match($body, '"name":\s*"([^"]+)"')
    $profilesBySource[$key] = [pscustomobject]@{
        identity = $match.Groups['identity'].Value
        name = if ($name.Success) { $name.Groups[1].Value } else { $match.Groups['identity'].Value }
    }
}

# These two current-reference squad profiles are generated by a shared helper,
# so their source identity is expressed in the helper arguments/return data
# instead of a literal profile dictionary. Keep the gap audit aware of them.
$generatedProfileSources = @{
    "death-company-marines" = @{ book_id = "000000021"; sheet_id = "000001997"; name = "Death Company Marines" }
    "death-company-marines-with-jump-packs" = @{ book_id = "000000021"; sheet_id = "000002737"; name = "Death Company Marines With Jump Packs" }
}
foreach ($identity in $generatedProfileSources.Keys) {
    $source = $generatedProfileSources[$identity]
    $helperCall = [regex]::Escape('"' + $identity + '": _death_company_squad_profile(')
    if ($profileText -notmatch $helperCall) { continue }
    $key = "$($source.book_id)/$($source.sheet_id)"
    if ($profilesBySource.ContainsKey($key)) { throw "Duplicate runtime profile source identity: $key" }
    $profilesBySource[$key] = [pscustomobject]@{ identity = $identity; name = $source.name }
}

# Space Wolves Dreadnought profiles are emitted by one family helper. Keep the
# exact source identities visible to the chapter inventory auditor.
if ($profileText -match '(?m)^static func _space_wolves_walker_profiles\(') {
    $spaceWolvesWalkers = @(
        @{ identity = "bjorn-the-fell-handed"; sheet_id = "000000302"; name = "Bjorn the Fell-handed" },
        @{ identity = "murderfang"; sheet_id = "000000314"; name = "Murderfang" },
        @{ identity = "venerable-dreadnought"; sheet_id = "000002801"; name = "Venerable Dreadnought" },
        @{ identity = "wulfen-dreadnought"; sheet_id = "000004133"; name = "Wulfen Dreadnought" }
    )
    foreach ($source in $spaceWolvesWalkers) {
        $identityPattern = [regex]::Escape('"' + $source.identity + '"')
        if ($profileText -notmatch $identityPattern) { continue }
        $key = "000000036/$($source.sheet_id)"
        if ($profilesBySource.ContainsKey($key)) { throw "Duplicate runtime profile source identity: $key" }
        $profilesBySource[$key] = [pscustomobject]@{ identity = $source.identity; name = $source.name }
    }
}

# These six Black Templars vehicle records are generated by _chapter_vehicle_profiles()
# from their shared-book combat profiles. Their source identity lives in the
# chapter source map rather than in the shared profile dictionary above.
$chapterVehicleBlock = [regex]::Match($profileText, '(?ms)^const BLACK_TEMPLARS_VEHICLE_SOURCES := \{\r?\n(?<body>.*?)^\}')
if ($chapterVehicleBlock.Success) {
    $chapterVehiclePattern = '(?m)^\t"(?<identity>[a-z0-9-]+)": \{[^\r\n]*"name": "(?<name>[^"]+)"[^\r\n]*"datasheet_id": "(?<sheet>\d+)"'
    foreach ($match in [regex]::Matches($chapterVehicleBlock.Groups['body'].Value, $chapterVehiclePattern)) {
        $key = "000000162/$($match.Groups['sheet'].Value)"
        if ($profilesBySource.ContainsKey($key)) { throw "Duplicate runtime profile source identity: $key" }
        $profilesBySource[$key] = [pscustomobject]@{
            identity = $match.Groups['identity'].Value
            name = $match.Groups['name'].Value
        }
    }
}

$catalogByIdentity = @{}
$catalogText = Get-Content -LiteralPath $CatalogPath -Raw -Encoding UTF8
foreach ($line in ($catalogText -split "`r?`n")) {
    $entry = [regex]::Match($line, '^\t"(?<identity>[a-z0-9-]+)": \{(?<body>.*)$')
    if (-not $entry.Success) { continue }
    $status = [regex]::Match($entry.Groups['body'].Value, '"validation_status":\s*"([^"]+)"')
    if ($status.Success) { $catalogByIdentity[$entry.Groups['identity'].Value] = $status.Groups[1].Value }
}

if ([string]::IsNullOrWhiteSpace($retrievedUtc)) { throw "Snapshot manifest has no retrieval timestamp." }
$lines = [System.Collections.Generic.List[string]]::new()
$missingRecords = [System.Collections.Generic.List[object]]::new()
$lines.Add("# Space Marine Chapter-book profile gap audit")
$lines.Add("")
$lines.Add("Snapshot: ``$snapshotId``; retrieved: ``$retrievedUtc``; SHA-256 checks: ``$($snapshotFiles.Count)/$($snapshotFiles.Count)`` passed.")
$lines.Add($structureNote)
$lines.Add("Generated from the locally recorded Wahapedia export and runtime source identities. This gap report is derived data and must stay under ignored ``.tools/``.")
$lines.Add("")
$lines.Add("| Chapter book | Source ID | Sheets | Runtime profiles | Missing profiles |")
$lines.Add("|---|---:|---:|---:|---:|")
$missingTotal = 0
foreach ($bookId in $chapterBooks.Keys) {
    $rows = @($chapterRows | Where-Object { [string]$_.source_id -eq $bookId })
    $missing = @($rows | Where-Object { -not $profilesBySource.ContainsKey("$bookId/$($_.id)") } | Sort-Object name)
    $present = $rows.Count - $missing.Count
    $missingTotal += $missing.Count
    foreach ($row in $missing) {
        $missingRecords.Add([pscustomobject]@{ book = [string]$chapterBooks[$bookId]; source_id = $bookId; datasheet = $row })
    }
    $lines.Add("| $($chapterBooks[$bookId]) | ``$bookId`` | $($rows.Count) | $present | $($missing.Count) |")
    if ($missing.Count -gt 0) {
        $lines.Add("")
        $lines.Add("## $($chapterBooks[$bookId]) — missing runtime profiles ($($missing.Count))")
        $lines.Add("")
        foreach ($row in $missing) { $lines.Add("- ``$($row.id)`` — $($row.name)") }
    }
}
$lines.Add("")
$lines.Add("## Source matrix for missing runtime profiles")
$lines.Add("")
$lines.Add("This queue is derived only from the verified local export. It describes source facts and attachment dependencies; it does not admit or certify a profile.")
foreach ($record in $missingRecords) {
    $sheetId = [string]$record.datasheet.id
    $modelSummary = @($modelRows | Where-Object { [string]$_.datasheet_id -eq $sheetId } | Sort-Object { [int]$_.line } | ForEach-Object {
        "$(Format-SourceText $_.name): M$(Format-SourceText $_.M), T$(Format-SourceText $_.T), Sv$(Format-SourceText $_.Sv), W$(Format-SourceText $_.W), Ld$(Format-SourceText $_.Ld), OC$(Format-SourceText $_.OC), base $(Format-SourceText $_.base_size)"
    })
    $compositionSummary = @($compositionRows | Where-Object { [string]$_.datasheet_id -eq $sheetId } | Sort-Object { [int]$_.line } | ForEach-Object { Format-SourceText $_.description })
    $costSummary = @($costRows | Where-Object { [string]$_.datasheet_id -eq $sheetId } | Sort-Object { [int]$_.line } | ForEach-Object {
        $description = Format-SourceText $_.description
        if (-not [string]::IsNullOrWhiteSpace([string]$_.cost)) { "$($description): $($_.cost) points" } else { $description }
    })
    $weaponSummary = @($weaponRows | Where-Object { [string]$_.datasheet_id -eq $sheetId } | Sort-Object { [int]$_.line } | ForEach-Object {
        $name = Format-SourceText $_.name
        $description = Format-SourceText $_.description
        $entry = "$name ($($_.type), range $($_.range), A $($_.A), BS/WS $($_.BS_WS), S $($_.S), AP $($_.AP), D $($_.D))"
        if ($description -ne "—") { $entry += ": $description" }
        $entry
    })
    $abilitySummary = @($abilityRows | Where-Object { [string]$_.datasheet_id -eq $sheetId } | Sort-Object { [int]$_.line } | ForEach-Object {
        $name = if (-not [string]::IsNullOrWhiteSpace([string]$_.name)) { Format-SourceText $_.name } elseif ($abilityNameById.ContainsKey([string]$_.ability_id)) { Format-SourceText $abilityNameById[[string]$_.ability_id] } else { "ID $($_.ability_id)" }
        "$($_.type): $name"
    })
    $keywordSummary = @($keywordRows | Where-Object { [string]$_.datasheet_id -eq $sheetId } | ForEach-Object {
        $name = Format-SourceText $_.keyword
        if (-not [string]::IsNullOrWhiteSpace([string]$_.model)) { "$name ($($_.model))" } else { $name }
    })
    $optionSummary = @($optionRows | Where-Object { [string]$_.datasheet_id -eq $sheetId } | Sort-Object { [int]$_.line } | ForEach-Object { Format-SourceText $_.description })
    $attachmentSummary = @($attachmentRows | Where-Object { [string]$_.leader_id -eq $sheetId -or [string]$_.attached_id -eq $sheetId } | ForEach-Object {
        if ([string]$_.leader_id -eq $sheetId) { "can attach to $(Format-SourceText $sourceNameById[[string]$_.attached_id]) [$(Format-SourceText $_.attached_id)]" }
        else { "can be attached to $(Format-SourceText $sourceNameById[[string]$_.leader_id]) [$(Format-SourceText $_.leader_id)]" }
    })
    $lines.Add("### $($record.book) — ``$sheetId`` $($record.datasheet.name)")
    $lines.Add("")
    $lines.Add("- Source role: $(Format-SourceText $record.datasheet.role); support record: $(Format-SourceText $record.datasheet.is_support).")
    $lines.Add("- Composition: $(@($compositionSummary) -join '; '); models: $(@($modelSummary) -join '; ').")
    $lines.Add("- Costs: $(@($costSummary) -join '; ').")
    $lines.Add("- Weapons: $(@($weaponSummary) -join '; ').")
    $lines.Add("- Abilities: $(@($abilitySummary) -join '; ').")
    $lines.Add("- Keywords: $(@($keywordSummary) -join '; ').")
    $lines.Add("- Options: $(@($optionSummary) -join '; ').")
    $lines.Add("- Attachment links: $(@($attachmentSummary) -join '; ').")
    $lines.Add("")
}
$profileRows = @($chapterRows | Where-Object { $profilesBySource.ContainsKey("$($_.source_id)/$($_.id)") } | Sort-Object source_id,name)
$lines.Add("")
$lines.Add("## Runtime profile records")
$lines.Add("")
$lines.Add("| Chapter book | Datasheet ID | Runtime identity | Catalog validation status |")
$lines.Add("|---|---:|---|---|")
foreach ($row in $profileRows) {
    $profile = $profilesBySource["$($row.source_id)/$($row.id)"]
    $status = if ($catalogByIdentity.ContainsKey($profile.identity)) { $catalogByIdentity[$profile.identity] } else { "not present in the construction catalog" }
    $lines.Add("| $($sourceById[[string]$row.source_id].name) | ``$($row.id)`` | ``$($profile.identity)`` | ``$status`` |")
}
$lines.Add("")
$lines.Add("Total: $($chapterRows.Count) source sheets; $($chapterRows.Count - $missingTotal) runtime profiles; $missingTotal missing.")
$lines.Add("")
$lines.Add("Runtime profiles are matched only by source book ID and datasheet ID. This audit does not implement rules, admit profiles, certify abilities, or validate army legality.")

if ([string]::IsNullOrWhiteSpace($OutputPath)) { $OutputPath = Join-Path '.tools' "space-marine-chapter-gap-audit-$snapshotId.md" }
$outputDirectory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) { New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null }
$newline = [System.Environment]::NewLine
[System.IO.File]::WriteAllText($OutputPath, (($lines -join $newline) + $newline), [System.Text.UTF8Encoding]::new($false))

[pscustomobject]@{
    snapshot_id = $snapshotId
    retrieved_at_utc = $retrievedUtc
    verified_files = $snapshotFiles.Count
    chapter_sheets = $chapterRows.Count
    runtime_profiles = $chapterRows.Count - $missingTotal
    missing_profiles = $missingTotal
    report = $OutputPath
} | ConvertTo-Json -Compress
