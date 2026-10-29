# Heavy Intercessor Squad — source-bounded local scope

This audit closes the Heavy Intercessor Squad's declared local scope in the shared Space Marines App book. Its rules source is Wahapedia's 11th-edition [Heavy Intercessor Squad datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Heavy-Intercessor-Squad), book `000000139`, datasheet `000001177`. Datasheet facts below come from the verified local export. This audit did not perform network validation.

## Verified local data source

The Wahapedia 11e Space Marines export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; Data Export specification revision `20260817b`; 23-file manifest SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant file hashes are recorded in [the machine-readable audit](marine-heavy-intercessor-squad-audit.json).

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

The runtime profile retains its earlier `2026-10-16T21:03:46+03:00` source stamp. This scope checks the profile against the separately identified 21 October snapshot without rewriting that provenance field.

## Implemented and locally checked scope

- One Heavy Intercessor Sergeant and four to nine Heavy Intercessors; five models cost 115 points and ten cost 230. Each has a 40 mm base and M5, T6, Sv3+, W3, Ld6+, OC2.
- The six source keywords are `ADEPTUS ASTARTES`, `BATTLELINE`, `EXPLOSIVES`, `GRAVIS`, `IMPERIUM` and `INFANTRY`.
- Every model starts with a Bolt Pistol, Heavy Bolt Rifle and Ceramite Fists. All four weapon profiles, including the Heavy Bolter option, are checked through `Equipment` and `AttackPlan`; the Heavy Bolter retains Heavy, Sustained Hits 1 and Rapid Fire 2.
- During setup, one non-Sergeant model per five starting models can replace its Heavy Bolt Rifle with a Heavy Bolter. The public `SELECT_UNIT_CHOICE` flow offers and applies the choice, preserves the pistol, leaves other models unchanged and restores the Heavy Bolt Rifle. The five-model unit is capped at one Heavy Bolter; the ten-model unit is capped at two. Wrong-owner, Sergeant-only and stale choices are rejected.
- `Unyielding in the Face of the Foe` grants +1 to saving throws while the unit contributes to an objective controlled by its player. The dedicated check routes the modifier through the damage save resolver: a 2 succeeds against a 3+ save with the ability active and fails when the unit is away from a controlled objective.
- The local source lists five Leader/Support links: Tor Garadon, Marneus Calgar, Apothecary Biologis, Captain in Gravis Armour and Iron Father Feirros. The profile test checks the exact relation set and materializes the Captain in Gravis Armour attachment. The paired `test_space_marine_leader_links` suite checks the complete 153-link local map.
- Current-catalog admission accepts the source-priced five- and ten-model sizes and rejects an unsupported six-model unit.

## Local validation

Focused offline verification passed **4/4 processes** (project import, Python checks, the dedicated datasheet suite and the 153-link relation suite) in `.tools/verification/20261027T073729361442Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_heavy_intercessor_current --only test_space_marine_leader_links --timeout 300
```

The report records `network: false` and `legacy_starter_staged: false`. The separate fixed-data audit `.tools/marine-comparison-20261027-v12.json` covers the bounded 85-profile identity and fixed-data comparison.

## Limits

This closes only the Heavy Intercessor Squad's source-bounded local shared-book scope. It does not certify whole-army legality, every combination of attached Leaders and Supports, Chapter-book adaptations, Forge World, Legends, network behavior, a complete match or human playtesting. Network validation remains deferred to final integration.
