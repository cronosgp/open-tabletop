Current status (25 October 2026): all 85 shared-book Marine identities, including Wardens of Ultramar, are selectable from the local Wahapedia e11 catalog after focused profile, rules and admission checks. The Dark Angels App Land Speeder Vengeance runtime profile and Storm of Vengeance path are implemented with checks pending, so the profile is not yet a new construction choice. Network validation remains deferred to final integration; full faction/army legality remains uncertified.


Historical Librarian increment: [Librarian in Phobos Armour](space-marines-profile-records.md#marine-librarian-phobos-armour), sheet `000000119`, adds Scouts 6 pre-battle movement/set-up, Infiltrators, Stealth, Psychic Hood and Soul Sight/Shrouding, alongside its fixed weapon profile. It may Lead admitted Infiltrator or Eliminator Squads. The recorded increment covered 32 shared-book Marine identities, with 26 selectable from the local catalog at that point. Focused local checks passed; final network integration remains deferred.

Historical Phobos batch: [shared equipment, healing and all-model eligibility](space-marines-profile-records.md#marine-phobos-batch) extends the existing mechanisms, adds phase-scoped detection marks and includes alternate equipment in the compatibility digest. Its targeted local checks passed; the full regression run remains pending. Twenty current-price additions supply construction data.

Historical Gravis/Ancient batch: [Gravis Captain and Terminator Ancient](space-marines-profile-records.md#marine-gravis-ancient-batch) add bearer-only damage reduction and objective-conditioned defensive wound context using existing mechanisms. Its targeted local checks passed; the full regression run remains pending. Eighteen current-price additions supply construction data.

Historical Jump Pack batch: [Assault Intercessors With Jump Packs](space-marines-profile-records.md#marine-jump-pack-batch), sheet `000002776`, and [Captain With Jump Pack](space-marines-profile-records.md#marine-jump-pack-captain), sheet `000000083`, are admitted from the local Wahapedia export. The squad has supported 5/10-model options, first/second versus third-plus prices, listed equipment, Deep Strike and post-charge Hammer of Wrath; construction is capped at two copies because it cannot represent the third-plus price tier per copy. The Captain has seven source-legal loadouts, Leader attachment to the admitted Jump Pack squad, Deep Strike, Strategic Acumen, Angel’s Wrath and bearer-only Relic Shield wounds. Local checks cover action and modifier sequencing. The Ancient in Terminator Armour `DEATHWING` context is recorded in keyword-context v48; the v97 comparison has not yet been regenerated.

Historical Vanguard increment: [Vanguard Veteran Squad With Jump Packs](space-marines-profile-records.md#marine-vanguard-veterans-jump-packs), sheet `000000147`, adds 5/10-model formations, both point tiers, source equipment choices, per-model Combat Shield protection, Deep Strike, conditional Relic Blade Lethal Hits and Vanguard Assault. The local check prepares its charge bonus through the actual Fight-phase attack planner. Captain With Jump Pack has the recorded Leader link. Construction is capped at two copies because the catalog does not price third-plus copies independently.

Historical Chaplain increment: [Chaplain With Jump Pack](space-marines-profile-records.md#marine-chaplain-jump-pack), sheet `000000112`, reuses Deep Strike, Leader and Litany of Hate, and implements Exhortation of Rage from the extraction's half-strength condition. It opens an optional free choice to re-roll any attached unit melee Wound die, including successes, only when the unit is at or below half-strength. Local Leader options cover the two admitted Jump Pack bodyguards; source-linked chapter sheets remain outside the current catalog.

Historical Terminator Captain increment: [shared charge decisions](space-marines-profile-records.md#marine-terminator-captain) extends the existing roll window with a free datasheet alternative and separate paid eligibility. Sixteen admitted current-price additions supplied construction data at that stage; construction version advanced to v17 and attack validation to v5 for absent-BS Torrent profiles. Earlier counts below are historical.

Historical Terminator Chaplain increment: [unit prevention grants](space-marines-profile-records.md#marine-terminator-chaplain) adds a shared effective-prevention resolver, source lifetime snapshots and complete attached-unit reserve costs. Fifteen admitted current-price additions supplied construction data at that stage; construction version advanced to v16. Earlier consolidation counts below are historical.

Historical Apothecary increment: [shared healing](space-marines-profile-records.md#marine-apothecary) adds `unit_healing.gd` for budget/priority/preview decisions and `return_placement.gd` for return geometry shared with Necron Reanimation. Fourteen admitted current-price additions supplied construction data at that stage; the 13-record consolidation described below is its historical baseline. Construction version advanced to v15.

Assessment and first consolidation: 18 October 2026. The current incremental approach is useful for discovering rules interactions and providing a checked playable subset. Repeating all per-unit data and control code manually is not the preferred architecture for completing the faction.

## Recommended direction

Use a reviewed declarative catalog for characteristics, formations, weapon profiles, equipment choices, prices, source revision and attachment links. Keep source inventory separate from admission: importing a row or finding points must never make a unit selectable automatically. Explicit supported-scope metadata remains mandatory.

Build reusable mechanisms for recurring effects: characteristic modifiers, conditional protections, objective effects, healing, reaction windows, source lifetime and usage limits. Share the implementation when timing and target semantics match. Preserve dedicated code for distinct mechanics; do not build a general rules language before enough actual examples justify it. Existing Support matching, conditional saves and pre-dice declaration windows are useful examples of reusable pieces.

Validate each admitted sheet against its source records and exercise meaningful combat/selection boundaries. Then validate interactions across units and publish accurate capability metadata. Source comparisons, local tests and network integration establish different things. None alone certifies full army legality.

## Implemented consolidation

Historical status after the Captain With Jump Pack increment: 28 shared-book Marine identities were in runtime and 22 were selectable in the local construction catalog; 57 shared-book identities remained unimplemented. The four-batch run (Gravis/Ancient, Phobos, Jump Pack squad and Jump Pack Captain) passed 13 targeted processes; a five-process follow-up also passed after adding an explicit attachment-eligibility assertion. The complete local regression remains pending, network validation is deferred to final integration and was not run, and this was not full faction or army legality certification.

The 14 admitted Marine additions carrying explicit current prices now supply checked-roster costs and formation prices directly from `current_reference_marine_profiles.gd`. `roster_validation.gd` no longer repeats those numeric records. Character/Battleline flags come from the same profile keywords; Support classification comes from the shared compatibility table.

The 10 older captured reference records remain explicit because their source-reconciliation status differs. A current record cannot silently override an old captured authority: a collision reports an error and blocks construction. A future migration must remove that captured record deliberately after source review.

The profile catalog returns a fresh dictionary. Construction checks the explicit `current_reference` admission flag; Guilliman is now included after his local source profile and abilities passed targeted checks. Regression coverage protects both the publication boundary and his single-copy price entry.

The construction compatibility digest now includes Support links, alongside prices, detachments and other existing data. The construction implementation advances to `incursion-fixed-rosters-mfm1.6-2026-10-18-v14`. Profile characteristics and unit-effect implementation versions remain unchanged because no unit rule or price changed.

Before/after runtime comparison found zero differences across all 23 price records. The same existing `POINTS` read API remains available to exporters, builders and validation. This change does not admit any new datasheet: 19 shared-book Marine identities remain selectable, with 66 still unadmitted.

## Next increments

Continue adding sheets in groups that share mechanics. Add the missing mechanism once, then map each reviewed sheet to it. Extend automated source comparison to all default and optional profiles, keeping unsupported grammar and conditional data explicit. Consolidate repeated source/admission metadata next, rather than replacing the combat engine or rewriting working units wholesale.

Move data into a reviewed generated artifact when its schema and admission boundaries are stable. Raw Wahapedia prose, chapter-specific rows and unresolved export links must not be translated directly into executable effects without review.

Network validation remains deferred to final integration by user instruction. The [validation audit](datasheet-architecture-audit.json) records the local comparison and regression for this consolidation.
