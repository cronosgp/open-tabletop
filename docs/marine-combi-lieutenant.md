# Lieutenant with Combi-weapon — local rules admitted

The fixed data baseline was transcribed on 19 October 2026 from the project's pinned Wahapedia 11th-edition extraction: Space Marines App book `000000139`, datasheet `000000076`, export revision `2026-10-16T21:03:46+03:00`. The local extracted tables are the authority for this work.

The admitted profile records one 85-point model on a 40 mm base: M8, T4, Sv3+, W4, Ld6+, OC1. Its fixed equipment is a Combi-weapon (Bolter or Flamer profile) and Paired Combat Blades. The extraction test checks profile characteristics and weapon values/traits against the local sheet.

The local runtime implements the datasheet's Feel No Pain 5+, Infiltrators, Lone Operative, Stealth, Priority Target Identified, and Evade and Survive. The test verifies FNP assignment through the prevention resolver, Lone Operative's 12-inch targeting boundary, standalone detection/cover abilities, visible terrain selection and its temporary detection bonus, and the full D3+3 reactive movement/placement flow. The grounded terrain model uses the existing cylindrical visibility and movement proxies. Focused validation passed 11/11 processes in `.tools/verification/20261019T065023692405Z/results.json`; the 25 Wahapedia import/comparator Python tests also passed. The profile is admitted to the consolidated local construction catalog. Network validation remains deferred to final integration.

Full faction and army legality remain uncertified. The next Space Marines increment should come from the remaining local extracted sheets and undergo the same profile, ability, combat and admission checks.
