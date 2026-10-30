# Centurion Assault Squad datasheet audit

## Current source identity

The current [Wahapedia 11th edition Centurion Assault Squad page](https://wahapedia.ru/wh40k11ed/factions/space-marines/Centurion-Assault-Squad) identifies the sheet as a Space Marines Warhammer Legends datasheet in book `000000356`, datasheet `000002703`. It was checked on 30 October 2026 against the verified local Wahapedia Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, revision `2026-10-28T23:48:19+03:00`, parent manifest SHA-256 `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`, and Space Marines Legends slice manifest SHA-256 `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`. The machine-readable audit records the retrieval time and hashes of the source tables. The source slice has zero scoped structural findings; its parent export retains 68 unrelated findings.

## Datasheet facts represented

- Composition is one Assault Centurion Sergeant and two to five Assault Centurions. Both roles use M4, T7, Sv2+, W4, Ld6+, OC2 and the exact source-listed 50 mm base.
- The priced configurations are three models for 150 points and six models for 300 points. Other sizes are unavailable in construction; the local copy ceiling is three units.
- Every model starts with Centurion Bolters, Siege Drills and a Twin Flamer. During preparation, each model can independently replace its Centurion Bolters with a Centurion Assault Launcher and/or replace its Twin Flamer with a Twin Meltagun.
- The local profiles match the listed weapon statistics and traits: Centurion Bolters (Rapid Fire 3, Twin-linked), Twin Flamer (Blast 1, Twin-linked, Torrent), Twin Meltagun (Melta 2, Twin-linked), and Siege Drills (Twin-linked).
- The launcher has no attack profile in the source. Its bearer gains EXPLOSIVES, which uses the existing Core Explosives action. Annihilator Protocols grants Sustained Hits 2 to melee attacks against MONSTER, VEHICLE or FORTIFICATION targets. Combat Doctrines and all source keywords are retained.

## Game use and limits

The sheet is labelled Warhammer Legends. Games Workshop guidance permits Legends units in home, store, club and campaign games; competitive event use needs the event organiser's permission. The Army Builder displays this condition. This verifies the sheet's current game-mode status, but the organiser decides acceptance at a specific event.

The local profile covers both priced sizes, the source role minimum, all per-model loadout choices, every listed weapon profile, the launcher keyword effect, Annihilator Protocols and local roster admission. It does not certify a complete Space Marines army, every cross-unit interaction, network play, a complete match or human playtesting. Network validation remains deferred to final integration under project policy.

## Verification

The focused checks cover source identity and provenance, characteristics/base/keywords, weapon data, both priced roster sizes, copy limits, all four combinations of per-model replacements, reversible preparation choices, the granted EXPLOSIVES keyword and Core Explosives action, and Annihilator Protocols against its eligible and ineligible target keywords. The local source-slice check and final verification record are linked in the [machine-readable audit](marine-centurion-assault-squad-audit.json) and [verification history](verification/verification-results.md).
