# Marneus Calgar datasheet audit

## Source and snapshot

This audit covers Marneus Calgar in shared Space Marines book `000000139`, datasheet `000004246`, from the pinned Wahapedia 11th-edition export snapshot `20261021T130623Z` (specification revision `20260817b`). The snapshot was retrieved on 2026-10-21; its manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf` and the Space Marines slice manifest SHA-256 is `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`. The current [Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Marneus-Calgar) was checked on 2026-10-27. The twelve relevant export-file hashes are recorded in the machine audit.

## Source profile

The local export records a one-model 50 mm profile at 180 points with M6, T6, Sv2+, W6, Ld6+, OC1 and a 4+ invulnerable save. Fixed weapons: Gauntlets of Ultramar, Gauntlets of Ultramar, Gauntlets of Ultramar - Overhead Smash. There are no equipment-option rows.

Core abilities: Deep Strike, Leader. Army rules: Combat Doctrines, Transhuman Strategist. Datasheet abilities: Codex Adept, Master Tactician, Thunderhawk Insertion.

The export lists 14 Leader links: 13 common-book targets plus Vanguard Veteran Squad (`000001154`) from Warhammer Legends book `000000356`, which remains outside shared-book construction.

## Integrated local scope

Marneus Calgar: exact one-model 50 mm 180-point source profile, characteristics, keywords and absence of equipment-option rows; ranged Gauntlets of Ultramar, melee Gauntlets and Overhead Smash through Equipment and AttackPlan with Extra Attacks routing; both players' current Marine catalogs; all 13 common-book Leader targets and explicit exclusion of the Warhammer Legends Vanguard Veteran Squad; Codex Adept; Warlord selection and once-per-round Transhuman Strategist CP; Master Tactician's Movement-phase target, visibility, range, doctrine, use and duration boundaries; Thunderhawk Insertion's pre-battle target eligibility, Deep Strike effect and reserve flow; and Cato's conditional Support, attachment and Warlord interaction.

## Verification

Focused offline verification passed **7/7 processes**: import, Python checks, Cato Sicarius, Cato profile parity, Marneus Calgar, Victrix Honour Guard as a linked regression, and the 153-link Leader/Support relation suite. This evidence closes Marneus Calgar's declared local source-bounded scope. The Victrix suite is a dependency regression and does not close its separate sheet scope.

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_cato_sicarius --only test_cato_profile_parity --only test_marneus_calgar --only test_victrix_honour_guard --only test_space_marine_leader_links --timeout 300
```

Report: `.tools/verification/20261027T184013951006Z/results.json`; SHA-256 `fda6d470dc83ef6df9faa13f30c37ae748879ca91526b0b5faba66a546bfde01`. Network was disabled, the optional legacy starter was not staged and no cleanup diagnostics were reported. Provenance and boundaries are recorded in the [machine-readable audit](marine-marneus-calgar-audit.json) and [master profile evidence](space-marines-profile-evidence.json).

## Open boundaries

Closes only Marneus Calgar's shared-book local sheet scope. Its linked Victrix target now supports all source-legal compositions and Banner pricing; see the [Victrix audit](marine-victrix-honour-guard.md). Ultramarines/Chapter restrictions, full faction/army legality, network behavior, complete matches and human playtesting remain outside this result; network validation is deferred to final integration.
