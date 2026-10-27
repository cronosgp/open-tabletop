# Space Marine enhancements in local training

## Army Workshop screen brief

- **Goal:** assign one supported enhancement for the selected Space Marine detachment to one unit entry and make its extra points visible.
- **Context:** the player selects an existing entry in the local army list.
- **Information order:** unit name and composition, current points, then the enhancement picker. The picker shows the enhancement name, points cost, and detachment requirement.
- **Primary action:** select an eligible enhancement. A multi-copy row splits into an unenhanced row and one enhanced unit before assignment.
- **Feedback:** the selected list row names its enhancement and shows the added points. The list total includes the added cost. The helper text asks the player to select the matching detachment for match setup.
- **Unavailable state:** the picker is disabled when the selected local datasheet has no supported enhancement. An enhancement already assigned elsewhere in the army is disabled.
- **Rules boundary:** the source is the local Wahapedia 11e export. Pending and historical profiles remain outside construction choices. This Army Workshop entry is a training roster choice, not a complete legality certification.
- **Capture status:** graphical before/after captures were unavailable in this environment because no Godot executable was found on PATH or in the workspace. The UI has not received graphical QA at supported viewport sizes.

## Implemented source rows

| Export ID | Enhancement | Eligible supported local profiles | Runtime effect |
|---|---|---|---|
| `000008486002` | Supercharged Engines | Chaplain on Bike, Captain on Bike, Outrider Squad, Invader ATVs | Free Advance reroll in the pending movement decision. |
| `000008486003` | Auspex Triangulation Shrines | Storm Speeder Hammerstrike, Hailstrike, Thunderstrike, Land Speeder | At Shooting start, mark one visible enemy within 12 inches spotted; +3 inches detection range while marked. |

The local export also maps Supercharged Engines to Scout Bike Squad, Ravenwing Black Knights, Thunderwolf Cavalry and Ravenwing Command Squad, and Auspex Triangulation Shrines to Ravenwing Darkshroud and Land Speeder Vengeance. Those datasheets do not yet have selectable runtime profiles, so they remain unavailable in construction until reconciled and admitted. Exported spotted text contains no expiry clause, so the selected mark lasts for the battle. `tests/test_stormlance_enhancements.gd` passed its local checks; networking and full army legality remain deferred.


## Inner Circle Task Force

The 20-point **Champion of the Deathwing** enhancement is selected through the same Army Workshop picker. Snapshot `20261021T130623Z` maps it to five DEATHWING datasheet IDs; all five identities have current-reference profiles in the consolidated Marine catalog. In a match, the bearer's unit gains Sustained Hits 1 against enemies within range of its owner's active Vowed objective. Focused checks and human playtesting are pending. This current increment did not run tests.


## Medusa's Wrath

The enhancement **The Flesh is Weak** (15 points) is selectable for 23 current-catalog identities linked by the local export relation. The bearer model gains +1 Toughness and Feel No Pain 5+ against any wound. These effects use the existing per-model defender profile and prevention resolver; when attached to a Bodyguard unit, Toughness continues to follow its surviving Bodyguard models.

The enhancement **Target Augury Web** (30 points) is selectable for the current-catalog Techmarine profile. At the start or end of its unit’s Movement-phase move, the player may select one friendly Adeptus Astartes Vehicle model within 3 inches of any model in the bearer unit. The selected model’s ranged and melee attacks gain Lethal Hits until the start of its owner’s next Command phase. The local action uses base-edge geometry, appears at both source-listed timings, and holds movement confirmation until a start-of-move choice is resolved. Its effect is stored by vehicle model and is applied through the shared per-model attack-profile path.


The enhancement **Master of the Machine War** (25 points) is selectable for 23 source-linked current-catalog profiles. In the owner's Movement phase, the bearer selects one visible friendly Adeptus Astartes Vehicle unit within 6 inches and chooses Devastator or Tactical Doctrine for it until the start of the owner's next Command phase. The per-unit doctrine uses the shared active-doctrine query and doctrine selection limit.
The verified local snapshot is `20261021T130623Z` (retrieved `2026-10-21T19:46:58Z`, revision `20260817b`). Enhancement row `000011180005` links to 37 datasheets, of which 23 are in the current consolidated catalog. Source hashes: `Enhancements.csv` `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`, `Datasheets_enhancements.csv` `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`, and `Datasheets.csv` `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`.

Target Augury Web is row `000011180002`, related to Techmarine `000000140` and Iron Priest `000000306`; only Techmarine exists in the current consolidated catalog. The source hashes are recorded in the [rules ledger](space-marines-rules-ledger.json). Wahapedia’s Space Marines 11e App 2.8.1 page was observed on 26 October 2026.

Master of the Machine War is row `000011180004` and links to 37 datasheets, 23 of which resolve to current consolidated Marine profiles. The complete source relation and snapshot hashes are recorded in the [rules ledger](space-marines-rules-ledger.json).

No tests, Godot session or capture were made for this increment. Focused local checks, visual review and human acceptance remain pending; the enhancement and detachment are not certified as fully legal.

The enhancement **Adept of the Omnissiah** (25 points) is selectable for the current-catalog Techmarine. Once per battle round per army, when an enemy unit targets a friendly Adeptus Astartes Vehicle within 6 inches of the bearer unit, the defender may grant that Vehicle Feel No Pain 5+ against the triggering enemy's attacks until that attack resolution completes. The persisted response is available before attacks in the Shooting and Fight phases and uses the common damage-prevention path.

