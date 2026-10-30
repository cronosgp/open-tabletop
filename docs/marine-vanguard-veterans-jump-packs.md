# Vanguard Veteran Squad With Jump Packs — Space Marines datasheet scope

This audit closes the Vanguard Veteran Squad With Jump Packs' source-defined local scope in the shared Space Marines App book only. Its source is Wahapedia's 11th-edition [Vanguard Veteran Squad With Jump Packs datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Vanguard-Veteran-Squad-with-Jump-Packs), book `000000139`, datasheet `000000147`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

## Verified local data source

The Space Marines local Wahapedia Data Export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; export specification revision `20260817b`; the manifest has 23 files and SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. The relevant source files and SHA-256 values are:

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

The raw export remains ignored under `.tools`; these hashes identify the recorded snapshot and are not a substitute for checking a newer source revision when one is adopted.

## Implemented and locally checked scope

- One Sergeant and four to nine Vanguard Veterans, fielded as five or ten models. Characteristics: M12, T5, Sv3+, W2, Ld6+, OC1; 32 mm bases.
- The first and second copies cost 110/220 points for five/ten models. Third-plus copies cost 130/240 points. The consolidated local catalog admits up to three copies and rejects a fourth; roster admission applies the correct third-plus tier.
- Default equipment is role-specific: the Sergeant has a Heavy Bolt Pistol and Relic Blade; each ordinary Veteran has a Heavy Bolt Pistol and Master-crafted Power Weapon.
- Every model can replace its Heavy Bolt Pistol with a Combat Shield, which grants a 5+ invulnerable save only to that bearer, or a Plasma Pistol. The Sergeant's choice is independent; ordinary Veterans are limited to two Plasma Pistols per five models. Checks cover two ordinary pistols in a five-model unit and four in a ten-model unit, and reject a fifth in the ten-model unit.
- The Sergeant can replace the Relic Blade with a Power Fist or Thunder Hammer. Heavy Bolt Pistol, both Plasma Pistol modes, Master-crafted Power Weapon, Relic Blade, Power Fist and Thunder Hammer source characteristics and traits are routed through AttackPlan. This includes Plasma Supercharge's Hazardous, Thunder Hammer's Devastating Wounds, Relic Blade's Cleave, conditional Lethal Hits and the Vanguard Assault extra Attack.
- Deep Strike is checked for every model after attaching the source-listed Captain With Jump Pack. The assembled unit can be placed in Strategic Reserves through the projected public choice; the check confirms all six attached-unit models leave the battlefield and the reserve record includes the Leader-inclusive 200-point roster cost. Subsequent reserve set-up uses the shared reserve resolver.
- Captain With Jump Pack is an allowed Leader. The conditional `DEATHWING` keyword is applied in Dark Angels Chapter context and removed when that context is cleared; it is not added to the shared unit keywords by default.

## Validation and limits

The dedicated offline command passed **3/3 processes** (project import, Python checks and `test_vanguard_veterans`), with `network: false` and `legacy_starter_staged: false`, at `.tools/verification/20261027T053433336440Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_vanguard_veterans --timeout 300
```

This closes only the Vanguard Veteran Squad With Jump Packs' declared source-bounded shared-book local scope (**4/85 datasheets complete**, alongside Scout Squad, Lieutenant and Redemptor Dreadnought). It does not certify whole-army legality, full faction coverage, other Chapter-book datasheets, Forge World, Legends, every Rapid Ingress or reserve ingress path, a full match, network behavior or human playtesting. Network validation remains deferred to final integration.
