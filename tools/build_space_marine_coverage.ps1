$ErrorActionPreference = "Stop"

$profilePath = "scripts\edition_11\current_reference_marine_profiles.gd"
$transportPath = "data\edition_11\space_marines_transport_profiles.json"
$sliceAuditPath = "docs\wahapedia-marines-slice-audit.json"
$identityAuditPath = "docs\space-marines-source-identity-map.json"
$profileEvidencePath = "docs\space-marines-profile-evidence.json"
$snapshotPath = ".tools\wahapedia-e11"
$outputPath = "docs\space-marines-coverage.csv"
$bookId = "000000139"
$factionId = "SM"

function Normalize-SourceName([string]$Name) {
    return $Name.Replace([char]0x2018, "'").Replace([char]0x2019, "'").Trim()
}

$profileSource = Get-Content -Encoding UTF8 $profilePath -Raw
$profilePattern = '(?ms)^\t"(?<identity>[a-z0-9-]+)": \{\r?\n(?<body>.*?)(?=^\t"[a-z0-9-]+": \{|\r?\n\})'
$profiles = @()
foreach ($match in [regex]::Matches($profileSource, $profilePattern)) {
    $body = $match.Groups["body"].Value
    $nameMatch = [regex]::Match($body, '"name":\s*"([^"]+)"')
    $bookMatch = [regex]::Match($body, '"source_book_id":\s*"(\d+)"')
    $idMatch = [regex]::Match($body, '"source_datasheet_id":\s*"(\d+)"')
    $revisionMatch = [regex]::Match($body, '"source_export_updated_at":\s*"([^"]+)"')
    if (-not $nameMatch.Success) {
        throw "Missing display name for runtime profile $($match.Groups['identity'].Value)."
    }
    $profiles += [pscustomobject]@{
        identity = $match.Groups["identity"].Value
        name = $nameMatch.Groups[1].Value
        source_book_id = if ($bookMatch.Success) { $bookMatch.Groups[1].Value } else { "" }
        source_datasheet_id = if ($idMatch.Success) { $idMatch.Groups[1].Value } else { "" }
        runtime_profile_source_export_updated_at = if ($revisionMatch.Success) { $revisionMatch.Groups[1].Value } else { "" }
        source_name = ""
        identity_match_method = ""
        source_export_updated_at = ""
    }
}

$transportDocument = Get-Content -Encoding UTF8 $transportPath -Raw | ConvertFrom-Json
foreach ($property in $transportDocument.profiles.PSObject.Properties) {
    $profile = $property.Value
    $profiles += [pscustomobject]@{
        identity = $property.Name
        name = $profile.name
        source_book_id = $profile.source_book_id
        source_datasheet_id = $profile.source_datasheet_id
        runtime_profile_source_export_updated_at = $profile.source_export_updated_at
        source_name = ""
        identity_match_method = ""
        source_export_updated_at = ""
    }
}

$sliceAudit = Get-Content -Encoding UTF8 $sliceAuditPath -Raw | ConvertFrom-Json
if ($profiles.Count -ne $sliceAudit.subject_count) {
    throw "Runtime profile count $($profiles.Count) differs from audited source subjects $($sliceAudit.subject_count)."
}
if (($profiles | Where-Object {
    ($_.source_book_id -and $_.source_book_id -ne $sliceAudit.source_book.id) -or
    ($_.runtime_profile_source_export_updated_at -and $_.runtime_profile_source_export_updated_at -ne $sliceAudit.export_updated_at)
}).Count -gt 0) {
    throw "A runtime profile does not match its historical source-book metadata."
}
if (($profiles.source_datasheet_id | Where-Object { $_ } | Sort-Object -Unique).Count -ne ($profiles | Where-Object { $_.source_datasheet_id }).Count) {
    throw "Runtime profile source datasheet IDs are not unique."
}

