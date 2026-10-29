# Impulsor — source-bounded local scope

This closes the shared-book 11th-edition local datasheet scope for [Impulsor](https://wahapedia.ru/wh40k11ed/factions/space-marines/Impulsor), source book 000000139, datasheet 000002568. The current page and the verified local Wahapedia export snapshot were checked on 28 October 2026. This result does not certify full army legality or network behavior.

## Implemented and checked

- The source lists one Impulsor at 70 points for the first three copies and 80 points for the fourth and later copies. The local profile retains both tiers; the current construction catalog has a three-copy ceiling. Characteristics, keywords and the exact 100 mm circular base are represented.
- Storm Bolters, Armoured Hull, and every source-listed ranged option match their extracted weapon profiles through Equipment and AttackPlan. Army Preparation exposes the four one-of systems, the Storm Bolters-to-Fragstorm replacement, and the optional Ironhail Heavy Stubber. Choices are reversible; Orbital Comms Array adds its 10-point surcharge.
- Orbital Comms Array grants Scouts 6; Shield Dome grants a 5+ invulnerable save. Switching systems removes the prior effect and restores the applicable points cost. Public choices reject wrong-owner and stale selections.
- The transport carries up to seven Adeptus Astartes Infantry models, excludes Terminator and Jump Pack models, and counts each Gravis model as two. Rapid Disembarkation after an Advance, Firing Deck 7 and Deadly Demise D3 are retained in the local rules profile. Shared transport tests check Firing Deck attack planning and the Emergency Disembark to Deadly Demise continuation using a Rhino fixture.
- Both players materialize current-catalog Space Marine units for the local construction and admission checks. The common-book source lists no Impulsor Leader or Support relation.

Focused offline verification passed 11/11 processes at .tools/verification/20261028T065001931427Z/results.json (network disabled; legacy starter not staged; no cleanup diagnostics). See the [machine-readable source and hash audit](marine-impulsor-audit.json).

Verification command:

python tools/verify.py --godot .tools/godot/Godot_v4.7.2-stable_win64_console.exe --profile targeted --only test_marine_impulsor_options --only test_marine_transport_profiles --only test_marine_transport_admission --only test_marine_transport_rules --only test_marine_transport_weapon_options --only test_marine_transport_destruction --only test_marine_firing_deck --only test_marine_conditional_weapon_traits --only test_space_marine_leader_links --timeout 300

## Limits

This closes the Impulsor shared-book local scope only. The three-copy construction ceiling is a local catalog rule and does not establish the complete current-edition army limit. Firing Deck 7 and Deadly Demise D3 are checked as Impulsor profile parameters; shared resolution behavior is exercised through the common transport rules tests. Full faction and army legality, Chapter-book content, network behavior, complete-match certification and human playtesting remain open. Network validation is deferred to final integration.