The verified local export row is `000011180003` in snapshot `20261021T130623Z`, revision `20260817b`. It links to Techmarine `000000140` and Iron Priest `000000306`; only Techmarine is in the current consolidated catalog. The source file hashes are recorded in the [rules ledger](space-marines-rules-ledger.json). Focused checks, human playtesting, network validation and full army legality remain pending.

## Blade of Ultramar

**Armour of Antoninus** (`000010633003`, 15 points) is selectable for 23 current-catalog Space Marine Character profiles linked by the local export. The bearer model has a 2+ Save and Feel No Pain 5+ against any wound. The standard enhancement rules exclude EPIC HERO models and require a CHARACTER bearer; the runtime picker applies those filters alongside the export relation and Blade of Ultramar detachment.

**Oath of Macragge** (`000010633004`, 20 points) is selectable for the same 23 current-catalog Character profiles. The bearer model's melee attacks gain +1 Strength and AP, or +2 Strength and AP while Assault Doctrine is active. Its effect shares the existing per-model melee weapon modification path used by Laurels of Triumph.

**Veteran of Behemoth** (`000010633005`, 20 points) is selectable for the same 23 current-catalog Character profiles. The bearer unit's ranged attacks gain Sustained Hits 1 through the shared attack-profile path; a stronger existing Sustained Hits value is preserved.

This uses the Wahapedia Space Marines 11e App 2.8.1 page observed on 26 October 2026 and the verified local export snapshot `20261021T130623Z` (retrieved `2026-10-21T19:46:58Z`, revision `20260817b`). Rows `000010633003`, `000010633004` and `000010633005` each relate to the same 37 datasheets, all marked CHARACTER in the local keyword table; 23 resolve to current consolidated profiles that pass the non-Epic-Hero filter. The verified source file hashes are `Enhancements.csv` `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`, `Datasheets_enhancements.csv` `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`, `Datasheets.csv` `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`, and `Datasheets_keywords.csv` `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341`.

Armour of Antoninus uses per-model Save and wound-prevention paths; Oath of Macragge uses per-model melee weapon modification; Veteran of Behemoth adds its unit-wide ranged trait after target-specific weapon restrictions are resolved, preserving stronger native Sustained Hits values. All six Blade of Ultramar stratagems now have local paths, including Tactical Foresight's attack-declaration response and conditional Wound modifier; see [detachment stratagem scope](rules/detachment-stratagems.md#blade-of-ultramar). Focused local checks, Godot presentation review, human acceptance, network validation and full Ultramarines army legality remain pending.

## Phobos Shadow Force

**Venator Omni-auspex** (15 points, export row `000011188002`) is selectable for the four verified current-catalog PHOBOS bearers: Lieutenant with Combi-weapon, Librarian in Phobos Armour, Lieutenant in Phobos Armour and Captain in Phobos Armour. Its source-linked attacks re-roll Wound rolls of 1 against a hidden target, or 1 and 2 while Assault Doctrine is active for the attacking unit. Successful natural 2s are offered as optional free re-rolls through the existing persisted Wound checkpoint. The Shadow Force source row and capability remain distinct from the identically named Phobos Shock Force enhancement; attack resolution is shared.

The source mapping is from Data Export snapshot `20261021T130623Z`, revision `20260817b`. `Enhancements.csv` SHA-256 is `7df67f570117355fcf1e4f649b33806b7669456ab2fe839741db0ffc7889026f`; `Datasheets_enhancements.csv` SHA-256 is `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`. Wahapedia Space Marines 11e App 2.8.1 was observed on 26 October 2026. Focused checks and playtesting remain pending; network validation and full army legality are uncertified.

**Execute and Redeploy** (25 points, export row `000011188003`) is selectable for those same four PHOBOS bearers. After the unit shoots in its own Shooting phase, if it is unengaged, the owner may make a Normal Move up to 6 inches; if it moves, it cannot declare a Charge until turn end. Its post-shot choice follows Shadow Masters in the persisted window chain. Core Rules §09.05.01 prevents a second Normal Move in that phase, so after Shadow Masters has already moved the unit, Execute and Redeploy can only be passed. The move uses the shared preview and confirmation path with terrain, base overlap, coherency and end-unengaged checks.

## Fist of the God-Emperor

**Oathbound Exemplar** (10 points, export row `000011176003`) is now selectable for current-catalog Adeptus Astartes Infantry units linked by `Datasheets_enhancements.csv`. In a Fist of the God-Emperor match, the enhanced unit can remain eligible to start an action after an Advance or Fall Back move, provided it passes all other action requirements. The exception removes only the move-type restriction; it does not waive objective control, Battle-shock, engagement, action timing, or once-per-turn limits.

The prepared-match detachment selection enforces Black Templars Chapter context. The detachment's `Purge and Sanctify`, `Righteous Fervour` and stratagems do not yet have runtime paths; this remains a partial detachment. Source: Wahapedia Space Marines 11e App 2.8.1, observed 26 October 2026; local Data Export snapshot `20261021T130623Z`, revision `20260817b`. Source hashes are recorded in the [rules ledger](space-marines-rules-ledger.json). Focused local checks, Godot review, playtesting, network validation and full army legality remain pending.