$snapshotManifestPath = Join-Path $snapshotPath "snapshot-manifest.json"
$datasheetsPath = Join-Path $snapshotPath "Datasheets.csv"
$identityAudit = $null
if (Test-Path $datasheetsPath) {
    if (-not (Test-Path $snapshotManifestPath)) {
        throw "The local Wahapedia export has no snapshot manifest."
    }
    $manifest = Get-Content -Encoding UTF8 $snapshotManifestPath -Raw | ConvertFrom-Json
    if ($manifest.raw_file_count -ne $manifest.files.Count) {
        throw "The snapshot manifest file count is inconsistent."
    }
    foreach ($file in $manifest.files) {
        $path = Join-Path $snapshotPath $file.name
        if (-not (Test-Path $path)) {
            throw "Snapshot file is missing: $($file.name)"
        }
        $actual = Get-FileHash $path -Algorithm SHA256
        if ($actual.Hash -ne $file.sha256) {
            throw "Snapshot hash mismatch: $($file.name)"
        }
    }

    $timestampBefore = (Import-Csv -Delimiter "|" (Join-Path $snapshotPath "Last_update_before.csv")).last_update.Trim()
    $timestampAfter = (Import-Csv -Delimiter "|" (Join-Path $snapshotPath "Last_update_after.csv")).last_update.Trim()
    $timestampCurrent = (Import-Csv -Delimiter "|" (Join-Path $snapshotPath "Last_update.csv")).last_update.Trim()
    $manifestTimestamp = $manifest.last_update_marker.Trim().TrimEnd("|")
    if (-not $timestampBefore -or $timestampBefore -ne $timestampAfter -or $timestampBefore -ne $timestampCurrent -or $timestampBefore -ne $manifestTimestamp) {
        throw "The Wahapedia export timestamp changed during download or differs from its manifest."
    }

    $datasheetsFile = $manifest.files | Where-Object { $_.name -eq "Datasheets.csv" }
    if (-not $datasheetsFile) {
        throw "The snapshot manifest does not record Datasheets.csv."
    }
    $sourceRows = @(Import-Csv -Delimiter "|" $datasheetsPath | Where-Object { $_.faction_id -eq $factionId -and $_.source_id -eq $bookId })
    if ($sourceRows.Count -ne $sliceAudit.subject_count) {
        throw "The local source inventory has $($sourceRows.Count) rows; expected $($sliceAudit.subject_count)."
    }
    if (($sourceRows.id | Sort-Object -Unique).Count -ne $sourceRows.Count) {
        throw "The local source inventory contains duplicate datasheet IDs."
    }
    if (($sourceRows.name | Sort-Object -Unique).Count -ne $sourceRows.Count) {
        throw "The local source inventory contains duplicate datasheet names."
    }

    $mappings = @()
    foreach ($profile in $profiles) {
        $matches = @($sourceRows | Where-Object { $_.name -eq $profile.name })
        $method = "case-insensitive-exact-name"
        if ($matches.Count -eq 0) {
            $normalizedName = Normalize-SourceName $profile.name
            $matches = @($sourceRows | Where-Object { (Normalize-SourceName $_.name) -eq $normalizedName })
            $method = "apostrophe-normalized-name"
        }
        if ($matches.Count -ne 1) {
            throw "Runtime profile $($profile.identity) maps to $($matches.Count) source datasheets by the permitted name comparison."
        }
        $source = $matches[0]
        if ($profile.source_datasheet_id -and $profile.source_datasheet_id -ne $source.id) {
            throw "Runtime profile $($profile.identity) source ID does not match the local export."
        }
        if ($profile.source_book_id -and $profile.source_book_id -ne $source.source_id) {
            throw "Runtime profile $($profile.identity) source book does not match the local export."
        }
        $profile.source_book_id = $source.source_id
        $profile.source_datasheet_id = $source.id
        $profile.source_name = $source.name
        $profile.identity_match_method = $method
        $profile.source_export_updated_at = $timestampCurrent
        $mappings += [pscustomobject]@{
            identity = $profile.identity
            runtime_name = $profile.name
            source_name = $source.name
            source_datasheet_id = $source.id
            identity_match_method = $method
        }
    }
    if (($mappings.source_datasheet_id | Sort-Object -Unique).Count -ne $profiles.Count) {
        throw "Runtime profiles do not map one-to-one to source datasheets."
    }

    $identityAudit = [pscustomobject]@{
        schema_version = 1
        source = "Wahapedia"
        edition = "11th"
        source_root = "https://wahapedia.ru/wh40k11ed/"
        source_book_id = $bookId
        faction_id = $factionId
        source_export_updated_at = $timestampCurrent
        source_update_stable_before_after = $true
        source_update_marker_before = $timestampBefore
        source_update_marker_after = $timestampAfter
        observed_app_version = "2.8.1 / October 2026"
        source_subject_count = $sourceRows.Count
        runtime_profile_count = $profiles.Count
        identity_matches_case_insensitive_exact = @($mappings | Where-Object { $_.identity_match_method -eq "case-insensitive-exact-name" }).Count
        identity_matches_apostrophe_normalized = @($mappings | Where-Object { $_.identity_match_method -eq "apostrophe-normalized-name" }).Count
        datasheets_csv_sha256 = $datasheetsFile.sha256
        verified_snapshot_file_count = $manifest.files.Count
        runtime_existing_source_ids_verified = @($profiles | Where-Object { $_.runtime_profile_source_export_updated_at }).Count
        runtime_name_only_profiles_mapped = @($profiles | Where-Object { -not $_.runtime_profile_source_export_updated_at }).Count
        data_or_options_reconciled_by_this_map = 0
        snapshot_manifest_sha256 = (Get-FileHash $snapshotManifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
        verified_snapshot_files = @($manifest.files | ForEach-Object { [pscustomobject]@{ name = $_.name; bytes = $_.bytes; sha256 = $_.sha256 } })
        identity_mappings = $mappings
    }
    $identityAudit | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 $identityAuditPath
} elseif (Test-Path $identityAuditPath) {
    $identityAudit = Get-Content -Encoding UTF8 $identityAuditPath -Raw | ConvertFrom-Json
    if ($identityAudit.source_book_id -ne $bookId -or $identityAudit.faction_id -ne $factionId -or
        $identityAudit.source_subject_count -ne $profiles.Count -or $identityAudit.identity_mappings.Count -ne $profiles.Count) {
        throw "The committed source identity audit does not cover the current runtime profile set."
    }
    foreach ($profile in $profiles) {
        $matches = @($identityAudit.identity_mappings | Where-Object { $_.identity -eq $profile.identity })
        if ($matches.Count -ne 1 -or $matches[0].runtime_name -ne $profile.name) {
            throw "The committed identity audit does not match runtime profile $($profile.identity)."
        }
        if ($profile.source_datasheet_id -and $profile.source_datasheet_id -ne $matches[0].source_datasheet_id) {
            throw "Runtime profile $($profile.identity) conflicts with the committed source identity audit."
        }
        $profile.source_book_id = $bookId
        $profile.source_datasheet_id = $matches[0].source_datasheet_id
        $profile.source_name = $matches[0].source_name
        $profile.identity_match_method = $matches[0].identity_match_method
        $profile.source_export_updated_at = $identityAudit.source_export_updated_at
    }
} else {
    throw "Generate the source identity audit with .tools\wahapedia-e11 or provide the committed audit file."
}

$exactProfileIds = @($sliceAudit.six_fixed_profiles | ForEach-Object { $_.datasheet_id })
$tests = @(Get-ChildItem "tests" -Filter "test_*.gd" | ForEach-Object { $_.BaseName })
$profileEvidence = Get-Content -Encoding UTF8 $profileEvidencePath -Raw | ConvertFrom-Json
if ($profileEvidence.source.source_book_id -ne $bookId -or
    $profileEvidence.source.source_export_updated_at -ne $identityAudit.source_export_updated_at -or
    $profileEvidence.coverage_limits.profiles_with_bounded_source_data_evidence -ne @($profileEvidence.profiles.PSObject.Properties).Count) {
    throw "The profile evidence audit does not match the pinned Wahapedia export or its declared profile count."
}
$requiredEvidenceTests = @($profileEvidence.validation_run.profile_parity_test_files) +
    @($profileEvidence.validation_run.copy_cost_test.file, $profileEvidence.validation_run.source_field_test.file,
      $profileEvidence.validation_run.vanguard_test.file, $profileEvidence.validation_run.catalog_test.file)
foreach ($evidenceTest in $requiredEvidenceTests) {
    if (-not (Test-Path $evidenceTest)) {
        throw "Profile evidence test is missing: $evidenceTest"
    }
}
$profileEvidenceByIdentity = @{}
foreach ($property in $profileEvidence.profiles.PSObject.Properties) {
    $profileEvidenceByIdentity[$property.Name] = $property.Value
    foreach ($evidenceTest in @($property.Value.profile_parity_test)) {
        if ($evidenceTest -and -not (Test-Path $evidenceTest)) {
            throw "Profile evidence test is missing: $evidenceTest"
        }
    }
}
$rows = foreach ($profile in ($profiles | Sort-Object name)) {
    $profileDoc = "docs\marine-$($profile.identity).md"
    $testName = "test_$($profile.identity -replace '-', '_')"
    $testPath = "tests\$testName.gd"
    $evidence = $profileEvidenceByIdentity[$profile.identity]
    $evidenceTests = @()
    if ($evidence.profile_parity_test) { $evidenceTests += $evidence.profile_parity_test }
    if ($evidence.copy_cost_test) { $evidenceTests += $profileEvidence.validation_run.copy_cost_test.file }
    if ($evidence.source_field_test) { $evidenceTests += $profileEvidence.validation_run.source_field_test.file }
    $evidenceTests = @($evidenceTests | Sort-Object -Unique)
    $reconciliationState = "source-identity-only"
    if ($evidence.profile_parity_test) { $reconciliationState = "bounded-profile-data-compared" }
    elseif ($evidence.copy_cost_test) { $reconciliationState = "copy-costs-compared" }
    elseif ($evidence.source_field_test) { $reconciliationState = "selected-source-fields-compared" }
    [pscustomobject]@{
        source_book_id = $profile.source_book_id
        source_datasheet_id = $profile.source_datasheet_id
        identity = $profile.identity
        datasheet = $profile.name
        source_name = $profile.source_name
        source_export_updated_at = $profile.source_export_updated_at
        runtime_profile_source_export_updated_at = $profile.runtime_profile_source_export_updated_at
        source_identity_match = $profile.identity_match_method
        cataloged = "runtime-profile-record-present"
        source_reconciled = if ($profile.source_datasheet_id -in $exactProfileIds) { "historical-fixed-data-compared" } else { $reconciliationState }
        runtime_profile_metadata = if ($profile.runtime_profile_source_export_updated_at) { "runtime-source-export-stamp-present" } else { "runtime-source-export-stamp-absent" }
        implemented = "partial-profile-and-scoped-rules"
        locally_tested = if ($evidenceTests.Count -gt 0) { "bounded-source-data-checks-passed" } else { "no-bounded-source-data-check-in-current-audit" }
        test_file_present = (@(@($evidenceTests) + $(if ($testName -in $tests) { @($testPath) } else { @() })) | Sort-Object -Unique) -join "; "
        reconciliation_evidence = if ($evidence) { $evidenceTests -join "; " } else { "" }
        reconciliation_scope = if ($evidence) { $evidence.scope } else { "" }
        profile_note = if (Test-Path $profileDoc) { $profileDoc } else { "" }
        scope_validated = "no-complete-scope-validation"
    }
}

$rows | Export-Csv $outputPath -NoTypeInformation -Encoding UTF8
$boundedCount = @($rows | Where-Object { $_.locally_tested -eq "bounded-source-data-checks-passed" }).Count
$parityCount = $profileEvidence.coverage_limits.profile_parity_tests_passed
$copyCostCount = $profileEvidence.coverage_limits.copy_cost_profiles_tested
$fieldOnlyCount = $profileEvidence.coverage_limits.additional_source_field_only_profiles
Write-Output "Generated $outputPath with $($rows.Count) shared-book rows: $boundedCount profiles have bounded source-data tests ($parityCount profile parity, $copyCostCount copy-cost only, $fieldOnlyCount additional field-only); full datasheet scope validated: 0."
