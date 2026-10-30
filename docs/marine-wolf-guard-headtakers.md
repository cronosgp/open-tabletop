# Wolf Guard Headtakers

## Scope and source

This is a **partial source-bounded local profile** for Space Wolves App datasheet `000004131` in standard Warhammer 40,000 11th edition. The current Wahapedia page was rechecked on 30 October; fixed datasheet facts match verified Data Export snapshot `wahapedia-e11-live-refresh-final-user-readiness-20261030T013229Z`, retrieved 29 October local time at `2026-10-30T01:33:48.347556Z`. The export was updated `2026-10-28T23:48:19+03:00`. Parent manifest-file SHA-256 is `12ac4ca99c29456195287d9a2c947fdea0c4c8fd659b5bfa3a7a829ede87283e`; the Headtakers subject-slice manifest-file SHA-256 is `e0178a7d1203b781f24987b55980b832a6ff10112d1a5b1a70a21df4df50ebc7`, with subject catalog SHA-256 `4900aafe8d4c54bad4ea48229ad7be45f66c487f458abea1c3155553bb9775d6`. The subject slice has zero structural findings. The parent export has 68 unrelated findings; they are not treated as passed. See the [machine-readable source and verification audit](marine-wolf-guard-headtakers-audit.json).

## Admitted compositions and points

The current official [Munitorum Field Manual — Space Wolves, v1.0](https://mfm.warhammer-community.com/en/space-wolves), rechecked 30 October 2026 and listed on the download update dated 14 October, explicitly maps all four model-count rows. Wahapedia's selected composition requires 3–6 Hunting Wolves **and** 3–6 Wolf Guard Headtakers, so construction admits the two mixed rows and blocks the Headtakers-only rows.

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

The integrated three-sheet readiness batch passed **11/11 processes** at `.tools/verification/20261030T070201355409Z/results.json` (SHA-256 `eb3e935cc2ba1cbd6494ce3f5342b0af3a9a9f9b260affec4435a68b26b09913`; `network: false`, legacy starter staged, no cleanup diagnostics), including Headtakers, composition gates, catalog and capabilities.

## Verification and remaining limits

The focused Headtakers test passed 3/3 offline processes at `.tools/verification/20261029T214027644989Z/results.json` (SHA-256 `12FF611601AE39A51319B5EF4BB3C02250A5B2DC8CD56D52017C8AC00F6CE838`; network disabled, no legacy starter staged, no cleanup diagnostics). It checks both admitted sizes and tiers, rejects both incompatible Headtakers-only options, exercises all six Leader attachments, Storm Shield replacement, the split with an attached Leader, separate post-split quarries, quarry-only attack traits, mandatory replacement selection and Hunting Hounds OC. The connected Wolf Scouts, Fenrisian Wolves, Watch Master and Leader-link regression passed 7/7 processes at `.tools/verification/20261029T205134675733Z/results.json` (SHA-256 `991D3C5A5DFB6A60F00350D5E527F33CF1FF48D3B25AC4369CD40E00A76A22BA`; network disabled, no legacy starter staged, no cleanup diagnostics).

This is not complete datasheet certification. The live Wahapedia page, current Data Export slice and official MFM v1.0 rows were checked together on 29 October; all three subject slices were structurally valid with zero findings. Runtime admits only the two exact MFM-priced mixed compositions; it blocks the two Wahapedia-incompatible Headtakers-only rows and other source-permitted role mixes that lack an explicit MFM price. Full Space Wolves roster legality and human playtesting remain open. The local profile does not certify exact oval-base geometry or every battlefield interaction.

An earlier three-sheet readiness batch passed **14/14 processes** at `.tools/verification/20261030T015331833516Z/results.json` (SHA-256 `5B927A356524B9E0613EED2B39E33F4C5D17B851B1305D376944689D4A2B1338`; `network: false`, no cleanup diagnostics), including cost-tier, composition, ability, Leader-link and roster-admission checks. Only the explicitly priced 3+3 and 6+6 source-compatible choices remain selectable; other permitted role mixes without confirmed MFM costs stay blocked.

The focused three-sheet run passed **5/5 processes** on 30 October at `.tools/verification/20261030T030111786006Z/results.json` (SHA-256 `6bee64a7cbcc7387b986e4cb9504a2e7798e1b6275474caa63f3899deacccd2d`; `network: false`, legacy starter staged, no cleanup diagnostics). The current Wahapedia page still requires 3–6 models of each role and lists the same four price rows; only the compatible, explicitly priced 3+3 and 6+6 mixtures are admitted. The Hunting Wolf oval is represented by a conservative 60 mm circular proxy, so exact base geometry is not certified.


The 30 October role-aware price audit reconciles each duplicate export cost row against the official MFM role mapping and checks selectable prices only for the two compatible, priced constructions. It passes as part of the **161/161** strict fixed-data comparison. The 30 October targeted batch passed **9/9 processes** at `.tools/verification/20261030T035752327644Z/results.json` (SHA-256 `467535c10b9f27f1fcfa99407abdf9a4f2470923e41ebb1820ba5a7c967f9768`; offline; no cleanup diagnostics). This closes the duplicate-row comparison issue; unpriced legal role mixes and exact oval geometry still keep the local scope partial.

Latest linked-sheet regression passed **15/15 processes** at `.tools/verification/20261030T102146906553Z/results.json` (SHA-256 `daa3134c46d55086618e0a01ec438cbd5e431470fef33759c66a01e2cbdd5cde`; `network: false`, legacy starter staged, no cleanup diagnostics). It rechecks the two admitted MFM-priced mixes; other role mixes without explicit MFM prices and exact oval-base geometry remain open.
