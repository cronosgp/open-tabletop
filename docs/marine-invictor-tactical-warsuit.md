# Invictor Tactical Warsuit — source-bounded local scope

This audit closes the Invictor Tactical Warsuit's declared local scope in the shared Space Marines App book. Its rules source is Wahapedia's 11th-edition [Invictor Tactical Warsuit datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Invictor-Tactical-Warsuit), book `000000139`, datasheet `000001156`. Datasheet facts below come from the verified local export. This audit did not perform network validation.

## Verified local data source

The Wahapedia 11e Space Marines export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; Data Export specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant file hashes are recorded in [the machine-readable audit](marine-invictor-tactical-warsuit-audit.json).

The runtime profile retains its earlier `2026-10-16T21:03:46+03:00` source stamp. This scope checks the profile against the separately identified 21 October snapshot without rewriting that provenance field.

## Implemented and locally checked scope

- One VEHICLE model, 135 points for each of the first two copies, 150 points for the third-plus copy, maximum three copies; M10, T9, Sv3+, W12, Ld6+, OC4 and a 90 mm circular base. The five source keywords are `ADEPTUS ASTARTES`, `IMPERIUM`, `PHOBOS`, `VEHICLE` and `WALKER`.
- The fixed loadout is Fragstorm Grenade Launcher, Heavy Bolter, Incendium Cannon, Ironhail Heavy Stubbers and Invictor Fist. All five default profiles and the Twin Ironhail Autocannon replacement profile are checked through `Equipment` and `AttackPlan`, including their source traits.
- During deployment, the public `SELECT_UNIT_CHOICE` path replaces the Incendium Cannon with the Twin Ironhail Autocannon and restores it. Wrong-owner and stale options are rejected without mutation.
- `Damaged 4` applies -1 to Hit in the actual shooting attack plan at four wounds remaining. `Deadly Demise D3` does not trigger on 5; on 6 it creates a mortal-wound allocation for a nearby enemy player.
- `Scouts 8` grants the source movement allowance: the unit is eligible for Strategic Reserves set-up, and the movement validator accepts 8 inches but rejects 8.01. The paired scout rules and geometry systems have broader checks elsewhere; this audit does not certify every placement and terrain case for the Invictor.
- `Forward Assault Warsuit` offers its first-round mark through a public normalized command, grants Wound re-rolls of 1 only against the marked unit, and offers a living replacement after the mark is destroyed. The replacement suspends the resolved attack continuation, rejects the opposing player without mutation and survives save/restore.
- The source export lists no Leader/Support links for this datasheet. The paired relation suite checks the complete 153-link shared-book map.
- Current-catalog admission accepts one through three copies at source costs and rejects a fourth.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, the dedicated datasheet suite and the 153-link relation suite) in `.tools/verification/20261027T074848766922Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_invictor_tactical_warsuit --only test_space_marine_leader_links --timeout 300
```

The report records `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics. The separate fixed-data audit `.tools/marine-comparison-20261027-v12.json` covers the bounded 85-profile identity and fixed-data comparison.

## Limits

This closes only the Invictor Tactical Warsuit's source-bounded local shared-book scope. The test covers the Scouts distance boundary and reserve eligibility, not every terrain-placement case. This does not certify whole-army legality, Chapter-book adaptations, Forge World, Legends, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
