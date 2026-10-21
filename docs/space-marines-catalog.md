**Current admitted status (19 October 2026):** The runtime offers all 85 shared-book Space Marine datasheets, including Wardens of Ultramar. The eight transport sheets and Wardens passed local profile, rules, loadout, points and materialization checks. Network validation remains deferred to final integration. Full faction and army legality remain uncertified.

**Ironclad Champions increment (19 October 2026):** Enduring Vengeance, all three stratagems and both enhancements from the local Wahapedia export pass focused Godot checks in `test_ironclad_champions.gd`. Checks cover Dreadnought eligibility, costs, damage reduction, attack-plan hit rerolls, both Mercy modes, Adamantine Terror's -1 Battle-shock modifier, Unstoppable Advance's Mobile movement and Venerable Champion's 6-inch Infantry aura. Network validation remains deferred; full faction and army legality are uncertified.

**Gladius increment (19 October 2026):** All four enhancements pass focused Godot checks in `test_gladius_enhancements.gd`. Adept of the Codex keeps Tactical Doctrine active alongside Assault Doctrine after Captain attachment. Artificer Armour applies 2+ Save and Feel No Pain 5+ to its bearer. Laurels of Triumph adds +1 Strength/AP, or +2 while Assault Doctrine is active, to the bearer's melee attacks. Standard of the Emperor Ascendant gives its Ancient bearer +1 OC, +1 Leadership and Feel No Pain 5+; its once-per-army battle ability adds +1 melee Attack to the attached unit for that Fight phase. Network validation remains deferred; full faction and army legality are uncertified.

**Gladius stratagem correction (19 October 2026):** Armour of Contempt opens when an enemy's actual attack declaration targets a friendly Adeptus Astartes unit. It binds that attacking unit and worsens its AP by 1 against the selected unit through the attack sequence, then expires. Its Wahapedia export row is `000008352002`; the local stratagem suite covers its trigger, CP cost, attacker binding and AP change.

