# Company Heroes — current e11 implementation

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000002772`, revision `2026-10-16T21:03:46+03:00`. The sheet uses a fixed four-model composition: Ancient, Company Champion, Company Veteran with Bolt Rifle, and Company Veteran with Heavy Bolter. Each has M6, T5, Sv3+, W4, Ld6+, OC2 and a 40 mm base. The first two units cost 125 points each; a third or later unit costs 145.

The unit materializer keeps the four roles in source order and assigns the source weapons to the appropriate models. The Ancient and Bolt Rifle Veteran carry a Master-crafted Bolt Rifle, Master-crafted Bolt Pistol and Combat Knife; the Champion has a Master-crafted Bolt Pistol and Master-crafted Power Weapon; the Heavy Bolter Veteran has a Master-crafted Bolt Pistol, Master-crafted Heavy Bolter and Combat Knife. Only the Ancient receives the Ancient keyword, and only the Champion receives Champion.

Both current datasheet abilities are enabled:

- **Raise the Banner:** at the end of the controlling player's Movement phase, secure an objective controlled by this unit.
- **Command Squad:** attacks against this unit subtract 1 from Wound rolls. There is no weapon-Strength eligibility condition in the source, and the shared roll-modifier cap still applies.

`tests/test_company_heroes_current.gd` checks the local profile and source identity, all four model roles and weapon assignments, model-scoped keywords, 4-model composition, 125/145 prices, checked-roster admission, both abilities and the Raise the Banner timing. `tests/test_attack_plan.gd` and `tests/test_capabilities.gd` cover adjacent modifier and registry behavior. The fixed-data comparison `.tools/wahapedia-fixed-data-review-v63.json` reports zero numeric/identity differences and all five unique weapon profile/trait checks, default loadout, composition, shared keywords and both source abilities consistent. Its bounded comparison does not itself certify role assignment; the local Company Heroes test covers that mapping.

This is a local source and combat increment, not full army-legality or complete faction certification. Network validation remains deferred to final integration.
