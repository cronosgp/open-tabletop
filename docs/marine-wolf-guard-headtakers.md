# Wolf Guard Headtakers

## Scope and source

This is a **partial source-bounded local profile** for Space Wolves App datasheet `000004131` in standard Warhammer 40,000 11th edition. Fixed datasheet facts use the verified Wahapedia Data Export snapshot `20261029T072022Z-final-integration`, retrieved 29 October 2026. The parent export manifest SHA-256 is `772952e313b6772022c68226514eba7cdde00464468fd79c8291d20c24da4801`; the structurally valid Headtakers slice manifest SHA-256 is `9779a6e90c1690c19179a7eda8a66498d4cce2c6e953e05d3bcd7a644763fe1e`. The subject slice has zero structural findings. The parent export has 68 unrelated findings; they are not treated as passed. See the [machine-readable source and verification audit](marine-wolf-guard-headtakers-audit.json).

## Admitted compositions and points

The official [Munitorum Field Manual — Space Wolves, v1.0](https://mfm.warhammer-community.com/en/space-wolves), observed 29 October 2026, explicitly maps all four model-count rows. Wahapedia's selected composition requires 3–6 Hunting Wolves **and** 3–6 Wolf Guard Headtakers, so construction admits the two mixed rows and blocks the Headtakers-only rows.

| Composition | Total models | First/second copy | Third-plus copy | Runtime |
|---|---:|---:|---:|---|
| 3 Headtakers + 3 Hunting Wolves | 6 | 115 pts | 125 pts | Admitted |
| 6 Headtakers + 6 Hunting Wolves | 12 | 230 pts | 240 pts | Admitted |
| 3 Headtakers only | 3 | 85 pts | 95 pts | Blocked: fails the selected Wahapedia minimum composition |
| 6 Headtakers only | 6 | 170 pts | 180 pts | Blocked: fails the selected Wahapedia minimum composition |

The MFM resolves the duplicated six-model prices and identifies the exact role mixes. All four exact role-composition rows and both copy tiers are preserved in the runtime profile's `mfm_composition_cost_rows` metadata. Only the priced 3+3 and 6+6 rows match the selected Wahapedia composition and enter construction pricing. Wahapedia allows 3–6 models of each role, but MFM v1.0 has no explicit price row for other role-count combinations; runtime leaves those combinations unpriced and unavailable rather than inferring costs. The MFM-listed 3- and 6-Headtaker-only rows remain recorded as source prices but blocked from construction because they fail the selected Wahapedia composition.

## Integrated local scope

The profile preserves separate model roles. Wolf Guard Headtakers have M7, T5, Sv3+, W3, Ld6+, OC1 and a 40 mm base. Hunting Wolves have M10, T4, Sv6+, W1, Ld8+, OC0 and a source-listed 60 × 35.5 mm oval base. Runtime geometry represents the wolf oval with a labelled 30 mm circular proxy; it is not an exact base shape.

The default Headtaker carries a Heavy Bolt Pistol and paired Master-crafted Power Weapons. Any Headtaker can replace the paired weapons with a Master-crafted Power Weapon and Storm Shield, granting that model a 4+ invulnerable save. Hunting Wolves use Teeth and Claws.

The local rules scope registers:

- **Headhunters:** at the start of the first battle round, each resulting unit can select up to one enemy unit as its quarry or pass. Attacks against that unit gain Devastating Wounds and Precision. When a quarry is destroyed, its owner must select a living replacement if one remains.
- **Let Loose the Wolves:** an optional Declare Battle Formations choice splits all Wolves from all Headtakers and attached Leaders/Support models. Starting strengths are updated, the Leader stays with the Headtakers, and the combined roster cost is preserved.
- **Hunting Hounds:** a Hunting Wolf gains +1 OC while its unit is not Battle-shocked and is within 6 inches of a friendly Space Wolves Character other than a Wulfen.
- **Storm Shield:** a per-Headtaker reversible equipment choice applies the source-listed weapon replacement and 4+ invulnerable save.

All six source-listed Leader targets are now selectable for the admitted mixed profile: Wolf Priest, Wolf Guard Battle Leader, Ragnar Blackmane, Ulrik the Slayer, Njal Stormcaller and Iron Priest. The focused test attaches each through the public setup choice.

## Verification and remaining limits

The focused Headtakers test passed 3/3 offline processes at `.tools/verification/20261029T214027644989Z/results.json` (SHA-256 `12FF611601AE39A51319B5EF4BB3C02250A5B2DC8CD56D52017C8AC00F6CE838`; network disabled, no legacy starter staged, no cleanup diagnostics). It checks both admitted sizes and tiers, rejects both incompatible Headtakers-only options, exercises all six Leader attachments, Storm Shield replacement, the split with an attached Leader, separate post-split quarries, quarry-only attack traits, mandatory replacement selection and Hunting Hounds OC. The connected Wolf Scouts, Fenrisian Wolves, Watch Master and Leader-link regression passed 7/7 processes at `.tools/verification/20261029T205134675733Z/results.json` (SHA-256 `991D3C5A5DFB6A60F00350D5E527F33CF1FF48D3B25AC4369CD40E00A76A22BA`; network disabled, no legacy starter staged, no cleanup diagnostics).

This is not complete datasheet certification. Runtime admits only the two exact MFM-priced mixed compositions; it blocks the two Wahapedia-incompatible Headtakers-only rows and other source-permitted role mixes that lack an explicit MFM price. Final network/page validation, full Space Wolves roster legality and human playtesting remain open. The local profile does not certify exact oval-base geometry or every battlefield interaction.
