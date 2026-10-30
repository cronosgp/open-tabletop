# Tarantula Air Defence Battery

## Current verdict

The Tarantula Air Defence Battery now has a fixed 11e profile in the local Space Marines catalog. Its source data is checked against the verified Wahapedia export, its supported battle abilities use the shared runtime rules, and its composition, points and copy limits pass local roster admission. It is explicitly tagged **Warhammer Legends**.

Games Workshop's current Space Marines guidance allows Legends rules at home, in stores, clubs and campaigns. Competitive event use requires the event organiser's permission. The catalog displays this condition with the unit. This is not approval for a particular event or a certification of a whole army. See [Big Space Marines News](https://www.warhammer-community.com/en-gb/articles/bbnskauh/big-space-marines-news/).

One configuration is supported: one model for 70 points. It has no optional wargear. The unit is immobile (the source Movement characteristic is `-`). The Incursion core profile permits up to two copies of this non-Battleline datasheet; Strike Force permits up to three.

The verified source says `Use model` and gives no footprint measurement. The tabletop simulation currently uses a 60 mm circular proxy. Exact clearance and other physical-footprint measurements are therefore outside this profile's certification; use the actual miniature footprint for a physical game.

## Datasheet scope

| Source field | Runtime value |
|---|---|
| Composition and cost | 1 Tarantula Air Defence Battery model; 70 points |
| Characteristics | M `-`; T 5; Sv 3+; W 4; Ld 7+; OC 0; no invulnerable save |
| Default wargear | 1 Armoured Hull; 1 Tarantula Air Defence Missiles |
| Ranged | Tarantula Air Defence Missiles: 48", A 3, BS 4+, S 7, AP -1, D 1, Blast 2, Anti-Fly 2+ |
| Melee | Armoured Hull: A 1, WS 4+, S 4, AP 0, D 1 |
| Keywords | ADEPTUS ASTARTES, FRAME, VEHICLE, IMPERIUM |
| Abilities | Combat Doctrines; Deadly Demise 1; Sentry Programming |

Sentry Programming is implemented through the normal Fire Overwatch reaction. The Tarantula can make its own one-per-phase Overwatch use even after another friendly unit used that Stratagem; its use costs 0 CP and leaves the normal use available to another unit. A prior normal or Firestrike use likewise does not block the Tarantula. The Tarantula cannot use it twice in the same phase. Its missile weapon continues through the normal equipment and attack-plan paths, including Blast 2 and Anti-Fly 2+. Deadly Demise 1 uses the shared destruction, mortal-wound allocation and prevention path.

## Source record

- Current sheet: [Wahapedia 11e — Tarantula Air Defence Battery](https://wahapedia.ru/wh40k11ed/factions/space-marines/Tarantula-Air-Defence-Battery)
- Source book: Space Marines (Warhammer Legends), book `000000356`, datasheet `000000099`, edition 11.
- Verified export: `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`; snapshot identity encodes retrieval time `2026-10-30T01:32:29Z`; source revision `2026-10-28T23:48:19+03:00`.
- Parent export manifest SHA-256: `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`.
- Legends slice manifest SHA-256: `d0164c9bf5035b95d88f0a3a1c297bc88dbaf5b565f2a1ba195928be3d3ceb5c`.
- The local derived 28-sheet `catalog.json` has SHA-256 `74e7fbdd029d7c30ad0259c8e4bed278553fd187cf057755fb4aaaaa6ddc28d1`; it remains ignored with the raw export.
- The local ignored snapshot's `manifest.json` records the 22 source filenames and their SHA-256 values; the checked raw files are in `.tools/marine-full-space-readiness-20261030/space-marines-legends-faction-28/raw/`. Raw and derived third-party data are not committed or distributed.
- The repeatable 28-sheet source audit is `.tools/marine-full-space-readiness-20261030/tarantula-source-slice-audit.json`, SHA-256 `7cf7f365e643b8475ed648f281989c4b9d0ef97f176e8eecc2fdfd211c20138d`. It confirms the slice's source rows; by design it reports no runtime admission or playability certification.

## Local verification and limits

The focused test checks source identity and provenance, all fixed profile and weapon facts, construction size and prices, Incursion/Strike Force copy limits, catalog and saved-roster labels, Sentry Programming in both Overwatch-use orders, Firestrike interaction, missile resolution through AttackPlan, and Deadly Demise allocation. The verification command passed **6/6 processes** (import, Python, Tarantula, catalog UI, Firestrike and Core reactions) at `.tools/verification/20261030T043853086740Z/results.json`, SHA-256 `98e0f3301e7e5db4b17c78fca7b8d1540ceeeeb481e9b5eb4ec7596872d4d074b`. It ran offline; the verifier staged its legacy starter fixture and reported no headless cleanup diagnostics.

A follow-up corrected the roster's singular display (`1 model`) and verified both singular and plural counts. The same focused batch passed **6/6 processes** at `.tools/verification/20261030T044853649302Z/results.json`, SHA-256 `5761064DF2A9E631D8C22D416D7427A0EF70BF0DB0C6B7E32767051CCC014207`. A live Godot 4.7.2 run was inspected at 1280×800; `.tools/tarantula-builder-added.png` shows the draft row with its Legends label, one model and 70 points. The generic preview cylinder remains a placeholder, not a Tarantula miniature.

This closes only the Tarantula Air Defence Battery's bounded local datasheet and reaction scope. Its simulation footprint remains a proxy, and this result does not certify every army combination, every interaction with other rules, event acceptance, network play, a complete match or human playtesting. The other 23 Space Marines Legends sheets, Kill Team Cassius and two unresolved-edition Forge World sheets remain separate work; see the [extended inventory](data/space-marine-extended-inventory.md).
