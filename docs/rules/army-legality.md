# Full 11th-Edition Army Legality Validation (Space Marines & Necrons)

## Provenance and source boundary

Army legality rules in `scripts/edition_11/army_legality.gd` and `scripts/edition_11/detachment_catalog.gd` are derived from the verified local Wahapedia 11th-edition Data Export snapshots and Core Rules Section 25 (*Muster Your Army*):

- **Core Rules reference**: [Wahapedia 11e Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), Section 25 (*Muster Your Army*).
- **Space Marines snapshot**: `20261021T130623Z` (`.tools/wahapedia/11e/space-marines/20261021T130623Z/`).
  - `Datasheets_keywords.csv` SHA-256: `bdb2431dd3a24d34ec91e1aa1e7ddae9da3565faa18a56abcd8ead5247b4e341`
- **Necrons snapshot**: `20261031T053336Z` (`.tools/wahapedia/11e/necrons/20261031T053336Z/`).
  - `Detachments.csv` SHA-256: `d323c5cc7e025ba8c3c004805fedf1adfbf0126305a770e448287d6280b4c536`
  - `Datasheets.csv` SHA-256: `39ce33b9f3031ca127f6e94a5d1039bafa01c93f843008623b54731f397afb9c`
  - `Datasheets_enhancements.csv` SHA-256: `97cd4bf6aac2064a7555dd04a067095e106ff263d57bf13b9d8e79fbe903158f`

Any detachment or faction not implemented in the runtime rules engine fails closed rather than silently substituting unverified rules.

## Enforced 11e Muster Your Army Rules

| Rule | Scope & Enforcement |
|---|---|
| **Battle Size & Points Ceiling** | `incursion` (1,000 pts), `strike_force` (2,000 pts), `onslaught` (3,000 pts), `training` (500 pts), or `custom` (explicit limit). Total points = base/tiered copies + wargear + Enhancements. |
| **Datasheet Repetition Caps** | `incursion`: 2 copies (4 `BATTLELINE` / `DEDICATED TRANSPORT`). `strike_force`: 3 copies (6 `BATTLELINE` / `DEDICATED TRANSPORT`). `onslaught`: 3 copies (6 `BATTLELINE` / `DEDICATED TRANSPORT`). Conditional `BATTLELINE` grants (e.g., Darkflight Pursuit Outriders) apply. |
| **Epic Hero Uniqueness** | At most 1 copy of any datasheet with `EPIC HERO`. |
| **Warlord Eligibility** | At least 1 `CHARACTER` unit that is not restricted by `cannot_be_warlord` (e.g., Murderfang). Conflicting `SUPREME COMMANDER` units (e.g., Roboute Guilliman + Lion El'Jonson) are rejected; a single `SUPREME COMMANDER` (Guilliman, Lion El'Jonson, or The Silent King) must be the Warlord. |
| **Enhancement Caps** | At most **3** Enhancements per army; at most 1 per Character; `EPIC HERO` units cannot take Enhancements; no duplicate Enhancement; Enhancement must belong to the player's declared detachment. |
| **Space Marine Chapter Lock** | At most one Chapter Faction keyword across the roster; Chapter-locked detachments (`wrath-of-the-rock`, `darkflight-pursuit`, `inner-circle-task-force`, `fist-of-the-god-emperor`, `vow-sworn-crusaders`, `spearpoint-task-force`) bar conflicting Chapters. |
| **Detachment Points (DP) Budget** | `incursion`: 2 DP (or 1 single 3 DP detachment exception); `strike_force`: 4 DP; `onslaught`: 6 DP. Multi-detachment DP math is validated; match execution remains single-detachment until multi-detachment runtime rules are implemented. |
| **Support-to-Bodyguard Matching** | Every Support unit (`SupportAttachments.BODYGUARDS` / `CONDITIONAL_BODYGUARDS` for Space Marines and Necron Crypteks) must have an eligible admitted bodyguard slot (allowing the Apothecary + Lieutenant pair). |
| **Dedicated Transport Passenger Check** | List-check verifies enough embarkable non-transport units exist for each `DEDICATED TRANSPORT` copy; pre-deployment formation seal verifies no `DEDICATED TRANSPORT` starts empty. |
| **Reserves Limits (Formation Seal)** | Combined Reserves points ≤ 50% of battle `points_limit`, and non-Deep-Strike Strategic Reserves ≤ 25% of battle `points_limit`. |
| **Warhammer Legends Gate** | `"matched_play"` rejects `source_scope == "Warhammer Legends"`; `"casual_legends"` permits them with an explicit advisory warning. |

## Explicit Scope Boundaries

- **Allies**: Unsupported and blocked at admission (`allow_allies: false`).
- **MFM vs. Wahapedia price variance**: Decimus Kill Team (210 vs MFM 190) and Crusader Squad (160/305 vs MFM 150/290) retain Wahapedia runtime prices and emit non-blocking advisory warnings.
- **Historical MFM 1.6 Presets**: Preserved under `RosterValidation` for backwards compatibility with legacy checked-roster tests; not certified for current-Codex competitive play.
