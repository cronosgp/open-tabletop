# Ancient and Bladeguard Ancient — source-bounded local scope

This audit closes the Ancient and Bladeguard Ancient local shared-book scopes. Their rules source is Wahapedia's 11th-edition [Ancient datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ancient), datasheet `000002775`, and [Bladeguard Ancient datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Bladeguard-Ancient), datasheet `000001165`, both in book `000000139`. Facts below are checked against the verified local Space Marines export. This audit does not perform network validation.

## Verified local data source

The Wahapedia 11e Space Marines export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; Data Export specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant filenames and hashes are recorded in [the machine-readable audit](marine-ancients-audit.json).

The runtime profiles retain their earlier `2026-10-16T21:03:46+03:00` export stamps. The dedicated scope verifies those profiles against the separately identified 21 October snapshot without rewriting their provenance.

## Ancient

- One model, 40 points, 40 mm base; M6, T5, Sv3+, W4, Ld6+, OC2, no invulnerable save. Its six unconditional source keywords are `ADEPTUS ASTARTES`, `CHARACTER`, `EXPLOSIVES`, `IMPERIUM`, `INFANTRY` and `TACTICUS`.
- The default loadout is Bolt Pistol, Bolt Rifle and Ceramite Fists. The Bolt Rifle has Focused Fire (24", A1, BS3+, S6, AP-1, D2, Heavy, Rapid Fire 1) and Saturation (24", A2, BS3+, S5, AP-1, D1, Assault, Rapid Fire 1) profiles. The one source equipment option replaces only the Bolt Rifle with a Power Weapon; the public preparation choice can restore the rifle.
- `Honour of the Company` grants +1 OC to each model in the current unit. The focused checks retain printed OC, suppress usable OC while Battle-shocked and stop the bonus when the Ancient is dead or off the battlefield.
- `Raise the Banner` secures an objective the unit controls at the end of its owner's Movement phase. The test covers the control check, shock/dead/enemy-turn/shooting/tie boundaries, persistence after departure, enemy capture, and a living Bladeguard Ancient conferring the rule through its bodyguard.

## Bladeguard Ancient

- One model, 70 points, 40 mm base; M6, T5, Sv3+, W4, Ld6+, OC3 and a 4+ invulnerable save. The fixed loadout is Heavy Bolt Pistol (18", A1, BS3+, S5, AP-1, D1, Close-quarters) and Relics of Battle (A4, WS3+, S5, AP-2, D2).
- The source export includes `DEATHWING`; project source reconciliation treats it as conditional on Dark Angels context. The prepared-match test verifies the default absence and the contextual grant.
- `Deeds of Legend` adds one melee attack while the unit is within objective range, regardless of objective control. The test checks its AttackPlan count, a split across two targets, no ranged bonus, source-profile immutability and loss of the effect when the Ancient dies.
- It also has `Raise the Banner` and Support.

## Support and local validation

Both identities use the Support slot. The 29 October cross-book export lists 13 Ancient targets, but Vanguard Veterans with Jump Packs is a Warhammer Legends profile and stays outside the standard catalog. Runtime therefore exposes the 12 standard targets: Intercessors, Assault Intercessors, Infernus, Hellblasters, Sternguard Veterans, Desolation, Inner Circle Companions, Deathwatch Veterans, Fortis Kill Team, Decimus Kill Team, Sword Brethren and Crusader Squad. Bladeguard Ancient supports Bladeguard Veterans. The dedicated test covers public Support declarations and representative matching conflicts; the full relation regression covers all 363 current standard Leader/Support links.

Focused offline verification passed **4/4 processes** (project import, Python checks, the Ancient suite and the 153-link relation suite) in `.tools/verification/20261027T080140069584Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_ancients --only test_space_marine_leader_links --timeout 300
```

The run materializes both players through the current Marine catalog, records `network: false` and `legacy_starter_staged: false`, and reports no cleanup diagnostics. It checks both profiles' source identity, composition, costs, characteristics, base size, keywords, loadouts and catalog admission; all seven weapon profiles through `Equipment` and `AttackPlan`; Ancient's reversible option and wrong-owner/stale-choice rejections; both ability sets; and contextual Deathwing behavior.

## Limits

This closes only the Ancient and Bladeguard Ancient source-bounded local scopes. Support tests and the global relation suite do not certify every roster combination. Full army legality, other Chapter-book adaptations, Legends, Boarding Actions, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.
