# Scout Squad — 11th edition local scope

**Status:** source-bounded local datasheet scope implemented and tested. This is the first of 85 shared-book Space Marines sheets to meet that gate.

## Source identity

- Authority: Wahapedia, Warhammer 40,000 11th edition, Space Marines, shared source book `000000139`.
- Datasheet: `000001160`, source page [Scout Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Scout-Squad).
- Verified local snapshot: `20261021T130623Z`; source rows and snapshot hashes are recorded in [the source identity map](space-marines-source-identity-map.json).
- Runtime: `scout-squad` in `scripts/edition_11/current_reference_marine_profiles.gd`; preparation and pre-battle rules use the current edition unit actions and ability systems.

## Implemented source scope

- Five models for 65 points or ten for 120, with one Sergeant and four or nine Scouts. Other sizes are rejected by local admission.
- Fixed Bolt Pistol, Boltgun and Combat Knife equipment; the 28.5 mm base and profile characteristics match the verified source comparison.
- All five source equipment options are available with source limits: Sergeant Boltgun to Shotgun; Sergeant Combat Knife to Chainsword; any Scout Boltgun to Shotgun; one Sniper Rifle per five models; and one Heavy Bolter or Missile Launcher per five models. The Missile Launcher supports Frag and Krak profiles.
- AttackPlan receives the selectable Bolt Pistol, Boltgun, Shotgun, Sniper Rifle, Heavy Bolter and both Missile Launcher modes. The Sergeant's Chainsword is also exercised through the melee plan.
- Infiltrators is enforced during deployment, including the source enemy-zone restriction.
- Scouts 6 uses the shared pre-battle normal move or Strategic Reserves set-up flow for the Scout Squad. Both paths retain base placement, coherency, distance, deployment-zone and sequencing checks.
- Flexible Asset permits an otherwise eligible Action after Advance or Fall Back and does not remove the Battle-shock restriction.
- Both source-listed Leaders are supported: Captain in Phobos Armour and Librarian in Phobos Armour. Attached Scouts retain their tested Scouts and Infiltrators eligibility.

## Verification

The dedicated rules-scope suite passed with project import and Python checks in `.tools/verification/20261027T044508003953Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_scout_squad --timeout 300
```

The cross-system rerun passed **8/8 processes** in `.tools/verification/20261027T043821951990Z/results.json`, covering Scout Squad, Phobos Librarian, Infiltrators, all 153 shared-book Leader/Support links, Combat Doctrines and catalog admission. The newer Scout-only run above separately includes the Scout Squad Strategic Reserves assertion. The pinned local comparison `.tools/marine-comparison-20261027-v12.json` reports zero fixed-data identity or numeric differences for all 85 shared-book profiles, including Scout Squad's nine weapon profiles; see [verification results](verification/verification-results.md).

This status is limited to the shared-book Scout Squad's source-defined local rules and admission. It does not certify every Space Marines roster, faction or detachment combination, network behavior, or Chapter-book, Forge World and Legends variants.

The consolidated implementation notes remain in [Space Marines profile records](space-marines-profile-records.md#marine-scout-squad); overall progress is tracked in the [coverage matrix](space-marines-coverage.md).
