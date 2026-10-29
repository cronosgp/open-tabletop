# Wardens of Ultramar — 11th edition scope

Source: [Wahapedia 11th edition Wardens of Ultramar](https://wahapedia.ru/wh40k11ed/factions/space-marines/Wardens-of-Ultramar-1), Space Marines App book 000000139, datasheet 000004188. The live page was checked on 27 October 2026. Datasheet facts were reconciled against the verified local Data Export snapshot 20261021T130623Z (specification revision 20260817b, retrieved 2026-10-21T19:46:58Z; source timestamp 2026-10-21 16:06:23 GMT+3). Snapshot manifest SHA-256: 169db99791a91582fd043902303e73c4af83ec63e96c01817ce52cb5ce4deccf. Relevant CSV file hashes are preserved in [the audit JSON](marine-wardens-ultramar-audit.json).

## Profile and equipment

The unit has six fixed models for 115 points, with no equipment-option rows. Local construction allows one copy. The source records these individual bases and roles:

| Model | Base | Source-specific defense or keyword |
|---|---:|---|
| Aemelia Minervas | 28.5 mm | — |
| Ancient Gadriel | 40 mm | OC 2 |
| Dainal Kornelius | 28.5 mm | PSYKER |
| Gaius Silva | 28.5 mm | 5+ invulnerable save |
| Lucia Vestha | 28.5 mm | — |
| Veteran Sergeant Metaurus | 40 mm | T5, Sv 3+, W4, 4+ invulnerable save |

The export spells Dainal's surname Komelius in the characteristics table and Kornelius in loadout/composition text. The implementation preserves that source discrepancy. The runtime catalog uses the largest base as its unit proxy; combat materialization assigns each model its exact source base radius.

Fixed loadouts are all represented: Aemelia and Gaius carry an Archeotech Laspistol and Power Weapon; Ancient Gadriel carries a Bolt Rifle and Ceramite Fists; Dainal carries Astropathic Blast and Force Stave; Lucia carries an Archeotech Laspistol and Ultramarian Combat Weapons; Metaurus carries a Heavy Bolt Pistol and Master-crafted Power Weapon. Ancient Gadriel's Bolt Rifle includes both Focused Fire and Saturation profiles. All nine distinct weapon profiles pass the local Equipment and AttackPlan checks.

## Rules and attachments

The source lists **Support**, **Combat Doctrines**, **Raise the Banner** and **Strategium Command**. Current local Support targets are Assault Intercessor Squad, Bladeguard Veteran Squad, Intercessor Squad and Sternguard Veteran Squad. Wahapedia also lists a Vanguard Veteran Squad target; that datasheet is in Legends and outside the shared-book 85.

Raise the Banner secures an objective the Wardens control at the end of their own Movement phase. The check rejects an opponent Movement-phase trigger.

After both armies deploy, Strategium Command lets the Wardens player redeploy up to three deployed friendly Adeptus Astartes units under the normal setup restrictions, or place them in Strategic Reserves without the normal points cap. It resolves before Scouts. Local checks cover wrong-owner rejection without mutation, legal and illegal normal placements, the Strategic Reserves exception, three distinct selections and progression to the next pre-battle step.

## Verification

The focused offline run passed **3/3 processes** (import, Python checks and test_marine_wardens_profile) with network: false, legacy_starter_staged: false and no cleanup diagnostics. SHA-256: a6452e5031358ce0799067ac80ec8ccf91412fed6cf7ad1cfd11eddc953fd932. A broader 7-process regression covering Leader/Support links, Ancients, Company Heroes and the catalog also passed; that run staged the optional legacy starter and is recorded separately in the audit.

See [the profile audit](marine-wardens-ultramar-audit.json), [coverage matrix](space-marines-coverage.md) and [verification record](verification/verification-results.md).

This closes only the Wardens common-book local datasheet scope. It does not certify full Ultramarines roster rules, Legends attachments, complete faction or army legality, network behavior, complete matches or human playtesting. Network validation remains deferred to final integration.
