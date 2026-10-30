# Infernus Squad — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for the [Infernus Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Infernus-Squad), book `000000139`, datasheet `000000126`. The facts below were checked against the verified local Data Export snapshot. This does not certify whole-army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant export-file hashes are preserved in the [machine-readable audit](marine-infernus-squad-audit.json). The runtime profile retains its earlier `2026-10-16T21:03:46+03:00` source stamp; this scope uses the separately identified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- One Infernus Sergeant and four to nine Infernus Marines; five models cost 95 points and ten cost 190. Third-plus cost tiers of 105/200 remain in the current catalog. Every model has a 32 mm base and M6, T5, Sv3+, W2, Ld6+, OC1, without an invulnerable save. The source keywords are `ADEPTUS ASTARTES`, `EXPLOSIVES`, `IMPERIUM`, `INFANTRY` and `TACTICUS`.
- The fixed loadout on every model is a Pyreblaster, Bolt Pistol and Ceramite Fists. The suite routes every weapon profile and trait through `Equipment` and `AttackPlan`.
- `Driven from Cover` opens after the Infernus unit shoots and hits. The owner can select one of the hit enemy units through `MatchCommandService`; the opposing player is rejected without mutation. Friendly Adeptus Astartes ranged attacks against the selected unit gain Ignores Cover for that Shooting phase. The test checks the actual cover state in `AttackPlan`, that the unselected target, enemy attacks and melee do not gain the effect, that the mark survives source loss and state serialization through the phase, and that it expires afterward. It also checks that no hits or opponent-turn shooting open the choice.
- Both players materialize from the consolidated current Marine catalog. The checked 1,000-point Incursion list admits both source sizes at their first-two prices and rejects a third non-Battleline copy. The export's third-plus prices remain visible in catalog metadata but are outside this checked roster format.
- The paired `test_space_marine_leader_links` suite validates the 153-link local Leader/Support map.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, this datasheet suite and the 153-link relation suite) at `.tools/verification/20261027T081932784642Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_infernus_squad_current --only test_space_marine_leader_links --timeout 300
```

## Limits

This closes only this source-bounded shared-book datasheet scope. It does not certify every army or Leader combination, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
