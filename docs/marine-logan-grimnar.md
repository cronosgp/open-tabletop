# Logan Grimnar — source-bounded local scope

**Status:** source-bounded local validation passed, 29 October 2026. This records local behavior against the verified Wahapedia 11th-edition Space Wolves App export; network page comparison is deferred to final integration.

## Source identity

- Wahapedia Space Wolves App, source `000000036`, datasheet `000000282`, Standard Warhammer 40,000 mode.
- Source export updated `2026-10-28T23:48:19+03:00`; verified local snapshot `20261029T003124Z`.
- Parent snapshot manifest SHA-256: `457067e2a3aa94f341e020792d56dfae4a36fe30272d0daf7eeb1de6ed2dab9d`.
- Logan slice manifest SHA-256: `6db0cd7f582c0a87ec57ab91c02c8a5cf88a2e5b102224f26f9f1b3c5fd12e92`; slice catalog SHA-256: `211d2720b0103b7ac5fe98e128606bd14b65813374419162439db0b9f845765b`.
- The parent export has 68 unrelated validation findings; Logan's subject-scoped slice has zero findings and is structurally valid. Raw exports remain ignored under `.tools/`.

## Integrated datasheet

Logan is one 150-point model on an 80 mm base: M6, T6, Sv2+, 4++, W8, Ld6+, OC1. The source keywords are ADEPTUS ASTARTES, SPACE WOLVES, INFANTRY, TERMINATOR, CHAPTER MASTER, CHARACTER, IMPERIUM and EPIC HERO. The local construction catalog enforces the one-copy Epic Hero limit.

The fixed weapons are Storm Bolter (24", A2, BS2+, S5, AP-1, D1, Rapid Fire 2), Axe Morkai Strike (A6, WS2+, S10, AP-2, D3), Axe Morkai Sweep (A10, WS2+, S6, AP-2, D1, Cleave 1) and Tyrnak and Fenrir (A6, WS2+, S5, AP-1, D1, Extra Attacks). Axe Morkai's Strike and Sweep modes share one physical weapon identity.

Leader, Deep Strike and Combat Doctrines are registered. All three source-listed Leader targets are connected: Terminator Squad (`000001183`), Terminator Assault Squad (`000000118`) and Wolf Guard Terminators (`000000318`).

## Datasheet abilities

- **High King of Fenris:** in Logan's Movement phase, the player may select up to one friendly SPACE WOLVES unit in Strategic Reserves per battle round. That selection stays with the reserve unit until it makes an ingress move. On ingress, the engine treats the battle round as one higher for the early-ingress gate and, for a unit without Deep Strike, the opponent deployment-zone restriction. The selection is available to a later Rapid Ingress in the opponent's Movement phase.
- **Guile of the Wolf:** Assault, Devastator and Tactical Doctrines are all active for Logan's unit. Other Space Wolves units do not receive this ability from Logan.

## Local verification and limits

The focused and connected offline results, exact commands and hashes are recorded in the [machine-readable source/hash audit](marine-logan-grimnar-audit.json). The dedicated regression checks the source profile, construction/copy limit, weapon modes, Leader relations, unit-only doctrine scope, once-per-round reserve choice, first-round ingress, Rapid Ingress timing, the treated-round deployment-zone boundary and selection consumption on ingress.

This scope does not certify all Space Wolves army restrictions, full army legality, network/page comparison, human playtesting or complete-match behavior. The source slice's zero findings do not resolve the 68 unrelated parent-export findings. See the [Space Marine Chapter coverage](space-marines-coverage.md) and [support matrix](project/support-matrix.md) for remaining work.
