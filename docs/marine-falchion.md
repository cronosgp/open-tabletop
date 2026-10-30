# Falchion (Warhammer Legends) local datasheet audit

**Status (30 October 2026): source-bounded local profile ready for preparation and play in the supported game flow.** The current-reference catalog admits one Falchion per unit at 420 points for the first, second and third copies, with the normal three-copy ceiling. Its characteristics, all source-listed weapons, all three independent weapon choices and its four datasheet abilities are represented. This is a local sheet-level result; it does not certify every army interaction or tournament acceptance.

## Source and legality boundary

The profile is datasheet `000001666` in Wahapedia 11e Space Marines Legends book `000000356`. It comes from the hash-verified local Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved 30 October 2026. The export revision is `2026-10-28T23:48:19+03:00`; the snapshot manifest SHA-256 is recorded in the [machine-readable audit](marine-falchion-audit.json). Its exact book slice has zero structural findings. The live page was not rechecked over the network in this increment; final network validation remains deferred under the project policy.

The project labels this Legends profile for home, store, club and campaign use. Competitive event use requires the organiser's permission, and any event-specific points or restrictions still need confirmation. The source specifies `Use model` without a footprint diameter. The game uses a labelled 60 mm circular proxy, so exact physical clearance is not certified.

## Represented sheet

- One model: M9, T13, Sv2+, W24, Ld6+, OC8, with no invulnerable save.
- Keywords: ADEPTUS ASTARTES, FRAME, SMOKE, IMPERIUM, TITANIC and VEHICLE.
- Default ranged weapons: two Quad Lascannons, Twin Falchion Volcano Cannon and Twin Heavy Bolter; default melee weapon: Armoured Tracks.
- Independent preparation choices: add one Heavy Bolter, Heavy Flamer, Multi-melta or Storm Bolter; replace both Quad Lascannons with two Laser Destroyers; replace the Twin Heavy Bolter with a Twin Heavy Flamer. All 20 resulting combinations are checked.
- Abilities: Combat Doctrines; Deadly Demise D6+2; Damaged 8; and Titan-killer. Titan-killer adds Devastating Wounds only to the Twin Falchion Volcano Cannon against MONSTER or VEHICLE targets.

All ten source weapon rows and all four ability rows are represented. The local check also covers the source price tiers, three-copy ceiling, public preparation choices, invalid-option rejection, attack modifiers and the D6+2 mortal-wound packet.

## Verification and remaining limits

The dedicated Falchion test passed **3/3 processes** at `.tools/verification/20261030T110317013906Z/results.json` (SHA-256 `401935e223376558498686cc3a60c59d5cb8a2f17687308e3670a108cbde7738`; network disabled, no cleanup diagnostics). The connected catalog, source-field, copy-cost, capability, ability, attack-plan, weapon-selection and Legends vehicle regression passed **14/14 processes** at `.tools/verification/20261030T110346483572Z/results.json` (SHA-256 `63b9eec14a424902d0c18ecfa4927eee2bdad270a1ebcfafd576b7e2a950ca04`; network disabled, no cleanup diagnostics).

The runtime identity export records 179 Space Marine profiles, including 18 separate Legends profiles, with no missing source IDs. The broad Legends source audit covers all 56 identities assigned to book `000000356` and reports zero scoped structural findings; its source-only row count does not certify runtime support. See the audit JSON for snapshot files and hashes, and the [extended Marine inventory](data/space-marine-extended-inventory.md) for the remaining scope.

Full army legality, all cross-datasheet interactions, exact physical clearance, live-page/event-pack validation, competitive-event approval, network behavior and human playtesting remain outside this sheet-level result.
