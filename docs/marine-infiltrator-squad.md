# Infiltrator Squad — Space Marines datasheet scope

This audit closes the Infiltrator Squad source-defined local scope in the shared Space Marines App book only. The source is Wahapedia's 11th-edition [Infiltrator Squad datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Infiltrator-Squad), book `000000139`, datasheet `000000128`. Datasheet facts below come from the verified local export snapshot; this audit did not perform network validation.

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

The raw export remains ignored under `.tools`; these hashes identify the pinned snapshot and are not a substitute for checking a newer revision when one is adopted. The runtime profile keeps its original `2026-10-16T21:03:46+03:00` source stamp; the scope audit is tied separately to the verified 21 October snapshot.

## Implemented and locally checked scope

- One Infiltrator Sergeant and four to nine Infiltrators; five models cost 85 points and ten cost 150 points. Models use 32 mm bases and M8, T4, Sv3+, W2, Ld6+, OC1.
- Every model has INFANTRY, EXPLOSIVES, IMPERIUM, PHOBOS, SMOKE and ADEPTUS ASTARTES. The default equipment is a Marksman Bolt Carbine, Bolt Pistol and Ceramite Fists.
- The source lists one equipment option: one model can take one Helix Gauntlet. Army preparation offers the choice on each individual model; choosing a bearer moves the option, and the player can remove it. Helix healing is available in the bearer's Command phase and heals D3 wounds through the shared healing preview and overflow handling, including returning a destroyed non-Character model under the existing survivor-first placement rules. A destroyed bearer cannot activate it.
- **Infiltrators:** the squad can be set up outside its deployment zone only when the entire base fits on the battlefield and is more than 8 inches from the enemy deployment zone and deployed enemy models. The suite checks the permitted midfield placement, both 8-inch limits, the battlefield edge and that an Intercessor cannot use the rule. A source-linked Phobos Lieutenant retains the squad's all-model eligibility when attached.
- **Omni-scramblers:** in its own Shooting phase the squad can select one visible enemy within 18 inches; the target gains +3 inches to detection range until the phase ends. The suite checks visibility/range admission, the once-per-phase limit, phase expiry, combination with the separate +6-inch Optics effect, and rejection of targets hidden beyond current detection. Wrong-owner and stale public commands are rejected without changing state.
- The source lists Captain in Phobos Armour, Librarian in Phobos Armour and Lieutenant in Phobos Armour as Leader links. All three links pass the attachment predicate; a generic Captain does not.
- The suite checks all three source weapon profiles through `Equipment` and `AttackPlan`, the current catalog's 5/10-model admission at 85/150 points, rejection of the unsupported six-model size, and a match fixture built from current Space Marines catalog entries for both players.

## Validation and limits

The shared offline command passed **6/6 processes** (project import, Python checks, Apothecary scope and parity, Infiltrator healing regression, and the 153-link Leader/Support suite), with `network: false`, `legacy_starter_staged: false` and no cleanup diagnostics, at `.tools/verification/20261027T092025938936Z/results.json`:

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_apothecary --only test_apothecary_profile_parity --only test_infiltrator_squad --only test_space_marine_leader_links --timeout 300
```

This closes the Infiltrator Squad and Apothecary declared source-bounded shared-book local scopes (**24/85 datasheets complete**). Whole-army legality, other datasheets, Chapter-book variants, Forge World, Legends, network behavior, full-match certification and human playtesting remain outside this result. Network validation remains deferred to final integration.
