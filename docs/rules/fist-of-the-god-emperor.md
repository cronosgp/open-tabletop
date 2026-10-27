# Fist of the God-Emperor

The Fist of the God-Emperor is a **partial** Black Templars detachment in the local training runtime. Select it in the prepared-match detachment field; current-reference Marine rosters must resolve to Black Templars Chapter context.

## Implemented: Oathbound Exemplar

`Oathbound Exemplar` costs 10 points and is available only for Adeptus Astartes Infantry profiles linked to local Data Export row `000011176003`. When its unit is selected to make an Advance or Fall Back move, that move does not by itself prevent the unit from being eligible to start an action.

The exception applies only to the move-type restriction. The action still requires positive Objective Control, an eligible unengaged unit, no Battle-shock restriction, the correct action timing and every other normal gate. It does not allow an action after the unit has shot or remove the army-wide once-per-turn action limit.

The enhancement uses the existing action-eligibility and enhancement-assignment paths. The picker matches the bearer unit against exact source datasheet IDs from `Datasheets_enhancements.csv` and requires the current profile to have `INFANTRY`; the source relation is not expanded to unsourced identities.

## Remaining detachment scope

`Purge and Sanctify`, `Righteous Fervour`, `Doctrinal Flexibility`, `Angels Defiant` and `Avowed Destruction` do not yet have runtime paths. The detachment option is labeled partial and does not imply those effects or full army legality are supported.

## Source and evidence

Rules source: [Space Marines, Wahapedia 11th edition](https://wahapedia.ru/wh40k11ed/factions/space-marines/), App 2.8.1, observed 26 October 2026. Datasheet eligibility comes from the verified local Data Export snapshot `20261021T130623Z`, revision `20260817b`; snapshot identity, retrieval time, filenames and SHA-256 hashes are recorded in the [Space Marines rules ledger](../space-marines-rules-ledger.json).

Focused local checks, Godot review, playtesting and network validation remain pending. This increment is not a rules-certification or full army-legality claim.
