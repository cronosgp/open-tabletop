# Reiver Squad — local Wahapedia implementation

Observed 19 October 2026 from the project's local 11th-edition Wahapedia export (book `000000139`, datasheet `000002718`, export timestamp `2026-10-16T21:03:46+03:00`). Wahapedia `/wh40k11ed/` is the sole rules authority for this implementation. The source sheet is [Reiver Squad](https://wahapedia.ru/wh40k11ed/factions/space-marines/Reiver-Squad).

## Runtime scope

- 5 models for 85 points or 10 for 165; one Reiver Sergeant plus four/nine Reivers. Stats: M8, T4, Sv3+, W2, Ld6+, OC1; 32 mm bases.
- Fixed equipment per model: Bolt Carbine (18 inches, A3, BS3+, S5, AP-1, D1; Assault, Precision), Special-issue Bolt Pistol (12 inches, A1, BS3+, S5, AP-2, D1; Close Quarters, Precision), and Monomolecular Combat Knife (A4, WS3+, S5, AP-1, D1; Precision).
- Scouts 6 uses the existing all-model pre-battle move or reserve set-up rules.
- Terror Troops reduces each enemy model's OC by 1 while it is within 3 inches of any living Reiver model. Battle-shock still sets OC to zero.
- Fearsome Assault resolves at the start of the Fight phase, before pile-in. Each unique enemy unit engaged with at least one Reiver unit takes a Battle-shock test with -1 to the roll. A passing test does not clear Battle-shock already in effect.
- Grav-chutes and Grapnel Launchers are optional unit-level equipment. Grav-chutes grant Deep Strike and reserve ingress eligibility while equipped. Grapnel Launchers permit movement paths through models and ignore vertical distance in supported flat-board geometry. Upper-floor movement remains unsupported by the board model.
- Phobos Librarian and Phobos Lieutenant Leader links are admitted; the external Phobos Captain remains excluded.

## Validation boundary

The local focused suite covers the source profile, both model counts and costs, default weapons/traits, Scouts, Leader links, gear-dependent Deep Strike, Grapnel pathing, model-level Terror Troops, Fight-phase Fearsome Assault, its -1 modifier and Battle-shock persistence. The fixed-data comparator is recorded in `.tools/wahapedia-fixed-data-review-v18.json`. Network validation and full local regression remain pending. Full faction/army legality is not certified.
