# Ravenwing Dark Talon (Dark Angels App)

**Status:** source-bounded local scope passed on 28 October 2026. This closes the fixed profile, checked Stasis Bomb behavior, Aircraft interactions exercised by the paired suites, and local catalog admission. It does not certify complete Dark Angels or Space Marines army legality.

## Source identity

- [Wahapedia 11th-edition Ravenwing Dark Talon](https://wahapedia.ru/wh40k11ed/factions/space-marines/Ravenwing-Dark-Talon), Dark Angels App datasheet `000000240`, book `000000023`.
- The current page was checked on 28 October 2026 against Dark Angels App revision 2.8.1 (October 2026). Fixed facts come from verified local Data Export snapshot `20261021T130623Z`, retrieved `2026-10-21T19:46:58Z`, export revision `20260817b`; source row stamp `2026-10-21 16:06:23 GMT+3`.
- The machine-readable audit records the snapshot hashes and two-sheet scoped slice. Its subjects have no structural validation errors. The parent export has 68 errors outside this slice; those are not claimed as passed. Raw data remains outside Git.

## Profile and weapons

- One model, 190 points, up to three copies in this local catalog. T8, Sv3+, 5+ invulnerable save, W11, Ld6+ and OC0. The source's dash for Movement is preserved as the local Aircraft movement profile.
- The source base is a 120 × 92 mm oval. Runtime placement uses a labelled 60 mm bounding-circle proxy; exact oval-edge distance and placement are outside this scope.
- **Rift Cannon:** 18", D3+1 attacks, BS3+, S16, AP-4, D3, Devastating Wounds and Blast 1.
- The two physical **Hurricane Bolters** each have 24", A6, BS3+, S5, AP-1, D1, Rapid Fire 6 and Twin-linked. Their runtime weapon IDs are distinct so each copy retains an independent attack inventory.
- **Armoured Hull:** A3, WS4+, S6, AP0, D1. The profile preserves ADEPTUS ASTARTES, DARK ANGELS, VEHICLE, AIRCRAFT, RAVENWING, FLY and IMPERIUM.

## Rules in the checked scope

- The paired Nephilim/Dark Talon suite exercises the shared Aircraft reserve and ingress flow, end-of-opponent-turn return, Rapid Ingress exclusion, pass-through movement with endpoint overlap rejection, Charge and Fight restrictions, Aircraft-only engagement movement exception, and the supported non-FLY contact/Surge target filtering.
- **Damaged 3:** -1 to Hit applies at three remaining wounds; the full-health profile is unmodified.
- **Stasis Bomb:** at the end of the opponent's Fight phase, select a visible enemy within 24", excluding AIRCRAFT and Lone Operative. On selection to move before the end of that opponent's next Movement phase, a non-stationary unit rolls one D6. Results 1–4 apply D3 mortal wounds and -2" M; results 5–6 apply 2D3 mortal wounds and -3" M. The tested low result passes through shared mortal-wound allocation and resumes its saved Normal Move; both branches, stationary choice and Movement-phase expiry are checked.
- **Deadly Demise D3** and **Combat Doctrines** are registered with their exported parameters. The paired suite does not trigger this Aircraft's destruction roll or exercise doctrine effects.

## Local verification and limits

The focused command `python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile focused --only test_nephilim_jetfighter --only test_ravenwing_dark_talon --timeout 300` passed **4/4 processes** at `.tools/verification/20261028T130615559370Z/results.json` (SHA-256 `08537FEBF4151D7AB8F7E91638DEEB1DB8E7E05928375BB5F6819A2E761771B2`; `network: false`, no legacy starter staged, no cleanup diagnostics). The Dark Talon suite checks its source-linked fixed profile and weapons, copy cap/admission, Damaged 3, Stasis Bomb target filters, both roll branches, shared allocation and saved-movement continuation.

The check does not exercise Aircraft-specific Deadly Demise triggering, Combat Doctrine effects, Plunging Fire targeting, complete matches, exact oval-base geometry, network behavior, human playtesting or full army legality. Forge World, Legends, Boarding Actions and alternate modes are outside this sheet-specific result; network validation remains deferred to final integration. See the [machine-readable audit](marine-ravenwing-dark-talon-audit.json).
