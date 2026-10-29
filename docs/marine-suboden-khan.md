# Suboden Khan — shared-book datasheet scope

## Source and provenance

This scope follows the 11th-edition [Wahapedia Suboden Khan datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Suboden-Khan) for Space Marines book 000000139, datasheet 000004167. The live page was checked on 27 October 2026 against the verified local export snapshot 20261021T130623Z, retrieved on 21 October 2026. The snapshot identity, revision, manifest and relevant CSV hashes are recorded in the [machine-readable audit](marine-suboden-khan-audit.json).

The source profile is one 105-point model on a 90 × 52 mm oval base: M12, T6, Sv3+, W8, Ld6+, OC2 and a 4+ invulnerable save. It has no equipment-option rows.

| Weapon | Profile | Source traits |
|---|---|---|
| Heavy Bolt Pistol | 18 in, A1, BS2+, S5, AP-1, D1 | Close-Quarters |
| Onslaught Gatling Cannon | 24 in, A8, BS2+, S5, AP0, D1 | Devastating Wounds |
| Stormtooth | Melee, A6, WS2+, S7, AP-3, D2 | Anti-Monster 4+, Anti-Vehicle 4+, Lance |
| Power Sword | Melee, A3, WS2+, S5, AP-2, D1 | Sustained Hits 1 against targets without MONSTER or VEHICLE; Extra Attacks |

## Implemented scope

All four weapon profiles pass through Equipment and AttackPlan. The sheet suite checks source identity, characteristics, costs and keywords, materializes current Space Marines catalogs for both players, accepts one copy and rejects a duplicate, and validates the source-listed Leader link to Outrider Squad. The shared relation suite covers all common-book Leader/Support links and rejects an unlisted Vehicle target.

The suite also checks Combat Doctrines and Transhuman Strategist, including once-per-round Warlord CP timing. Spear of Chogoris grants Assault to ranged attacks, preserves charge eligibility after Advance, and adds 1 to Advance and Charge rolls while Assault Doctrine is active. Skilled Riders grants Mobile to Suboden and the attached unit.

Stormtooth's Anti-Monster and Anti-Vehicle 4+ become Critical Wounds on qualifying unmodified Wound rolls against the matching target keyword. Its Lance bonus adds 1 to Wound when Suboden's unit made a Charge move this turn. The Power Sword's Sustained Hits 1 applies against non-MONSTER/non-VEHICLE targets; Extra Attacks remains part of its weapon selection.

## Verification and limits

The focused local run passed 7/7 processes: import, Python checks, Suboden's suite and four shared combat/relation regressions. The exact command and results artifact are recorded in the [verification log](verification/verification-results.md). The run reports network=false, legacy_starter_staged=true and no cleanup diagnostics. The fixed-data comparator reports no Suboden profile differences; its global full_match_certified flag remains false because the parent export has unrelated structural validation errors.

This closes only the common-book local datasheet scope. The verification run staged the optional legacy starter pack and does not establish clean-checkout demo behavior. White Scars roster restrictions, Chapter-specific rules, full cross-sheet army legality and network/LAN behavior remain outside this scope; network validation remains deferred to final integration.

The core [Anti-X rule](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) makes qualifying unmodified Wound rolls Critical Wounds against the matching target keyword. The [Lance rule](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/) grants +1 to Wound when the attacking unit made a Charge move this turn.
