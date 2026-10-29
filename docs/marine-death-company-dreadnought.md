# Death Company Dreadnought datasheet audit

## Source and snapshot

This audit covers Blood Angels App datasheet `000000166` in source book `000000021` for Warhammer 40,000 11th edition. The [current Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Death-Company-Dreadnought) and the [Core Rules Surge Moves section](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) were checked on 28 October 2026. The datasheet page does not publish a separate revision identifier.

Fixed datasheet facts come from the verified Wahapedia Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, updated `2026-10-21T16:06:23+03:00`, specification revision `20260817b`. The parent manifest SHA-256 is `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; the derived Blood Angels App slice manifest SHA-256 is `74de1b23c1319c395f9071449b47531870067eb0aa9c2de3ff6110ccd9e162c5`.

Relevant source-file SHA-256 values:

| Export file | SHA-256 |
|---|---|
| `Last_update.csv` | `e39235a323535cd23fbcbc3813bf939df34511b9a10203ca93377700e2ec7485` |
| `Source.csv` | `1b9d28d0d8c8c47746088e5f778afe1b4eb39a7e3ac35a7a8d4cce3a276ad9a9` |
| `Datasheets.csv` | `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c` |
| `Datasheets_models.csv` | `9cb303097f003f2eaa3bfc7cba8d3d7579b0364a35a139bafa5c0705bbd68d03` |
| `Datasheets_models_cost.csv` | `2114a9c824060fa66abef42b66ad70e43b98afb38e2cef221a2fb550ca213b8e` |
| `Datasheets_unit_composition.csv` | `f00a66fedc7b1df1a5a3907f763561db75789e3db82a0bd1f6a059fc2061e245` |
| `Datasheets_abilities.csv` | `49b054afc2f9977b9c8168ee446b016bd097b047adbd7ec35d23df5f054d7fe6` |
| `Datasheets_keywords.csv` | `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341` |
| `Datasheets_options.csv` | `642b8b74e57ac45aa5a383f46afd1cbd0a7e873a19dbee5a624cfbf6043e3853` |
| `Datasheets_wargear.csv` | `565b48410062728c942c709d0e61408660f18914b652fed6c77172d801f84d7d` |

The raw export remains ignored under `.tools`; these hashes identify the pinned local snapshot and do not replace rechecking a later adopted source revision.

## Integrated local scope

The Dreadnought is one model on a 90 mm round base. Its first and second copies cost 165 points each; each third-or-later copy costs 185 points, with a three-copy construction limit. Characteristics are M10, T10, Sv2+, W12, Ld6+, OC4. Its exported keywords are Blood Angels, Adeptus Astartes, Death Company, Imperium, Walker, Vehicle and Dreadnought.

The default ranged package is Blood Fist Bolt Rifles, Twin Heavy Bolter and Twin Icarus Ironhail Heavy Stubber; its melee weapon is Blood Fists. Army Preparation can replace the Twin Heavy Bolter with a Twin Multi-melta, and can replace both the Blood Fist Bolt Rifles and Blood Fists with Blood Talons. These choices carry no additional points. The Twin Heavy Bolter profile has Sustained Hits 1 and Twin-linked; it does not have Rapid Fire. Blood Talons have Cleave 2, Twin-linked and Sustained Hits 1 against targets without MONSTER or VEHICLE.

The profile registers Damaged 4, Deadly Demise D3, Combat Doctrines, Feel No Pain 6+, Black Rage and Driven by Fury. Damaged 4 applies the shared -1 Hit modifier at four or fewer remaining wounds. The prevention grant supplies one 6+ Feel No Pain roll per normal or mortal wound. Deadly Demise uses the shared D3 value and destruction resolver; the wider shared chain-destruction scope remains pending.

Black Rage grants melee Hit rerolls of 1. Its source wording uses “or” between the two missing-range conditions. The implementation follows that wording: to avoid the Fall Back and OC 0 restriction, the unit must be within 6 inches of a friendly Blood Angels Character **and** within 12 inches of a friendly Chaplain. The check uses living models on the battlefield, the selected Blood Angels army context for generic Astartes Characters, and Chaplain profile identities because the export does not provide a CHAPLAIN keyword.

Driven by Fury opens for the defender after an opponent's shooting attack scored at least one hit, provided the Dreadnought has not moved this phase, is not Battle-shocked and is not engaged. Its controller can decline or roll a host-provided D6 and add 1 inch. The placement decision selects a closest enemy, then validates the Surge distance, supported route, closer destination, required Engagement Range/as-close-as-possible endpoint and exclusion of engagement with another enemy. The local route search is bounded and does not certify every possible tabletop path or destination.

## Local checks and limits

The dedicated offline verification passed **5/5 processes** at `.tools/verification/20261028T194021499437Z/results.json` (SHA-256 `3B263606A2821852AA4FE90C4C547996C7B563958A60C58BBD8C5A724A3A5A9A`; `network: false`, `legacy_starter_staged: true`, no cleanup diagnostics):

```powershell
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_death_company_dreadnought --only test_implemented_catalog --only test_capabilities --timeout 300
```

The suites cover the source snapshot and profile, point tiers and copy limit, all fixed weapon values and traits, public equipment choices and invalid-choice rejection, Feel No Pain grant, Damaged 4, Deadly Demise value, Black Rage attack and support effects, the standard Fall Back gate, Driven by Fury trigger exclusions, the resolved-shot reaction hook, D6+1, closest-target selection, phase-close blocking, preview and confirmation, suspended attack continuation, selectable-catalog count and capability registry. The targeted verifier staged its ignored local legacy starter fixture because these selected suites require it; the run did not request network access.

These results close the declared Death Company Dreadnought local datasheet scope. They do not certify all Deathly Demise chain interactions, full Blood Angels/Space Marine army legality, other Chapter books, Forge World, Legends, network behavior, complete-match behavior or human playtesting. Network validation remains deferred to final integration.
