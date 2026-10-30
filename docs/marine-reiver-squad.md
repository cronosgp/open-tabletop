# Reiver Squad — Space Marines datasheet scope

This audit closes the Reiver Squad source-defined local scope in the shared Space Marines App book only. The source is Wahapedia's 11th-edition [Reiver Squad datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Reiver-Squad), book `000000139`, datasheet `000002718`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

## Verified local data source

The Space Marines local Wahapedia Data Export snapshot is `20261021T130623Z`, retrieved at `2026-10-21T19:46:58Z`. `Last_update.csv` records `2026-10-21 16:06:23 GMT+3`; export specification revision `20260817b`; the 23-file manifest has SHA-256 `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`. Relevant source filenames and SHA-256 values:

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

The raw export remains ignored under `.tools`; these hashes identify the pinned snapshot and do not replace checking a newer revision when one is adopted. The runtime profile retains its original `2026-10-16T21:03:46+03:00` stamp; this audit is tied separately to the verified 21 October snapshot.

## Implemented and locally checked scope

- One Reiver Sergeant and four to nine Reivers; five models cost 85 points and ten cost 165 points. Models use 32 mm bases and M8, T4, Sv3+, W2, Ld6+, OC1. The profile carries ADEPTUS ASTARTES, INFANTRY, EXPLOSIVES, IMPERIUM, PHOBOS and SMOKE.
- Every model has a Bolt Carbine, Special-issue Bolt Pistol and Monomolecular Combat Knife. Their source statistics and traits are checked through `Equipment` and `AttackPlan`: Assault/Precision on the carbine; Close-quarters/Precision on the pistol; Precision on the knife.
- The unit's two independent equipment options, Grav-chutes and Grapnel Launchers, are offered during setup, applied and removed through public commands. Grav-chutes grant Deep Strike and expose the unit to the existing reserve flow.
- Scouts 6 is registered for every Reiver model. Terror Troops reduces each enemy model's OC by 1 while it is within 3 inches of a living Reiver, retaining the normal zero-OC Battle-shock boundary.
- Fearsome Assault opens at the start of the Fight phase before the Fight sequence. Each engaged enemy unit takes one Battle-shock test at -1; existing Battle-shock persists after a passing test. The normalized result and defender-owned Tempered in Battle re-roll decision retain and resume the phase-start frame after serialization.
- Grapnel Launchers allow paths through models and ignore vertical distance for movement distance on the supported central ruin first floor. The check also confirms the normal 1/2-inch ruin-wall access requirement still applies; it does not extend to unsupported floor heights or arbitrary terrain geometry.
- The verified local export links Reivers to Librarian in Phobos Armour, Captain in Phobos Armour and Lieutenant in Phobos Armour. All three links pass the attachment predicate; a generic Captain is rejected.
- The dedicated fixture uses current-catalog Space Marines on both sides and checks admission of both priced sizes and rejection of an unsupported six-model size.

## Validation and limits

The dedicated offline command passed **3/3 processes** (project import, Python checks and `test_reiver_squad`), with `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics, at `.tools/verification/20261027T071129977108Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_reiver_squad --timeout 300
```

This closes only the Reiver Squad declared source-bounded shared-book local scope (**12/85 datasheets complete**). Whole-army legality, other datasheets, Chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.
