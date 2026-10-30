# Eradicator Squad with Heavy Bolters — source-bounded local scope

This audit closes the shared-book 11th-edition local datasheet scope for [Eradicator Squad with Heavy Bolters](https://wahapedia.ru/wh40k11ed/factions/space-marines/Eradicator-Squad-with-Heavy-Bolters), book `000000139`, datasheet `000004231`. The facts below were checked against the verified local Data Export snapshot. The audit does not certify whole-army legality or network behavior.

## Verified local source

Snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`; `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant export-file hashes are preserved in the [machine-readable audit](marine-eradicator-heavy-bolters-audit.json). The runtime profile retains its earlier `2026-10-16T21:03:46+03:00` source stamp; this scope uses the separately identified 21 October snapshot without rewriting that provenance.

## Implemented and checked

- Each unit has one Eradicator Sergeant and two to five Eradicators. Three models cost 100 points and six cost 215; third and later copies cost 130 and 245 respectively. Each model has a 40 mm base and M5, T6, Sv3+, W3, Ld6+, OC1, with no invulnerable save. The five keywords are `ADEPTUS ASTARTES`, `EXPLOSIVES`, `GRAVIS`, `IMPERIUM` and `INFANTRY`.
- Every model is equipped with a Heavy Bolter, Bolt Pistol and Ceramite Fists. All three weapon profiles and their traits are checked through `Equipment` and `AttackPlan`.
- `Overlapping Destruction` lets this unit select one enemy; its Heavy Bolter attacks against that target gain Blast 1 for the Shooting phase. The suite covers the source target choice, wrong-owner rejection without mutation, target revision before attacks, the actual combined Blast/Rapid Fire attack count, the target's current model count, state serialization, expiry, no effect on pistols, melee, another squad or another target, and Blast's engaged-target restriction. The target selection spends no CP.
- The source's five Leader links are Captain in Gravis Armour, Tor Garadon, Marneus Calgar, Iron Father Feirros and Apothecary Biologis. The separate Support map retains the Biologis link. The paired relation suite checks all 153 local Leader/Support links.
- Both players materialize from the consolidated current Marine catalog. Current construction exposes the 3/6 sizes and their first-two plus third-plus cost tiers. The current checked 1,000-point Incursion roster admits at most two copies of this non-Battleline datasheet, so it rejects a third; the exported third-plus prices remain recorded for catalog contexts outside this checked roster.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, this datasheet suite and the 153-link relation suite) at `.tools/verification/20261027T081515345154Z/results.json` (`network: false`, `legacy_starter_staged: false`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_eradicator_heavy_bolters --only test_space_marine_leader_links --timeout 300
```

## Limits

This closes only this source-bounded shared-book datasheet scope. It does not certify every roster combination, Chapter-book variants, Forge World, Legends, Boarding Actions, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