The shared-book queue is now complete for the current 85 selectable identities. The eight transports and Wardens of Ultramar have local source profiles and targeted rule checks covering transport use, weapons, destruction, loadouts and datasheet effects. See [the transport implementation record](space-marines-profile-records.md#marine-transports) and [the Wardens implementation record](space-marines-profile-records.md#marine-wardens-ultramar). These checks do not certify complete faction or army legality.

Previous snapshot (18 October 2026, before targeted local validation): [Gravis Captain and Terminator Ancient](space-marines-profile-records.md#marine-gravis-ancient-batch) brought the runtime to 24 Marine identities and four Necrons. Its tests have since passed as recorded in the linked batch report.

Current Terminator Captain increment (18 October 2026): [Captain in Terminator Armour](space-marines-profile-records.md#marine-terminator-captain) adds the 90-point Leader, Strategic Acumen, Transhuman Strategist, Deep Strike, optional free charge reroll and independent weapon replacements. Admission covers twenty-two shared-book Marine identities and four Necron identities; 63 shared-book Marine identities remain unadmitted. Network validation remains deferred and full faction/army certification incomplete. Earlier increments below are historical.

Current Terminator Chaplain increment (18 October 2026): [Chaplain in Terminator Armour](space-marines-profile-records.md#marine-terminator-chaplain) adds the 75-point Leader, unit mortal-wound Feel No Pain 4+, melee Lance, Deep Strike and reversible Relic Shield. Attached Characters now count toward reserve costs. Admission covers twenty-one shared-book Marine identities and four Necron identities; 64 shared-book Marine identities remain unadmitted. Network validation remains deferred and full faction/army certification incomplete. Earlier increments below are historical.

Current Apothecary increment (18 October 2026): [Apothecary and shared healing](space-marines-profile-records.md#marine-apothecary) add the 45-point Support, Narthecium D3+1 healing with confirmed return previews, and the explicit Apothecary/Lieutenant attachment exception. Admission now covers twenty shared-book Marine identities and four Necron identities; 65 shared-book Marine identities remain unadmitted. Network validation remains deferred and full faction/army certification incomplete. Earlier increments below are historical.

Current Ancients increment (18 October 2026): [Ancient and Bladeguard Ancient](space-marines-profile-records.md#marine-ancients) add distinct 40/70-point Support profiles, Raise the Banner, Honour of the Company, Deeds of Legend and the ordinary Ancient’s reversible equipment option. Support construction now checks a complete compatible assignment, and split melee declarations distribute the Deeds attack only once. Admission now covers nineteen shared-book Marine identities and four Necron identities; 66 shared-book Marine identities remain unadmitted. Network validation stays deferred, and full faction/army certification remains incomplete. Earlier counts below are historical increments.

Current Bladeguard increment (18 October 2026): [Bladeguard Veterans](space-marines-profile-records.md#marine-bladeguard) add 3/6-model formations, Sergeant pistol choices and the once-per-turn offensive/defensive choice before attack dice. Captain, Chaplain, Lieutenant and Judiciar links are enabled for this bodyguard. Admission now covers seventeen shared-book Marine identities and four Necron identities; 68 shared-book Marine identities remain unadmitted. Only two Bladeguard copies are admitted; later-copy prices remain outside scope. Network validation stays deferred, and full faction/army certification remains incomplete. Earlier counts below describe historical increments.

Current Judiciar increment (18 October 2026): [Judiciar](space-marines-profile-records.md#marine-judiciar) adds its 50-point shared-book profile, mandatory Support attachment, unit Fights First from a living Tempormortis source, and melee-only 4+ invulnerable protection across automatic and manual allocation. Admission now covers sixteen shared-book Marine identities and four Necron identities; 69 shared-book Marine identities remain unadmitted. Network validation remains deferred and full army/faction certification remains incomplete. Earlier counts below are historical increments.

Current Chaplain increment (18 October 2026): [Chaplain](space-marines-profile-records.md#marine-chaplain) adds its current 60-point profile, Warlord/Leader declarations, Litany of Hate and once-per-round Spiritual Leader, including the same-start-window interaction with Smokescreen. Admission now covers fifteen shared-book Marine identities and four Necron identities; 70 shared-book Marine identities remain unadmitted. Existing scope limits and deferred networking remain in force. Earlier counts below are historical increments.

Current marksmen expansion, 18 October 2026: [Eliminator Squad](space-marines-profile-records.md#marine-eliminators) and [Sternguard Veteran Squad](space-marines-profile-records.md#marine-sternguard) are admitted with their documented equipment and executable unit abilities; core Smokescreen is implemented for the ground-level cylindrical proxy. There are fourteen selectable shared Marine identities and four Necron identities. This bounded admission is not full faction, army or match certification; network checks remain deferred. Historical counts below are retained as increment history.

# Space Marines rules catalog — inventory first

**Prior runtime snapshot (19 October 2026, before Tigurius and Shrike):** [Caanok Var](space-marines-profile-records.md#marine-caanok-var) followed Iron Father Feirros in the local Wahapedia e11 catalog. That snapshot represented 67 selectable shared-book Marine identities; 18 source identities were incomplete or unreconciled, with five historical profiles excluded from new construction.

**Adrax Agatone increment (19 October 2026):** Adds the 90-point Salamanders Epic Hero profile, source weapons, local Leader targets, Lord of the Pyroclasts and Unto the Anvil. Local admission, OC and wound-reroll checks passed; network validation remains deferred.


**Captain on Bike increment (19 October 2026):** Adds the 110-point fixed profile, Plasma Pistol/Thunder Hammer replacements, Outrider Squad Leader attachment and Into the Fray. The fixed-data comparison covers 42 profiles / 187 weapon-trait profiles; 41/42 pass all bounded checks with zero numeric or identity differences. Focused local validation passed 8/8 processes; network validation remains deferred.

**Terminator Assault Squad increment (19 October 2026):** [Terminator Assault Squad](space-marines-profile-records.md#marine-terminator-assault-squad) adds its 170/340-point 5/10-model profile, 210/380 third-plus tiers, individually priced Storm Shields and Terminatus Assault. The updated fixed-data comparison covers 41 profiles / 181 weapon-trait profiles; 40/41 pass with zero numeric or identity differences, leaving only the Ancient in Terminator Armour chapter-keyword context open. Focused local checks passed. Network validation remains deferred.

**Invictor Tactical Warsuit increment (19 October 2026):** adds the 135/150-point profile, the extracted Incendium Cannon / Twin Ironhail Autocannon choice, Damaged 4, Deadly Demise D3, Scouts 8 and Forward Assault Warsuit. The fixed-data comparison covers 24 profiles / 91 weapon trait profiles; 23/24 pass all bounded checks with zero numeric or identity differences. Ancient in Terminator Armour's `DEATHWING` context remains open. Focused local validation passed 6/6 processes.

**Tor Garadon increment (19 October 2026):** [Tor Garadon](space-marines-profile-records.md#marine-tor-garadon) adds the 90-point Imperial Fists Epic Hero, exact local-export weapons and profile, four source-listed Leader targets, Siege Captain and once-per-Shooting-phase Signum Array. Ten focused local Godot suites passed. Fixed-data comparison is deferred for this profile until a structurally valid pinned snapshot is available; network validation remains deferred as requested.

**Darnath Lysander increment (19 October 2026):** Adds the 160-point Imperial Fists Epic Hero, Fist of Dorn, Deep Strike, two source-listed Terminator Leader targets, phase-start Rampart and Icon of Obstinacy. Focused local profile, combat and admission checks passed. Fixed-data comparison is not claimed because the currently available snapshot fails structural validation; network validation remains deferred.

**Suboden Khan increment (19 October 2026):** [Suboden Khan](space-marines-profile-records.md#marine-suboden-khan) adds the 105-point White Scars Epic Hero, source-listed Outrider Leader pairing, Assault/Advance/Charge effects from Spear of Chogoris and Mobile sharing from Skilled Riders. His focused test plus catalog, capability and current-ability regressions passed. Fixed-data comparison is not claimed because the currently available snapshot fails structural validation; network validation remains deferred.

**Caanok Var increment (19 October 2026):** [Caanok Var](space-marines-profile-records.md#marine-caanok-var) adds the 100-point Iron Hands Epic Hero, Storm Bolter and Axiom, the two source-listed Terminator Leader targets, Feel No Pain 5+, Cold and Calculating and Cerebrex Logic Engine. Focused profile and ability checks plus catalog admission passed locally. Fixed-data comparison is deferred because the available snapshot fails structural validation; network validation remains deferred.

**Iron Father Feirros increment (19 October 2026):** [Iron Father Feirros](space-marines-profile-records.md#marine-iron-father-feirros) adds the 85-point Iron Hands Epic Hero, four source-listed Leader pairings, Master of the Forge, Rites of Tempering and Iron Father. The focused test checks source data and local effects; the catalog, capabilities and Techmarine shared-repair regressions pass. Fixed-data comparison is not claimed because the available comparison snapshot fails structural validation; network validation remains deferred.

**Redemptor Dreadnought increment (19 October 2026):** [Redemptor Dreadnought](space-marines-profile-records.md#marine-redemptor-dreadnought) adds its fixed 170/190-point profile, optional +10 Macro Plasma Incinerator, extracted weapon replacements, Damaged 4, Deadly Demise D3 and Duty Eternal. The bounded fixed-data comparison covers 22 profiles / 79 weapon trait profiles; 21/22 pass all fixed-data checks, with Ancient in Terminator Armour's `DEATHWING` context still open. Focused local validation passed 15/15 processes; a 7/7 follow-up also passed after capability-registry status was updated.

**Ballistus Dreadnought increment (19 October 2026):** [Ballistus Dreadnought](space-marines-profile-records.md#marine-ballistus-dreadnought) adds its fixed source profile, Ballistus Strike, Damaged 4 and a mortal-wound allocation window for Deadly Demise D3, including chained explosions. Construction uses the extracted 150-point first/second-copy and 170-point third-plus prices after local targeted checks. The fixed-data comparison covers 21 profiles / 70 weapon profiles; 20/21 pass all bounded checks, with Ancient in Terminator Armour's `DEATHWING` context still open.

**Firestrike Servo-turrets increment (19 October 2026):** [Firestrike Servo-turrets](space-marines-profile-records.md#marine-firestrike-servo-turrets) adds 1/2 turrets for 80/160 points, individually replaceable Twin Firestrike Las-talons, and Sentinel Protocols. Firestrike passes the bounded numeric, weapon trait, composition, default loadout, cost and shared keyword comparison. The current comparator covers 20 profiles / 65 weapon profiles; 19/20 are consistent, with Ancient in Terminator Armour DEATHWING context still open.

**Reiver Squad increment (19 October 2026):** [Reiver Squad](space-marines-profile-records.md#marine-reiver-squad) adds its 5/10-model profile and costs, Scouts 6, model-level Terror Troops, Fight-start Fearsome Assault, Grapnel Launchers and optional Grav-chutes/Deep Strike. At that increment, fixed-data comparison covered 19 profiles / 62 weapon profiles; 18/19 were consistent, with the Ancient `DEATHWING` context still open.

**Incursor Squad increment (19 October 2026, previous):** [Incursor Squad](space-marines-profile-records.md#marine-incursor-squad) adds its fixed default profile and costs, two-copy construction boundary, Scouts 6, Divinator-class Auspexes, once-per-battle Haywire Mine, and Phobos Librarian/Lieutenant Leader links. Focused local validation passed 15/15 processes. The fixed-data comparison covers 18 profiles / 59 weapon profiles; 17/18 are consistent, with Ancient in Terminator Armour unresolved for shared-versus-chapter `DEATHWING` context.

**Previous Librarian increment (19 October 2026):** [Librarian in Terminator Armour](space-marines-profile-records.md#marine-librarian-terminator-armour) adds the 80-point Leader, Deep Strike, Psychic Hood and both Librarius powers. Its conditional `DEATHWING` keyword is excluded from shared runtime keywords. This is an earlier increment; at the Scout increment the catalog had 33 runtime identities and 27 selectable Marine identities.

**Gravis follow-up (18 October 2026):** [Aggressors and Apothecary Biologis](space-marines-profile-records.md#marine-gravis) add two more admitted identities, with Aggressor 3/6 configurations, both armament packages, Close-quarters Firestorm and mandatory Biologis Support with non-Vehicle Lethal Hits. Current admission is ten shared-book Marine identities, with the original six retaining their fixed-loadout limits; 75 of the 85 shared-book source identities remain unadmitted. Network checks remain deferred. Earlier counts below describe earlier increments.

**Implementation follow-up (18 October 2026):** [Infernus and Hellblasters](space-marines-profile-records.md#marine-fire-support) now enter actual roster preparation and combat, including 5/10 compositions, their unit abilities and the optional Hellblaster Sergeant pistol. Eight shared-book Marine identities are admitted, with different completeness boundaries: the original six retain their documented fixed-loadout limitations. The other 77 shared-book identities, chapter content and remaining faction features still need implementation. Network validation is deferred to final integration by user request; local rule tests continue. Older counts and definition-only notes below are historical.

**Source slice follow-up (18 October 2026):** [85 shared-book datasheets now have a structurally valid, joined local catalog](wahapedia-marines-slice.md), with 41 external Leader identity dependencies kept separate. The six fixed profiles match the numeric/shared-keyword audit after checking the Terminator chapter context. This is imported source coverage, not 85 executable datasheets or full legality certification.

**Structured ingestion delivered (18 October 2026):** [Wahapedia snapshot importer and actual results](wahapedia-import.md). The 22-table capture resolves 85 shared-book identities within 193 Marine faction records, retaining chapter/Legends/source boundaries. The global snapshot has 68 structural errors and is audit-only. Six runtime profiles have no numeric differences under the implemented comparison; this is not complete datasheet certification. Older OpenHammer counts below remain historical discovery evidence.

**Current source policy (18 October 2026):** [Wahapedia e11 is definitive](rules-source-policy.md). Its CSV export is the preferred ingestion source; OpenHammer is discovery only. Earlier requirements below for separate official Codex/app locators are historical and no longer gate admission. Pending implementation, edition/source boundaries and interaction checks still apply.

**Status:** source inventory and incremental rules implementation are active. Current admitted counts and validation scope are summarized at the top of this document; inventory completeness and full faction/army certification remain pending.

**Rules target:** Warhammer 40,000 11th edition as published by Wahapedia, using the project's local `/wh40k11ed/` extraction as the single source of truth. See [rules-source policy](rules-source-policy.md).
**Historical-policy note:** older inventory text below may mention official Codex/app locators or live MFM confirmation as admission gates. Those gates are superseded by the 18 October decision recorded in [the current source policy](rules-source-policy.md); the local Wahapedia e11 extraction is the sole rules authority.

**Last source check:** 18 October 2026.

This catalog is the work queue and provenance ledger for expanding Space Marine coverage. A profile or rule remains unavailable in enforced matches until its current source, interactions and implementation scope have been checked. Existing ten fixed Marine profiles remain only the narrow scope described by [Current unit abilities](rules/current-unit-abilities.md).

## Scope boundary

The Space Marines inventory covers the Adeptus Astartes faction and all current chapter-specific rules that use its shared faction content:

- Shared Space Marines army rules, datasheets, weapons, wargear, unit abilities, detachment rules, enhancements and stratagems.
- Chapter packs and supplements that modify or add to shared Space Marine content, including Black Templars, Blood Angels, Dark Angels, Deathwatch, Space Wolves, Ultramarines, Imperial Fists, Iron Hands, Raven Guard, Salamanders and White Scars.
- Forge World / Legends datasheets as a separately labeled optional scope, including their matched-play status. They must not be silently treated as ordinary current matched-play units.
- Every legal composition and interaction: chapter restrictions, unit variants, leader/support attachment choices, transports, reserves, keywords and detachment-point constraints.

Grey Knights, Chaos Space Marines, Death Guard, Thousand Sons, World Eaters and Emperor's Children are separate faction catalogues. They are not folded into Space Marines because of shared Astartes themes or model names.

The first catalog pass should inventory each source page and rule object, not transcribe complete rule paragraphs. Store concise, original mechanical summaries and source links; keep third-party catalogs and rule text out of bundled runtime data unless their redistribution rights are clear.

## Source and revision policy

| Source | Use | Limits |
|---|---|---|
| [OpenHammer 11e API](https://openhammer-api-production.up.railway.app/) | Bulk candidate discovery and provisional profiles, weapons, options, points and ability-name inventory | Community data with provider/version gaps and known stale fields. Preserve source ID, edition, retrieval date, request URL and digest; never make a record playable from import alone. |
| [Wahapedia Space Marines e11](https://wahapedia.ru/wh40k11ed/factions/space-marines/) and its chapter pages | Readable e11 rule reference for the slice currently being implemented; identify ability effects and interactions | Direct page observation on 17 October 2026 reports App 2.8.1 / October 2026. Record page URL/version/date. Do not block bulk discovery on checking every page in advance. |
| [Games Workshop downloads and app](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/) | Applicable current Codex, faction pack, errata, app update and points authority for implementation/support checks | Check the selected slice just in time. Record exact source, version/date and locator. A conflict remains unresolved and unsupported until reconciled. The app is a manual reference; no public bulk rules API has been identified. |
| [40k.app Space Marines](https://www.40k.app/factions/space-marines) | Historical discrepancy evidence only | Four sampled Marine sheets have material mismatches against the current e11 reference. Unofficial; no documented public data/API license located. Do not use as catalog input, runtime data, or a completeness check. |
| [Games Workshop downloads](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/) | Authoritative faction packs, FAQs/errata, points and matched-play updates | Record the exact document title, version/effective date, page or section, and file checksum for each checked item. |
| [GW September 2026 Astartes update](https://www.warhammer-community.com/en-gb/articles/rylbvfnv/warhammer-40000-balance-update-emboldened-astartes/) | Flags the new Codex-era movement, Toughness and weapon-profile changes that affect Astartes factions | The article is a change summary, not a substitute for the current datasheet or faction pack. |
| [40kdc-data](https://github.com/wn-mitch/40kdc-data), snapshot pinned at `709ecd9f5bb6c06b7446eda6a6a0eae6b921a1c8` | Previously recorded schema/discovery evidence | Community-authored, snapshot retrieved 15 October 2026 and tagged `launch` / `pre-launch-provisional`. Its migration strategy does not certify current Marine rules. Keep outside the canonical rules catalog; schema concepts may inform project-owned structures after license review. |

Do not identify a rule revision solely by “11th edition”, display name, or a provider's app version. Wahapedia's live Marine page lists App 2.8.1 (October 2026), aligned by version number with the official app release observed on that date; this is a freshness signal, not an official faction-pack revision. Give each official source document its own identity. When Codex, a chapter pack, errata, points and the app disagree, record the conflict and hold the affected item out of enforced play until resolved.

### Retrieval and update pass

1. Bulk-fetch the e11 faction candidate set from OpenHammer in a fresh ignored local snapshot. Record the provider revision if available, retrieval timestamp, paginated request URLs and content digests. Keep imported records provisional and retain provider IDs.
2. Reconcile identities and source boundaries in batches using direct e11 faction/datasheet pages. Keep shared Codex, chapter, Legends, Forge World and expansion entries distinct. Counts such as 85 shared Codex sheets, 191 Astartes keyword matches and 132 API Space Marines records have different boundaries; do not force them to match.
3. Select one coherent vertical slice. For that slice, check current Wahapedia rule text plus the applicable GW Codex/faction pack/errata/app points source before implementation or a support claim. Keep unresolved conflicts provisional/unsupported and continue independent catalog or engine work.
4. Preserve concise project-authored mechanics and source locators; do not copy bulk ability prose into the distributed project. Never infer base geometry or army legality from imported fields.

The current identity list has 67 partial candidates and is not the 85-sheet shared Codex manifest. GW's 85-sheet announcement and Wahapedia's 191 broad Astartes keyword total refer to different scopes. Use the API snapshot to expand candidates quickly, then resolve source-book identity in batches; do not fill the numeric gap by guessing.

The Wahapedia “no supplements” view still exposes a Deathwatch app book/detachment and a Boarding Actions expansion explicitly marked 10th edition. Treat the label as a filter/view name only. Every candidate still needs its own book marker and game-mode classification; do not infer shared Codex membership from its presence on that page.

The GW article states that Codex: Space Marines was impending and describes changes to Astartes characteristics and weapon options. Therefore, historical 10th-edition profiles and launch-tagged community records must not be promoted by matching names alone. Check the current profile and every later amendment individually.

### Fixed-profile migration snapshot (18 October 2026)

The [six-profile reconciliation increment](space-marines-fixed-profile-audit.md) records a fresh reference comparison, the remaining official source gates, and a Captain/Lieutenant keyword repair in reference profile v3. Roster preparation still cannot grant full-match certification. This increment does not admit additional datasheets.

The original fixed Marine profile pass is recorded in [profile reconciliation](space-marines-profile-reconciliation.json). Roboute Guilliman is now selectable through the consolidated local catalog at the extracted 415-point cost; his profile, source identity, weapons, keywords, composition and cost pass the bounded Wahapedia comparison. His rules are covered by the local checks recorded in [the Guilliman implementation note](space-marines-profile-records.md#marine-guilliman). Historical official cross-check notes below are context only and do not override the source policy.

The six fixed Marine reference profiles are now loaded by the experimental materializer from `scripts/edition_11/current_reference_marine_profiles.gd`. The profile identifier and digest enter the match content hash. This corrects the known mismatch where the fixed-profile runtime combined MFM 1.6 prices with historical starter-pack combat profiles. The mixed-core training path still uses the historical pack, and other data-pack profiles remain outside this migration. Checked-roster and source-certification flags remain blocked until current Wahapedia effects and applicability are reconciled, as described in the source policy.

## Initial inventory evidence

The ignored local starter snapshot contains **196 Adeptus Astartes unit records**, **313 unique referenced rule IDs**, **520 linked ability-definition entries**, and **one provisional unit record**. It also has **36 records without base geometry**. These figures describe the pinned discovery snapshot only; linked definitions can be duplicated between units and are community interpretations, not 520 unique or official rules.

The snapshot manifest says `reference-only`, identifies upstream revision `709ecd9f5bb6c06b7446eda6a6a0eae6b921a1c8`, and reports a 15 October 2026 retrieval. Most unit records are labeled `launch`; one is `pre-launch-provisional`. The snapshot is ignored by Git and must stay that way unless a separate licensing decision supports redistribution. It can help find omissions, but cannot certify a datasheet, points value, wargear option, base size or ability.

### OpenHammer 11e discovery pass (17 October 2026)

Direct read-only calls to `/v1/11e/stats` and `/v1/11e/units?faction=Space%20Marines&limit=500&offset=0&sort_by=name` returned **1,348 total records / 35 factions** and **132 records in Space Marines**, respectively. The current OpenHammer GitHub README instead claims 1,368 11e records, so its published summary and live service disagree. The API response does not expose an upstream data commit or per-record official publication date; record the request date and response digest when refreshing. The local planner cache from 16 October still has 1,348 records and is a day older than this check.

The 16 October cache has these Astartes-labeled faction buckets. Chapter buckets may overlap the shared catalog by unit name or represent chapter-specific datasheets; do not add them into a unique-unit total without an ID/source reconciliation.

For offline work, `tools/index_openhammer_candidates.py` writes an ignored local identity index from this cache, preserving provider IDs and marking every row unplayable. It intentionally does not fill missing stats, weapons, or abilities. The index is a work queue only; refresh the army-builder cache or run the full importer before using it as a current provider snapshot.

| OpenHammer faction bucket | Cached records (16 Oct) |
|---|---:|
| Space Marines | 132 |
| Black Templars | 20 |
| Blood Angels | 27 |
| Dark Angels | 19 |
| Deathwatch | 14 |
| Space Wolves | 43 |
| Ultramarines | 16 |
| Imperial Fists | 3 |
| Iron Hands | 2 |
| Raven Guard | 2 |
| Salamanders | 2 |
| White Scars | 2 |

These are provider-record counts for discovery, not counts of current unique, official or playable datasheets. They are higher than the 196-unit 40kdc starter snapshot because the providers group and identify chapter data differently. Catalog identity must retain provider + source ID + chapter/revision rather than merging by name.

The 17 October live response was compared with the current e11 reference for the six fixed Marine profiles. It shows why a field-level cross-check is necessary:

| Profile | OpenHammer live candidate | Current e11 reference / official current price | Finding |
|---|---|---|---|
| Intercessor Squad | T4; 4–2 model bounds; 80 points; bolt rifle S4; `Objective Secured` and `Hail of Bolts` | T5; 5–10; 85 points for five; two current bolt-rifle modes at S5/S6; `Bolter Discipline` and `Tactical Mainstay` | Profile, composition, points and abilities are stale; composition bounds are inverted. |
| Assault Intercessor Squad | T4; 4–9; 75 points; chainsword S4; `Shock Assault` | T5; 5–10; 85 points for five; chainsword S5; `Targeted Intercession` | Profile, minimum size, price and ability are stale. |
| Heavy Intercessor Squad | T6; 1–1 bounds; 100 points; six-model variant | T6; 5–10; 115 points for five | Characteristic/weapon direction is partly current, while composition and point variants are stale or invalid for this datasheet. Its ability is summarized using old 10e-style damage-1 wording, not the current e11 save-roll effect. |
| Terminator Squad | T5; 1–1 bounds; 160 points; storm bolter S4/AP0; `Fury of the First` uses Oath of Moment | T6; 5–10; 190 points for five; storm bolter S5/AP-1; `Fury of the First` gives +1 AP to attacks against targets within 9 inches | Profile, composition, points, weapon and ability are stale. Its Teleport Homer text also differs from current e11 placement and CP wording. |
| Captain | T4; 80 points; older bolt-weapon values; Leader pairing set | T5; 90 points; current weapon profiles; current ordinary Captain Leader pairings | Profile, points, weapons and pairing list require replacement from current sources; API omits current army ability effects. |
| Lieutenant | T4; 45 points; older weapon values; class label is Support | T5; 50 points; current fixed profile and Support ability | Characteristics, default loadout and cost are now mapped from the local Wahapedia sheet; alternate weapon choices still need runtime admission. |

The API is now the fast candidate-ingestion source, but these six records are still not safe as playable values. Preserve each provider ID and import the fields into a provisional, reviewable snapshot; do not copy unverified values into the enforced match pack. Promote a selected slice only after checking its current source and official points/update applicability.

### Source-surface census (17 October 2026)

The current Wahapedia Space Marines reference identifies App 2.8.1 (October 2026) for the shared book and chapter apps, and its datasheet index reports **191 datasheets carrying ADEPTUS ASTARTES**. GW announced **85 datasheets in Codex: Space Marines**. Those counts have different boundaries: the larger reference index includes chapter books and other selectable records, while the Codex figure is the shared Codex book. Neither count alone means “191 current matched-play units” or “85 total playable Astartes sheets.” Keep each record attached to its source book, game mode and matched-play status.

| Source surface | Observed scope | Catalog treatment |
|---|---|---|
| Codex: Space Marines | GW announced 85 datasheets and 15 detachments | Core shared book. Make one source record for each sheet, rule and legal option, then reconcile with current errata and MFM. |
| Space Marines and chapter app books | The e11 reference lists Space Marines, Ultramarines, Black Templars, Deathwatch, Dark Angels, Blood Angels, Space Wolves, Salamanders, White Scars, Raven Guard, Imperial Fists and Iron Hands at App 2.8.1 / October 2026 | Track each chapter's additions, replacements, restrictions and inherited shared rules separately. Do not merge identical names without checking source identity and mechanics. |
| 11e faction packs and current downloads | The downloads hub reports an update on 14 October 2026 and links the live MFM; the publicly indexed Space Marines Faction Pack v1.0 is legal 20 June 2026, before the September Codex previews. The live MFM page returned 403 in this automated check, while indexed MFM search results expose an older launch-era snapshot. | Treat the June pack and indexed MFM snapshot as dated launch evidence. Read current costs/dispositions from the live MFM and verify Codex rules against applicable current errata before certification. |
| Legends, Boarding Actions and other selectable sheets | Present in the consolidated index alongside standard faction content | Keep optional or mode-specific and mark legality explicitly; never include them in standard matched play by default. |
| OpenHammer shared bucket | Live API returns 132 records tagged Space Marines | Discovery identifiers only. It does not match the 85-sheet Codex scope or 191-sheet consolidated keyword scope, and field checks show stale 10e-era content. |
| 40kdc-data | Schema layer plus community-authored structured mechanics; `main` is described as migrating to e11 | Schema ideas are useful for our data contract. The migration document's `pre-launch-provisional` path can identify review work but cannot supply current-rule certification; complete current Space Marine coverage was not confirmed in this pass. |

The apparent 85-vs-191-vs-132 difference is a source-boundary issue, not evidence that one number should be “fixed” to another. A canonical catalog should carry a compound identity such as `(publisher, book/source, source record ID, edition, mode, revision)` and a separate current matched-play eligibility state. Chapter-specific OpenHammer buckets should remain aliases/candidate links until reconciled; do not add the cached 20/27/19/etc. chapter counts to 132 as a unique datasheet total.

The 17 October identity pass now contains **67 name candidates** transcribed from Wahapedia's `no-supplements` view into the machine-readable [rules ledger](space-marines-rules-ledger.json). The original 48 cover 21 infantry characters, 2 mounted characters, 3 Battleline units, 3 dedicated transports and 19 infantry units; six overlap the already-audited fixed Marine types. A second pass adds 19 identities from mounted, vehicle, walker, artillery and transport category lists, including the Outrider Squad, Invader ATV, current Speeder/Gladiator variants, Dreadnoughts, Firestrike Servo-turrets and Land Raider/Repulsor variants. This remains a partial identity index, not the shared-book 85-identity catalog: the index mixes books, truncates lists, and its keyword counts ignore the active filter. Every row remains a candidate until its Wahapedia source-book identity and current scope are checked individually.

The official evidence available in this pass includes GW's Codex preview and selected first-look articles, plus the current downloads index. Those articles establish the new rule direction and some example effects, but they do not reproduce the full 85 datasheets, 15 detachments, options and interactions. On 17 October the official downloads hub reported its Munitorum Field Manual updated 14 October and linked the live Space Marines page, but automated retrieval of that live page returned 403. Search-indexed faction MFM pages are marked crawled about three months earlier and expose launch-era v1.0 tables; do not treat their values as current Codex-era confirmation. The public downloads search in this check found no post-Codex Space Marines faction-pack PDF or full Codex errata locator. The 11e Wahapedia pages currently expose consolidated details and remain the practical transcription/checklist reference, but source-level certification still needs a precise official book/errata locator for each rule. Where that official locator cannot be obtained or resolved, keep the rule `candidate` or `source_checked` with the unresolved source boundary recorded; do not mark it fully validated.

GW's 11 September shared-detachment preview confirms the 15-detachment Codex structure, the 3DP Gladius cost, the 1DP Brethren costs and their `Unique: Doctrines` restriction, and publishes selected Gravis stratagem and enhancement text. Its Combat Doctrines preview establishes the new army rule direction, while the datasheet preview publishes selected current profiles. The 15 September Blood Angels/Dark Angels, 16 September Space Wolves/Black Templars/Deathwatch, and 17 September Codex-compliant Chapter articles similarly publish selected detachment mechanics and army legality notes. These previews give useful rule-level official anchors for the marked examples; they still do not certify every card or current app/MFM field in the ledger.

The current 11e faction reference lists shared Space Marines and separate chapter app books at version 2.8.1 for October 2026. GW's 30 September 2026 article previewed changes associated with the then-upcoming Codex; the current consolidated pages now reflect October app content. The GW download page remains the place to resolve published pack/errata boundaries. This means the existing reference snapshot and current implementation need a source-by-source reconciliation before any broad Marine support claim.

GW's [September Codex preview](https://www.warhammer-community.com/en-gb/articles/jfqdowqw/behold-the-most-impressive-codex-space-marines-yet/) describes **85 Codex datasheets and 15 Codex detachments**. Its [chapter update articles](https://www.warhammer-community.com/en-gb/articles/voakmnny/space-marines-detachments-blood-angels-and-dark-angels/) say that Black Templars, Blood Angels, Dark Angels, Deathwatch and Space Wolves receive broader unit/detachment updates, while the more Codex-compliant chapters receive specialist detachment updates. These figures establish a minimum catalog surface, not a count of all playable Astartes content: separate chapter datasheets, app-only revisions, Forge World and Legends records need their own rows. The ledger records the 15 shared Codex detachments plus 20 chapter detachment candidates from the current consolidated e11 reference. It now captures each chapter candidate's detachment-rule heading as an inventory key; effects and card sets still need transcription. The public GW downloads hub says the live MFM was updated 14 October, but the linked live page returned 403 to automated retrieval. The official 20 June launch pack/search-indexed MFM still reports Angelic Inheritors at 3 DP; that predates the official 15 September preview, which says the Codex-era detachment is 2 DP. Wahapedia's October App 2.8.1 page reports 3 DP and two dispositions; 40k.app also shows 3 DP but only Priority Assets. This reveals an additional third-party disposition mismatch. Since we could not capture the live MFM value or a public Codex errata locator, neither cost nor disposition is certified for roster validation. Full rule, restriction, enhancement, stratagem inventories and official disposition locators remain pending.

A separate four-sheet 40k.app comparison found stale Intercessor, Assault Intercessor, Heavy Intercessor and Terminator profiles, including outdated points and ability effects. The [ledger's comparison record](space-marines-rules-ledger.json) captures the fields and current-reference values; do not use those provider records to populate this catalog or runtime until independently reconciled.

The detachment candidate ledger is a source inventory, not a playable catalog. Its chapter count must not be treated as complete: Codex/divergent chapter packs can contain additional or superseded detachments, and Grey Knights are outside the Space Marines scope even though GW's faction-pack download article lists them alongside Space Marines. Preserve source book and effective revision on every candidate.

The ledger has a detailed first pass for all 20 listed chapter detachments and all 15 shared Codex detachments. The chapter records capture detachment rules, chapter/army restrictions, 61 enhancements and 94 stratagems; the shared Codex records capture 32 enhancements and 48 stratagems. Each enhancement/stratagem has a concise eligibility, timing, target or effect summary. This is current-reference inventory, not a gameplay support claim. The three Stormlance stratagems now have runtime paths with focused local checks; obstacle/crowded-base coverage for Wind-Swift remains pending. Supercharged Engines and Auspex Triangulation Shrines now have catalog, admission, and match effects implemented against the local export with focused local checks passed, including one target per bearer per Shooting phase and the spotted mark persistence. Other catalogued effects remain unimplemented. Network validation is deferred to final integration. Deathwatch Support has extra army-legality conditions, including the 500-point allies cap, Warlord restriction and Kill Team enhancement restriction. Full current-rule and interaction review remains pending.

## Historical fixed-profile comparison

The six-profile comparison and price table from the earlier fixed-roster workflow are omitted from this current catalog because their MFM and official-locator requirements were superseded by the 18 October source decision. The old roster and its MFM 1.6 values remain historical context in [roster validation](rules/roster-validation.md); they do not govern new construction. Wahapedia `/wh40k11ed/` and the consolidated local runtime catalog define current profile and point facts. A separate Games Workshop locator is not an admission prerequisite. Current implementation scope is recorded in the [consolidated profile ledger](space-marines-profile-records.md) and [support matrix](project/support-matrix.md).

## Catalog record

Create one record per independently versioned rule or profile, linked by stable internal IDs. A datasheet record should point to its weapon profiles and abilities; an ability record should point back to each datasheet that grants it. Do not merge records by display name.

```yaml
id: space-marines/<stable-id>
kind: datasheet | weapon | ability | army_rule | detachment | enhancement | stratagem | composition
edition: 11
faction_pack: space-marines
chapter: codex-compliant | ultramarines | black-templars | ...
status: candidate | source_checked | structured | implemented | scope_validated
sources:
  - publisher: Games Workshop
    document: <exact title and version>
    location: <page, section or datasheet>
    effective_date: YYYY-MM-DD
    url: <official URL>
  - publisher: Wahapedia
    location: <page and section>
    observed_update: <page version/date>
    url: <e11 URL>
supersedes: []
provider_refs: []
mechanics:
  timing: <phase/window/trigger>
  eligibility: <who and under what state>
  target: <targeting constraints>
  choices: []
  cost: <CP, once-per-X, resource, or none>
  effect: <concise original structured summary>
  duration: <end condition>
  interactions: []
validation:
  characteristics_checked: false
  options_checked: false
  interactions_checked: false
  geometry_checked: false
  implementation_scope: <specific match scope, or none>
notes: []
```

The status is per record, not per faction. `implemented` means an effect handler exists; it does not mean current-source verification or complete army legality. `scope_validated` requires the source revision, legal options, timing, interactions and matching implementation behavior to be checked together. A network match also needs both peers to agree on the same rules-pack and manifest hashes.

## Inventory work queue

| Slice | To catalog | Current state |
|---|---|---|
| Shared faction layer | Combat Doctrines, shared keywords/core ability links, chapter exclusivity, common deployment and transport rules | Partial implementation for one checked match; complete current source audit pending |
| Shared datasheets | Every current shared datasheet, composition, profile, base, loadout option and points entry | All 85 shared-book identities and linked source records are imported into a structurally validated local catalog and selectable through the consolidated local catalog. Five historical profiles remain excluded |
| Chapter datasheets | Chapter-specific characters, units and replacements to shared datasheets | Discovery references exist; current pack boundaries and override/replace links pending |
| Abilities | Each datasheet ability plus shared rules; timing, target, choices, effect, duration, limits and interactions | Structured definitions cover Combat Doctrines, attachment roles and named datasheet abilities, including [Company Heroes](space-marines-profile-records.md#marine-company-heroes), [Outrider Squad](space-marines-profile-records.md#marine-outrider-squad), [Gladiator Reaper](space-marines-profile-records.md#marine-gladiator-reaper), [Gladiator Valiant](space-marines-profile-records.md#marine-gladiator-valiant), [Gladiator Lancer](space-marines-profile-records.md#marine-gladiator-lancer), [Storm Speeder Hammerstrike](space-marines-profile-records.md#marine-storm-speeder-hammerstrike), [Storm Speeder Hailstrike](space-marines-profile-records.md#marine-storm-speeder-hailstrike) and [Storm Speeder Thunderstrike](space-marines-profile-records.md#marine-storm-speeder-thunderstrike). Each current runtime admission remains bounded by its own increment record. The definition pack is not a faction-completeness claim. |
| Weapons and wargear | Every ranged/melee profile, alternate fire mode, replacement, model limit, keyword and cost | OpenHammer snapshot is a provisional bulk baseline; current source and option legality checks are required for each implemented slice |
| Detachments | Eligibility, disposition, detachment points, rule, enhancements and stratagem cards | Combat Doctrines with Gladius Codex Discipline and Stormlance Lightning-fast Strike are executable; Assault Mastery, Death Blow, Codex Fire-patterns, Wrath of the Chapter, Walking Fortress, Dutiful Tenacity, the three Stormlance stratagems and two Stormlance enhancements pass focused local checks; Spearpoint's charge-after-Advance/Fall Back rule, Suboden Khan's conditional end-Fight move, all six Spearpoint stratagems and all four Spearpoint enhancements pass focused local checks; Tactical Mastery and all three Tactical Brethren stratagems and both enhancements pass focused local checks; Devastator Mastery and all three Devastator Brethren stratagems and both enhancements pass focused local checks; Ironclad Champions Enduring Vengeance, all three stratagems and both enhancements pass focused local checks; all three Assault Brethren stratagems and both enhancements have local runtime paths and pass focused checks; Vanguard Ambushers from local Wahapedia row `000011195` has a runtime path pending local validation; network validation is deferred and full army legality remains uncertified; all four Gladius enhancements and Armour of Contempt pass focused local checks; Spearpoint Mobile terrain/charge interactions, Wind-Swift obstacle/crowded-base cases, other detachment rules/cards and full current Marine coverage remain pending |
| Army construction | Faction/chapter restrictions, epic heroes, duplicate limits, attached units, wargear, points and matched-play exceptions | All 85 shared-book Marine identities are selectable from the consolidated local runtime catalog, with sizes and prices bounded by each increment; this is not a general Marine legality claim |
| Optional datasheets | Forge World/Legends and other explicitly non-standard profiles | Scope is separate and not yet inventoried |

### First implementation gate

Do not implement the entire catalog in one large patch. First finish the source inventory and mark the exact current profiles/rules for a bounded slice. Then implement shared rule primitives once (windows, eligibility, target, choice, cost, duration and modifier scope), and bring in Marine rule families with explicit interactions. Keep each unfinished ability visible as unsupported and reject a roster that needs it. Add a faction-level support claim only after every required record in that declared scope reaches `scope_validated`.

The initial expansion slice should be selected only after the source census identifies the applicable Codex/chapter pack, latest official downloads, matched-play points and all prerequisites. Then catalog a coherent set (for example, one datasheet family plus its weapons, abilities and attachment rules), implement shared effect primitives once, and validate the slice end to end. The existing fixed match stays a separately declared scope until its own profile and interaction audit is complete; new catalog candidates do not silently broaden it.

### First structured rule-definition slice

[The machine-readable definition file](space-marines-rule-definitions.json) defines Combat Doctrines and the abilities, Deep Strike dependency, and Leader/Support roles used by the six fixed Space Marine profiles. That historical pass added definition records for Bladeguard, Hellblaster, Infernus, Company Heroes, Redemptor Dreadnought, Apothecary Biologis, Desolation, Eliminator, Eradicator and Incursor abilities, plus Hidden/Detection Range and related core rules. Since then, several of those sheets, including Company Heroes, entered runtime and local construction; each admission remains bounded by its own audit. Each record keeps timing, eligibility, target, duration, limits, interactions and Wahapedia e11 source links. This remains a design/audit artifact, not runtime data or official certification; exact current GW Codex/core/errata locators and unresolved interactions remain pending.

## Current source links

- [Wahapedia: Space Marines faction page (e11)](https://wahapedia.ru/wh40k11ed/factions/space-marines/)
- [Wahapedia: consolidated Space Marines datasheet index (e11)](https://wahapedia.ru/wh40k11ed/factions/space-marines/datasheets.html)
- [Wahapedia: Space Marines without chapter supplements (e11)](https://wahapedia.ru/wh40k11ed/factions/space-marines/no-supplements)
- [Wahapedia: core rules (e11)](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/)
- [GW: Space Marines faction packs announced](https://www.warhammer-community.com/en-gb/articles/2ekfivpk/new40k-download-new-space-marine-faction-packs-today/)
- [GW: current Codex scope (85 datasheets)](https://www.warhammer-community.com/en-gb/articles/jfqdowqw/behold-the-most-impressive-codex-space-marines-yet/)
- [GW: preview of 15 Codex detachments](https://www.warhammer-community.com/en-gb/articles/zcobdkzh/your-first-look-at-15-new-space-marine-detachments/)
- [OpenHammer API repository and data-source notes](https://github.com/EshanPrakash/openhammer-api)
- [GW: 30 September 2026 Astartes balance update](https://www.warhammer-community.com/en-gb/articles/rylbvfnv/warhammer-40000-balance-update-emboldened-astartes/)
- [GW: current downloads hub](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/)
- [GW: first look at Space Marines datasheets](https://www.warhammer-community.com/en-gb/articles/paxsnmde/first-look-space-marines-datasheets/)
- [GW: Space Marines rules first look](https://www.warhammer-community.com/en-gb/articles/ifgezlgu/space-marines-rules-first-look/)

### Source conflicts caught in the definition pass

- The [Tactical Squad page](https://www.wahapedia.ru/wh40k11ed/factions/space-marines/Tactical-Squad) carries an 11th-edition faction-pack marker but displays T4, Strength 4 boltguns and Oath of Moment as the army rule. Those fields conflict with the current shared Space Marines reference. Tactical Squad abilities are held out until reconciled to the current official Codex or errata.
- The Sternguard page found during discovery is a Black Templars variant, not the shared Codex datasheet. Its chapter-specific rules are excluded from this shared slice.
- Bladeguard, Hellblaster and Infernus are transcribed from their current e11 Wahapedia datasheets only. No exact matching current GW ability-text locator has been attached, so these records remain uncertified and definition-only.

Second structured definition slice, 17 October 2026: the current e11 reference adds Company Heroes (Raise the Banner and Command Squad), Redemptor Dreadnought (Duty Eternal), and Apothecary Biologis (Vivispectral Analysis Targeting). Core objective persistence and Lethal Hits are also recorded as dependencies. The abilities are transcribed for future rules-engine work; no new unit profiles, loadouts or points are admitted to the runtime.
Third structured definition slice, 17 October 2026: current shared e11 pages add Targeter Optics (Desolation), Total Obliteration (the current Eradicator Squad with Melta Rifles profile), two Eliminator abilities, and both Incursor abilities. Hidden/Detection Range is recorded as a core dependency. The older Eradicator Squad result marked Faction Pack v1.2 retains Oath of Moment and older profiles; it is excluded. Haywire Mine is current on the general Incursor sheet, but the Pilum Strike Team Boarding Actions adaptation explicitly removes it in that game format.
Fourth structured definition slice, 17 October 2026: Reiver Squad adds Terror Troops, Fearsome Assault, Grapnel Launchers and Grav-chutes. Grav-chutes conditionally grant Deep Strike; Grapnel Launchers are conditional wargear. These remain current-reference definitions until selected for implementation and checked against applicable GW updates.
Fifth structured definition slice, 17 October 2026: current e11 pages add Overlapping Destruction (Eradicator Squad with Heavy Bolters), Meteoric Descent and Parabolic Jetleap (Inceptor Squad), Hammer of Wrath (Assault Intercessors With Jump Packs), and Flexible Asset (Scout Squad). Core Blast, Infiltrators, and Scouts/Scout Move are now represented as shared dependencies. These records were definition-only at that stage; Scout Squad has since entered the runtime and local construction catalog in the 19 October increment.
Sixth structured definition slice, 17 October 2026: current e11 Wahapedia pages add Close-quarters Firestorm (Aggressor Squad), Omni-scramblers and Helix Gauntlet (Infiltrator Squad), and the core Healing or Regaining Lost Wounds procedure used by Helix Gauntlet. Infiltrator Squad is linked to the core Infiltrators ability. At that time these were definition-only. Aggressor and Infiltrator profiles and selected abilities have since entered the runtime; the remaining records retain their individual pending status.

Seventh structured definition slice, 17 October 2026: Vanguard Veteran Squad With Jump Packs adds Vanguard Assault and Combat Shield, with its Deep Strike core link. Ballistus Dreadnought adds Ballistus Strike plus the parameterized core rules Sustained Hits, Damaged and Deadly Demise. Both sheets remain definition-only.
