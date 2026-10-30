# Assault Intercessor Squad — source-bounded local scope

This audit closes the Assault Intercessor Squad's source-defined local scope in the shared Space Marines App book. Its authority is the Wahapedia 11th-edition [Assault Intercessor Squad datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Assault-Intercessor-Squad), book `000000139`, datasheet `000001606`. Datasheet facts come from the verified local export; this audit did not perform network validation.

## Verified local data source

The full relational Wahapedia 11e export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; the Data Export specification revision is `20260817b`; the 23-file manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant source files and hashes are also pinned in [the machine-readable audit](marine-assault-intercessor-squad-audit.json).

| Export file | SHA-256 |
|---|---|
| `Last_update.csv` | `e39235a323535cd23fbcbc3813bf939df34511b9a10203ca93377700e2ec7485` |
| `Source.csv` | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Abilities.csv` | `4922f4c86c5b3ad31d5651feb4b395255a14912ec361e2296f80364a9a731410` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_leader.csv` | `af1d26d1d6188bb845777ad57aeb2a3c75e851c9a521b7c754b4607fa10abac4` |

The runtime profile retains its `2026-10-16T21:03:46+03:00` source-export stamp. This scope separately verifies its facts against the pinned 21 October snapshot; it does not rewrite the older profile stamp.

## Implemented and locally checked scope

- The unit contains one Assault Intercessor Sergeant and four to nine Assault Intercessors. Five models cost 85 points; ten cost 170. Every model has a 32 mm base and M6, T5, Sv3+, W2, Ld6+, OC2.
- The complete keyword set is `ADEPTUS ASTARTES`, `BATTLELINE`, `EXPLOSIVES`, `IMPERIUM`, `INFANTRY` and `TACTICUS`.
- Every model starts with a Heavy Bolt Pistol and Chainsword. The Sergeant's two replacement choices are selectable during setup through the public `SELECT_UNIT_CHOICE` flow and can be restored independently:
  - Heavy Bolt Pistol → Hand Flamer or Plasma Pistol.
  - Chainsword → Power Fist, Power Weapon or Thunder Hammer.
- The setup selector offers only replacements for the living Sergeant. Tests reject a normal model, another player's command and a stale option without changing the loadout. Changing the Sergeant's choice leaves every other model's equipment untouched.
- Every ranged and melee profile is checked through `Equipment` and `AttackPlan`. The Plasma Pistol retains Standard and Hazardous Supercharge profiles; the Thunder Hammer retains Devastating Wounds.
- `Targeted Intercession` adds +1 Strength and +1 AP to this unit's melee attacks after it makes a charge move. It also applies to the selected Thunder Hammer, leaves its printed profile intact and does not alter ranged attacks.
- The selectable Captain-to-Assault-Intercessor Leader link is exercised in the materialized match. The paired `test_space_marine_leader_links` suite checks the complete 153-link local map, including this target.
- The current local construction catalog admits the source-priced five- and ten-model sizes and rejects an unsupported six-model size.

## Local validation

Focused offline validation passed **4/4 processes** (project import, Python checks, the dedicated datasheet suite and the 153-link relation suite) in `.tools/verification/20261027T072248470555Z/results.json`:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_assault_intercessor_current --only test_space_marine_leader_links --timeout 300
```

The report records `network: false` and `legacy_starter_staged: false`. The fixed-data audit `.tools/marine-comparison-20261027-v12.json` remains the separate evidence for the bounded 85-profile comparison.

## Limits

This closes only the source-bounded local shared-book scope for this datasheet. It does not certify whole-army legality, every combination of attached Leaders and Supports, Chapter-book adaptations, Forge World, Legends, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
