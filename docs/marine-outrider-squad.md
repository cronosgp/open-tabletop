# Outrider Squad — current e11 implementation

Implemented 19 October 2026 from the pinned local Wahapedia Space Marines App export (`000000139`), datasheet `000002712`, revision `2026-10-16T21:03:46+03:00`. The selectable formations contain 3 or 6 models: one Outrider Sergeant and 2–5 Outriders. Costs are 80/160 points for the first two copies and 80/160 for each third-plus size. Each model has M12, T6, Sv3+, W4, Ld6+, OC2 and no invulnerable save.

The fixed loadout is one Heavy Bolt Pistol, Twin Bolt Rifle and Chainsword per model. The Sergeant may replace its Chainsword with a Power Weapon or Thunder Hammer. For every three models, one model may replace its Heavy Bolt Pistol with a Plasma Pistol; this is free and its standard and supercharge profiles retain their separate source traits. The setup choices allow one pistol at 3 models and two at 6 models.

**Full-throttle Assault** applies after the unit made a Charge move this turn. Thunder Hammer melee weapons gain +1 to hit and Sustained Hits 1. Other melee weapons gain +1 Damage and Sustained Hits 1. The ability is applied to weapon copies at attack time, leaving source profiles unchanged. The Thunder Hammer does not also receive the Damage bonus.

The source gives the models 90 × 52 mm oval bases. The prototype stores that source dimension and uses a 90 mm bounding-circle radius as a movement and range proxy; oval-base placement and full geometric legality are not certified. The local leader-attachment rows for Outriders are not enabled by this increment.

`tests/test_outrider_squad_current.gd` checks the local source identity, stats, copy prices, keywords, all seven weapon profiles/traits in the fixed-data comparison, construction and materialization, Sergeant-only melee choices, the Plasma Pistol cap and both charged weapon effects. The fixed-data report also checks the uniform default loadout, 3/6 composition and prices. This increment does not certify full faction or army legality. Network checks remain deferred to final integration.
