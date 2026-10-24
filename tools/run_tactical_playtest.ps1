[CmdletBinding()]
param(
    [string]$Godot = ""
)

$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($Godot)) {
    $Godot = Join-Path $root ".tools/godot/Godot_v4.7.2-stable_win64.exe"
}
$godotPath = $null
$godotError = ""
try {
    $godotPath = (Resolve-Path -LiteralPath $Godot -ErrorAction Stop).Path
}
catch {
    $godotError = $_.Exception.Message
}
$stamp = Get-Date -Format "yyyyMMdd-HHmmssfff"
$profile = Join-Path $root (".tools/playtest-" + $stamp)
New-Item -ItemType Directory -Path $profile | Out-Null

$revision = (& git -C $root rev-parse --short HEAD 2>$null)
if ([string]::IsNullOrWhiteSpace($revision)) { $revision = "unavailable" }
$workingTree = (& git -C $root status --porcelain 2>$null)
$treeStatus = if ([string]::IsNullOrWhiteSpace(($workingTree -join "`n"))) { "clean" } else { "modified or untracked" }
$godotLabel = if ($null -ne $godotPath) { $godotPath } else { "$Godot (not found)" }

$record = Join-Path $profile "tactical-training-session.md"
@"
# Tactical training session

Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
Godot: $godotLabel
Project: $root
Code revision: $revision
Working tree: $treeStatus
Scenario: marine-tactical-training-v1
Mode: shared computer, two participants alternating control
Window size and UI scale: record the actual values used
Participant experience and side assignment: record without personal identifiers

Use the checklist in docs/verification/tactical-training-playtest.md and record observations here.

After closing the session, validate the record with:
python tools/validate_tactical_playtest.py PATH_TO_THIS_RECORD

## Gate checks

Mark each item only after observing it in the actual Godot session. Use pass, partial, blocked or not observed, with a short note.

| Gate | Outcome | Notes |
|---|---|---|
| Both forces, model counts and points understood | | |
| Warlord and Leader attachments completed | | |
| Deployment and next-unit ownership understood | | |
| At least one legal ability or stratagem discovered | | |
| Experiment progress checklist understood | | |
| Plasma choice and Hazardous consequence understood | | |
| Bladeguard stance understood when offered | | |
| Pending decision ownership and phase lock understood | | |
| Save/resume preserves the intended decision | | |
| Five-round result reached without technical intervention | | |
| Opening guide and required controls readable without clipping | | |
| Optional roll kept without CP and paid reroll cost understood | | |
| Defender chose a legal recipient and understood restrictions | | |
| Invalid movement explained locally and corrected | | |
| Attack dice damage and destroyed models explained | | |
| Combat pacing symbols and reduced-motion controls understood | | |

| Observation | Result |
|---|---|
| Starting the match | |
| Setup and deployment | |
| Abilities and stratagems | |
| End-of-Turn coherency | |
| Turn flow | |
| Ownership and feedback | |
| Accessibility | |
| Save/resume | |
| Match completion | |

## Defects and assistance

Record severity, frequency, reproduction steps, assistance and recovery.

For the experience correction, observe a new training session: identify the current instruction; keep a roll for 0 CP and use a legal paid reroll; choose a non-default eligible defender model where possible; correct an invalid move using its local reason; explain the dice stages, damage and casualties. Compare Normal, Fast, Skip and Reduced motion without bypassing decisions. Record symbol recognition, sound comfort, hesitation and any help given. Mark absent legal opportunities as not observed; do not manufacture them with test dice or state edits.
"@ | Set-Content -LiteralPath $record -Encoding utf8

Write-Host "Tactical training playtest"
Write-Host "Use two participants on the same computer and select Start tactical training."
Write-Host "The isolated user profile and blank record are here: $profile"
Write-Host "Session record: $record"
Write-Host "After closing the game, validate with: python tools/validate_tactical_playtest.py `"$record`""
Write-Host "No telemetry, network connection or third-party download is used by this launcher."

if ($null -eq $godotPath) {
    Write-Host "ERROR: Godot executable was not found at '$Godot'. The blank record was created; install or provide Godot 4.7.2, then rerun this launcher. Details: $godotError" -ForegroundColor Red
    exit 2
}

$previousAppData = $env:APPDATA
$previousXdg = $env:XDG_DATA_HOME
$exitCode = 1
try {
    $env:APPDATA = $profile
    $env:XDG_DATA_HOME = $profile
    & $godotPath --path $root
    $exitCode = $LASTEXITCODE
}
finally {
    $env:APPDATA = $previousAppData
    $env:XDG_DATA_HOME = $previousXdg
}
exit $exitCode
