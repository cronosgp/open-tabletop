# Assault Intercessors With Jump Packs — source-bounded local scope

This audit closes the shared-book local scope for Assault Intercessors With Jump Packs, datasheet `000002776` in Space Marines App book `000000139`. Its rules reference is the current Wahapedia 11th-edition [datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Assault-Intercessors-With-Jump-Packs), checked 28 October 2026 UTC against the Space Marines App 2.8.1 / October 2026 reference. Datasheet facts were checked against the verified local export snapshot below; network validation was not part of the runtime test.

## Verified local data source

The full Wahapedia 11e export snapshot is `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; the specification revision is `20260817b`; the 23-file manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The datasheet row retains its earlier runtime source stamp, `2026-10-16T21:03:46+03:00`. Relevant filenames and SHA-256 hashes are recorded in the [machine-readable audit](marine-assault-intercessors-with-jump-packs-audit.json).

## Source profile and construction

The unit is one Assault Intercessor Sergeant with Jump Pack plus four to nine Assault Intercessors with Jump Pack. Five models cost 95 points and ten cost 190 for the first two units; the third-plus source tiers are 105 and 200. Models use 32 mm bases and share M12, T5, Sv3+, W2, Ld6+ and OC1. The seven keywords are `ADEPTUS ASTARTES`, `EXPLOSIVES`, `FLY`, `IMPERIUM`, `INFANTRY`, `JUMP PACK` and `TACTICUS`.

Construction admits the source-priced five- and ten-model sizes and rejects six models. The current roster admission limit is two copies because admission cannot yet apply the higher third-plus cost by copy index. The runtime profile and catalog retain both third-plus prices; a third copy remains explicitly blocked.

## Equipment and abilities

Every model starts with a Heavy Bolt Pistol and Chainsword. The Sergeant can replace the pistol with a Hand Flamer or Plasma Pistol, and the Chainsword with a Power Fist or Power Weapon. For every five models, one ordinary model can replace its Heavy Bolt Pistol with a Plasma Pistol. The public preparation flow exposes those choices, enforces the ordinary bearer cap at both unit sizes and can restore the original weapons.

All default and optional weapon modes pass through `Equipment` and `AttackPlan` checks:

| Weapon | Profile |
|---|---|
| Heavy Bolt Pistol | 18", A1, BS3+, S5, AP-1, D1; Close-quarters |
| Hand Flamer | 9", A3, Torrent, S4, AP0, D1; Close-quarters |
| Plasma Pistol — Standard | 12", A1, BS3+, S7, AP-2, D1; Close-quarters |
| Plasma Pistol — Supercharge | 12", A1, BS3+, S8, AP-3, D2; Close-quarters, Hazardous |
| Chainsword | Melee, A4, WS3+, S5, AP-1, D1 |
| Power Fist | Melee, A3, WS3+, S8, AP-2, D2 |
| Power Weapon | Melee, A4, WS3+, S5, AP-2, D1 |

The sheet grants Deep Strike and Hammer of Wrath. Deep Strike uses the shared reserve resolver; the Jump Pack Captain suite checks a source-linked attached Jump Pack unit through its public reserve choice. Hammer of Wrath's charge-end choice, engaged-model dice count, 4+ mortal wound, skip path, defender allocation and save/restore continuation pass in `test_hammer_of_wrath.gd`. That behavior suite uses the project's legacy training fixture; its separate run records `legacy_starter_staged: true` and no network access.

The shared-book Leader map contains Captain With Jump Pack, Chaplain With Jump Pack and Kayvaan Shrike. All three attachments are checked for both players and the paired 153-relation suite passes. Commander Dante is listed by the live page but belongs to the separate Blood Angels App and remains outside this 85-sheet common-book scope.

## Verification

The focused current-catalog verification passed **6/6 processes** at `.tools/verification/20261028T014923681819Z/results.json` (SHA-256 `9c1f697cbea55dbc578df376dee60fdecad7481977fb9304368b929e2d4f0faa`; `network: false`, `legacy_starter_staged: false`, no cleanup diagnostics). It covers the exact source profile, both player catalogs and model sizes, source copy-cost tiers, construction admission, every weapon option through public commands and AttackPlan, ordinary Plasma Pistol caps and the three common-book Leader links. A broader copy-cost/Chaplain regression passed **8/8 processes** at `.tools/verification/20261028T014453977946Z/results.json` (SHA-256 `0a2e3b132b02ee9d6033f0bacd401b795a6b4a4532fb900e0422f6193e949edb`; `network: false`, `legacy_starter_staged: true` because its supplemental copy-cost and Chaplain suites use the local historical starter). Hammer of Wrath behavior separately passed **3/3 processes** at `.tools/verification/20261028T014532504875Z/results.json` (SHA-256 `20bcec476b1f747895e86c94288ef52f5f6ece19411418b02c296ba2943efcb3`); that behavior suite also uses a legacy training fixture and records `legacy_starter_staged: true`. The test dependency and exact boundaries are listed in the machine audit.

The separate Hammer of Wrath behavior run passed **3/3 processes** at `.tools/verification/20261028T014532504875Z/results.json` (SHA-256 `20bcec476b1f747895e86c94288ef52f5f6ece19411418b02c296ba2943efcb3`; `network: false`, `legacy_starter_staged: true`). Both commands and scope boundaries are preserved in the machine audit.

This closes only this datasheet's declared shared-book local scope. The two-copy admission cap remains a known construction limit; full Chapter and army legality, all possible Leader combinations, network behavior, complete-match certification and human playtesting remain open.
