# Njal Stormcaller — source-bounded local scope

**Status:** source-bounded local validation passed, 29 October 2026. This records local behavior against the verified Wahapedia 11th-edition Space Wolves App export; network page comparison is deferred to final integration.

## Source identity

- Wahapedia Space Wolves App, source `000000036`, datasheet `000000292`, Standard Warhammer 40,000 mode.
- Source export updated `2026-10-28T23:48:19+03:00`; verified local snapshot `20261029T003124Z`.
- Parent snapshot manifest SHA-256: `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`.
- Njal slice manifest SHA-256: `F41AEB60436222F786E32DEE7E4D472E5C5DED5A01C8A33F02A98EBAA86BB113`; slice catalog SHA-256: `72d626f00660cf4ba0b5be7e8840d488b39abc9473b32f2baece08209105b7ef`.
- The parent export has 68 unrelated validation findings; Njal's subject-scoped slice has zero findings and is structurally valid. Raw exports remain ignored under `.tools/`.

## Integrated datasheet

Njal is one 100-point model on a 40 mm base: M7, T5, Sv3+, 4++, W4, Ld6+, OC1. The source keywords are ADEPTUS ASTARTES, CHARACTER, EPIC HERO, IMPERIUM, INFANTRY, PSYKER, SPACE WOLVES and TACTICUS. The local construction catalog enforces the one-copy Epic Hero limit, and Njal is available as a Warlord.

The weapons are Bolt Pistol; Living Lightning with Focused Witchfire (24", D6+6, BS3+, S7, AP-2, D1, Psychic, Hazardous, Sustained Hits 2) and Witchfire (24", D3+3, BS3+, S7, AP-1, D1, Psychic, Sustained Hits 2); and Staff of the Stormcaller (A4, WS3+, S7, AP-1, D2, Psychic, Sustained Hits 2).

Leader lists six source targets: Bladeguard Veteran Squad, Assault Intercessor Squad, Intercessor Squad, Blood Claws, Grey Hunters and Wolf Guard Headtakers. All six targets have current catalog profiles. Headtakers is a partial profile selectable at its mixed 6/12-model sizes; its standalone MFM rows remain blocked by Wahapedia's selected minimum composition.

## Datasheet abilities

- **Wind Walker:** Njal's unit has Assault on ranged attacks and can change its Advance roll to 6.
- **High Rune Priest:** the source marks Njal Psyker Level 3 and references the listed Runic Abilities.
- **Murderous Hurricane:** in the Movement phase, if Njal's unit is not Battle-shocked, make a psychic roll. On a 1, the unit becomes Battle-shocked; then select a visible enemy within 12" that cannot make Snap Shooting attacks. The local export does not state the duration of that restriction; the implementation keeps the target barred for the remainder of the battle as an explicit interpretation.
- **Storm Caller:** when an enemy unit targets Njal's unit, if it is not Battle-shocked, make a psychic roll. On a 1, the unit becomes Battle-shocked; its detection range is reduced by 3" until the end of the phase.
- **Tempest's Wrath:** in the Shooting phase, if Njal's unit is not Battle-shocked, make a psychic roll. On a 1, the unit becomes Battle-shocked; a visible enemy within 18" is Suppressed until the start of Njal's next turn and suffers -1 to Hit.
- **Psyker Level 3 interpretation:** the local rules model up to three level-1 ability uses per game turn, shared across active and reactive powers. This is recorded as an implementation interpretation.

The source slice also lists Combat Doctrines. All source Leader endpoints are recorded, and Njal is selectable with the two admitted mixed Headtakers formations. The MFM Headtakers-only rows remain blocked by the selected Wahapedia composition; see the [Headtakers audit](marine-wolf-guard-headtakers.md) for the point tiers and remaining limits.

## Local verification and limits

The focused regression passed 3/3 processes. The connected offline regression passed 12/12 processes, covering Njal, current catalog admission, capabilities, Leader links, reserves, Combat Doctrines, roster validation, Ezekiel and shared combat/ability paths. Exact commands, report hashes, source hashes and limits are in the [machine-readable source/hash audit](marine-njal-stormcaller-audit.json). The connected run staged the legacy starter for compatibility; network validation was disabled in both runs.

This scope does not certify all Space Wolves army restrictions, full army legality, network/page comparison, human playtesting or complete-match behavior. The source slice's zero findings do not resolve the 68 unrelated parent-export findings. See the [Space Marine Chapter coverage](space-marines-coverage.md) and [support matrix](project/support-matrix.md) for remaining work.
