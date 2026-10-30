# Rhino Primaris (Warhammer Legends) local datasheet audit

**Status (30 October 2026): source-bounded local profile ready for army preparation and the supported match flow.** The verified 11e sheet is admitted at 95 points per one-model copy, up to three copies in Strike Force. Incursion's standard repeat limit permits at most two because the source does not give this sheet the BATTLELINE or DEDICATED TRANSPORT keyword. The profile includes every source weapon, the optional missile, transport restrictions and all four ability rows.

## Source and legality boundary

The profile uses datasheet `000000085` in Wahapedia 11e Space Marines Legends book `000000356`, from local Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`. It was retrieved at `2026-10-30T01:33:48.347556+00:00`; the export revision is `2026-10-28T23:48:19+03:00`. The machine-readable [source/hash audit](marine-rhino-primaris-audit.json) records the parent and slice manifest hashes and all eight source-table checksums. The 56-subject Legends slice audit has zero scoped structural findings; its parent export still contains 68 unrelated findings. A live-page network recheck is deferred to final integration under project policy.

This is a Warhammer Legends unit. The project marks it for home, store, club and campaign play. Competitive-event use needs the organiser's permission, and event-specific points and restrictions need confirmation. The source footprint is `Use model` with no diameter; the match simulation uses a labelled 120 mm circular proxy. Exact physical hull clearance is not certified.

## Represented sheet

- One Rhino Primaris: M12, T9, Sv3+, W10, Ld6+, OC3; no invulnerable save.
- Keywords: ADEPTUS ASTARTES, TRANSPORT, IMPERIUM, SMOKE, VEHICLE and FRAME. It does not gain DEDICATED TRANSPORT.
- Default weapons: Twin Plasma Gun with standard and supercharge profiles, and Armoured Tracks.
- Optional equipment: one Hunter-killer Missile (48", A1, BS2+, S14, AP-3, D3+3 damage, One Shot). It is selected during army preparation and adds no points in this source record.
- Transport: capacity 6 ADEPTUS ASTARTES INFANTRY models; cannot carry JUMP PACK, GRAVIS, CENTURION or TERMINATOR models.
- Abilities: Combat Doctrines; Deadly Demise D3; Self-repair; Orbital Comms Array.

The Primaris profile does not inherit Firing Deck or Veiling Smoke from the ordinary Rhino. It retains the SMOKE keyword for the shared Smoke stratagem. Self-repair restores one lost wound in its owner's Command phase while the Rhino is alive and on the battlefield, capped at 10. Orbital Comms Array rolls separately for each eligible Rhino within 6 inches when a friendly Adeptus Astartes unit is targeted by a supported, implemented stratagem; each 5+ gains 1 CP. Local resolution hooks are connected to the runtime's logged stratagem-use paths. Unsupported stratagems and wider CP restrictions are outside this sheet check.

## Verification and remaining limits

The dedicated offline test checks source provenance, all model and weapon data, first/second/third prices, construction choice, Incursion and Strike Force copy caps, public missile selection, transport capacity/restrictions, ability registration, the 6-inch edge boundary, multiple nearby Rhino rolls, owner/embarkation/destruction gates and Self-repair's wound cap. Its exact command and result are recorded in the [verification history](verification/verification-results.md).

This closes only the Rhino Primaris' declared local sheet scope. It does not certify every cross-datasheet interaction, a complete army list, exact physical clearance, current live-page/event-pack equality, tournament acceptance, network play or human playtesting. Legends status and the 120 mm footprint proxy remain visible in construction.
