# Desolation Squad

This audit closes the **shared-book local scope** for Desolation Squad in the common Space Marines book. It uses the [11th-edition Wahapedia datasheet](https://wahapedia.ru/wh40k11ed/factions/space-marines/Desolation-Squad), the [Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/), and the verified local Data Export recorded with hashes in the [machine audit](marine-desolation-squad-audit.json).

## Source profile and choices

The unit has one Sergeant and four Desolation Marines. All five models use a 32 mm base and have M6, T5, Sv3+, W2, Ld6+, OC1. The unit costs 140 points for each of the first two copies and 150 for each third-plus copy in the source. Each model starts with a Bolt Pistol, Castellan Launcher, Ceramite Fists and Superfrag Rocket Launcher.

Every model may replace its Superfrag Rocket Launcher with a Superkrak Rocket Launcher. The Sergeant may replace either rocket launcher with a Vengor Launcher for 5 points. The local profile retains all source weapon profiles and cost tiers. Current roster admission is for 1000-point Incursion, so the non-BATTLELINE sheet is capped at two copies; Strike Force admission and its third-plus selection are outside this supported mode.

The profile keeps the shared keywords `INFANTRY`, `EXPLOSIVES`, `IMPERIUM`, `TACTICUS` and `ADEPTUS ASTARTES`. Chapter-specific context is not added to the generic profile.

## Rules covered

Targeter Optics grants Ignores Cover to ranged attacks against a visible enemy unit. The test checks a visible target and the Vengor attack path through the attack planner.

The Vengor's Indirect Fire path checks hidden-target selection, cover for an indirect attack, hit re-roll restrictions, the 1–5 failure band for a moving unit, the stationary 1–3 band when a friendly model can see the target, and the post-shot action restriction. Each rocket choice is reversible and Sergeant-only access to the Vengor is enforced.

The source lists four Leaders: Captain, Chief Librarian Tigurius, Librarian and Techmarine. It lists Ancient, Apothecary, Lieutenant and Sanguinary Priest as Supports; the Sanguinary Priest comes from a Chapter book and is outside the shared-book catalog. The common-book relation suite exercises all 153 Leader/Support links.

## Local evidence

The focused offline command passed **4/4 processes** on 28 October 2026:

```powershell
python tools/verify.py --godot C:\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_desolation_squad --only test_space_marine_leader_links --timeout 300
```

Both player rosters use the consolidated Space Marines catalog. Network validation was not run and the optional historical starter was not staged. The [machine audit](marine-desolation-squad-audit.json) records the source revision, local snapshot, file hashes, report hash, checks and limits.

This result closes only the source-bounded local datasheet scope. It does not certify full Chapter/faction or army legality, network behavior, complete matches or human playtesting. Network validation remains deferred to final integration.
