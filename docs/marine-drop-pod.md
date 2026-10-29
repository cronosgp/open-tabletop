# Drop Pod sheet audit

This audit closes the common-book Drop Pod's source-bounded local sheet scope. It does not certify full faction or army legality.

## Source and snapshot

- Authority: [Wahapedia 11th-edition Drop Pod](https://wahapedia.ru/wh40k11ed/factions/space-marines/Drop-Pod); Core Rules timing and copy limits use the [11th-edition Core Rules](https://wahapedia.ru/wh40k11ed/the-rules/core-rules/).
- Book `000000139`, datasheet `000000087`; source page checked 2026-10-27.
- Local export snapshot `20261021T130623Z`, retrieved 2026-10-21 19:46:58 UTC; export revision `20260817b`, export update stamp `2026-10-21 16:06:23 GMT+3`.
- Export manifest SHA-256: `169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf`; Space Marines slice manifest SHA-256: `f11ff7ddce6e12b33abf62426a245711611667a98e13969efa8679bef88c7989`.
- The exact relevant CSV filenames and hashes are recorded in [the master profile evidence](space-marines-profile-evidence.json) and `data/edition_11/space_marines_transport_profiles.json`. Raw exports remain ignored local files.

## Integrated local scope

- One model with M `-`, T7, Sv3+, W8, Ld6+, OC `-`; the runtime's numeric placeholders for M and OC are zero. The datasheet lists no weapons and the six expected keywords: ADEPTUS ASTARTES, DEDICATED TRANSPORT, FRAME, IMPERIUM, TRANSPORT and VEHICLE.
- Transport capacity is 12 ADEPTUS ASTARTES INFANTRY models; GRAVIS, JUMP PACK and TERMINATOR units are excluded. Source ability mapping includes Deep Strike and Deadly Demise 1.
- The source export labels the model geometry `Custom`. The runtime uses an 80 mm circle strictly as a local board proxy, not as a source base measurement.
- Points are 60 for each of the first three Pods and 70 for the fourth and later. Local construction admission checks the source tiers and currently caps the profile at four copies (250 points for four). Category-aware limits are not implemented: the Core Rules permit four Dedicated Transports in Incursion and six in Strike Force, so the local cap is conservative for Strike Force and does not yet admit its fifth and sixth Pods.
- Drop Pod Assault automatically assigns the Pod to Strategic Reserves during preparation, applies the half-army reserve cap, and allows arrival in the owner's first Movement phase. It can also arrive through Rapid Ingress. Arrival compels sequential passenger Rapid Disembark; passengers must be set up more than 8 inches from every enemy. This Rapid Disembark does not make Hazard rolls. Deployment Complete prevents later embarkation after the Pod has been set up.
- The current consolidated Marine catalog materializes the same profile for both players. Tests cover profile identity, characteristics, keywords, loadout, transport restrictions, points, copy admission, Deep Strike, Deadly Demise, reserve cost, ingress, passenger sequencing, distance, saved continuation and phase-close identity.

## Verification

Focused local verification passed 4/4 processes with network validation disabled and no legacy starter staged:

```text
python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_drop_pod --only test_marine_transport_admission --timeout 300
```

Report: `.tools/verification/20261027T110036757480Z/results.json`; SHA-256 `673625518FD3C2032CD86DEF8F2E8002F117A28081423BB1BEE5E312919FE2BC`. The dedicated suite is [test_marine_drop_pod.gd](../tests/test_marine_drop_pod.gd). The report validates this local scope only.

## Open boundaries

- The 80 mm geometry is only a board proxy for the export's `Custom` geometry.
- Local copy admission is capped at four; Strike Force's fifth and sixth Dedicated Transport slots require category-aware admission.
- The Gauntlet Task Force Aggressive Disembarkation interaction is present in the local choice path but still needs focused checks for CP, pass, multi-passenger continuation and save/restore.
- Chapter-book variants, Forge World, Legends, Boarding Actions, other transport interactions, network behavior, full faction/army legality, complete-match certification and human playtesting are not covered by this audit.
